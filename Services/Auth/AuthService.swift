import Foundation
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif
import Auth

struct AuthSession: Sendable, Equatable {
    let userID: UUID?
    let providers: [AuthProvider]
    let accessToken: String?
    let refreshToken: String?
    let isAnonymous: Bool
}

protocol AuthServicing: Sendable {
    func currentSession() async throws -> AuthSession
    func signIn(with provider: AuthProvider) async throws -> AuthSession
    func signOut() async throws
}

protocol AuthCallbackSessionExchanging: Sendable {
    func exchangeSession(fromCallbackURL url: URL) async throws -> AuthSession
}

enum AuthServiceError: Error, LocalizedError, Sendable {
    case providerUnavailable(AuthProvider)
    case cancelled
    case invalidCallback
    case sessionMissing
    case unimplemented(String)

    var errorDescription: String? {
        switch self {
        case let .providerUnavailable(provider):
            "当前无法使用 \(provider.displayName) 登录。"
        case .cancelled:
            "用户取消了登录流程。"
        case .invalidCallback:
            "认证回调无效。"
        case .sessionMissing:
            "当前不存在可用会话。"
        case let .unimplemented(message):
            message
        }
    }
}

struct MockAuthService: AuthServicing {
    var session: AuthSession

    static let anonymous = MockAuthService(
        session: AuthSession(
            userID: nil,
            providers: [],
            accessToken: nil,
            refreshToken: nil,
            isAnonymous: true
        )
    )

    func currentSession() async throws -> AuthSession {
        session
    }

    func signIn(with provider: AuthProvider) async throws -> AuthSession {
        AuthSession(
            userID: UUID(),
            providers: [provider],
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token",
            isAnonymous: false
        )
    }

    func signOut() async throws {
    }
}

struct SupabaseAuthConfiguration: Sendable, Equatable {
    let projectURL: URL
    let anonKey: String
    let redirectScheme: String
    let redirectHost: String
    let redirectPath: String

    var redirectURL: URL? {
        var components = URLComponents()
        components.scheme = redirectScheme
        components.host = redirectHost
        components.path = redirectPath
        return components.url
    }

    func matchesCallback(_ url: URL) -> Bool {
        let incomingScheme = url.scheme?.lowercased()
        let expectedScheme = redirectScheme.lowercased()

        let incomingHost = url.host?.lowercased()
        let expectedHost = redirectHost.lowercased()

        let incomingPath = normalizedPath(url.path)
        let expectedPath = normalizedPath(redirectPath)

        return incomingScheme == expectedScheme
            && incomingHost == expectedHost
            && incomingPath == expectedPath
    }

    private func normalizedPath(_ value: String) -> String {
        var path = value
        if !path.hasPrefix("/") {
            path = "/\(path)"
        }
        while path.count > 1 && path.hasSuffix("/") {
            path.removeLast()
        }
        return path
    }
}

enum SupabaseAuthCallbackOutcome: Equatable, Sendable {
    case authorizationCode(String)
    case cancelled
    case providerFailure(code: String?, description: String?)
}

struct SupabaseAuthCallbackPayload: Equatable, Sendable {
    let callbackURL: URL
    let outcome: SupabaseAuthCallbackOutcome
}

struct SupabaseAuthCallbackParser {
    func parse(
        url: URL,
        configuration: SupabaseAuthConfiguration
    ) throws -> SupabaseAuthCallbackPayload {
        guard configuration.matchesCallback(url) else {
            throw AuthServiceError.invalidCallback
        }

        let fields = extractFields(from: url)

        if let errorCode = nonEmpty(fields["error"]) {
            let description = nonEmpty(fields["error_description"])
            let normalizedCode = errorCode.lowercased()
            let cancelledCodes: Set<String> = ["access_denied", "cancelled", "user_cancelled", "user_canceled"]
            if cancelledCodes.contains(normalizedCode) {
                return SupabaseAuthCallbackPayload(callbackURL: url, outcome: .cancelled)
            }
            return SupabaseAuthCallbackPayload(
                callbackURL: url,
                outcome: .providerFailure(code: errorCode, description: description)
            )
        }

        if let code = nonEmpty(fields["code"]) {
            return SupabaseAuthCallbackPayload(callbackURL: url, outcome: .authorizationCode(code))
        }

        throw AuthServiceError.invalidCallback
    }

    private func extractFields(from url: URL) -> [String: String] {
        var merged: [String: String] = [:]

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value {
                    merged[item.name] = value
                }
            }
        }

        if let fragment = URLComponents(url: url, resolvingAgainstBaseURL: false)?.fragment {
            for pair in fragment.split(separator: "&") {
                let pieces = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
                guard let key = pieces.first, !key.isEmpty else { continue }
                let value = pieces.count > 1 ? String(pieces[1]) : ""
                merged[String(key)] = value.removingPercentEncoding ?? value
            }
        }

        return merged
    }

    private func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct SupabaseAuthService: AuthServicing, AuthCallbackSessionExchanging {
    let configuration: SupabaseAuthConfiguration
    private let callbackParser: SupabaseAuthCallbackParser
    private let authClient: AuthClient

    init(
        configuration: SupabaseAuthConfiguration,
        callbackParser: SupabaseAuthCallbackParser = SupabaseAuthCallbackParser()
    ) {
        self.configuration = configuration
        self.callbackParser = callbackParser

        let headers = [
            "Authorization": "Bearer \(configuration.anonKey)",
            "apikey": configuration.anonKey
        ]
        let authURL = configuration.projectURL.appendingPathComponent("/auth/v1")
        self.authClient = AuthClient(
            url: authURL,
            headers: headers,
            redirectToURL: configuration.redirectURL,
            localStorage: AuthClient.Configuration.defaultLocalStorage
        )
    }

    func currentSession() async throws -> AuthSession {
        do {
            let liveSession: Session
            if let cachedSession = authClient.currentSession, !cachedSession.isExpired {
                liveSession = cachedSession
            } else {
                liveSession = try await authClient.session
            }
            return mapAuthSession(from: liveSession)
        } catch {
            if case AuthError.sessionMissing = error {
                throw AuthServiceError.sessionMissing
            }
            throw error
        }
    }

    func signIn(with provider: AuthProvider) async throws -> AuthSession {
        guard configuration.redirectURL != nil else {
            throw AuthServiceError.invalidCallback
        }

        do {
            let session = try await authClient.signInWithOAuth(
                provider: provider.supabaseProvider,
                redirectTo: configuration.redirectURL
            )
            return mapAuthSession(from: session)
        } catch {
            if isCancelledError(error) {
                throw AuthServiceError.cancelled
            }
            if case let AuthError.api(_, code, _, _) = error,
               code == .providerDisabled || code == .oauthProviderNotSupported {
                throw AuthServiceError.providerUnavailable(provider)
            }
            throw error
        }
    }

    func signOut() async throws {
        try await authClient.signOut()
    }

    func parseCallback(url: URL) throws -> SupabaseAuthCallbackPayload {
        try callbackParser.parse(url: url, configuration: configuration)
    }

    func exchangeSession(fromCallbackURL url: URL) async throws -> AuthSession {
        let payload = try parseCallback(url: url)
        switch payload.outcome {
        case .cancelled:
            throw AuthServiceError.cancelled
        case let .providerFailure(code, description):
            let message = [code, description]
                .compactMap { $0 }
                .joined(separator: ": ")
            throw AuthServiceError.unimplemented(
                message.isEmpty ? "认证提供方返回错误。" : "认证提供方返回错误：\(message)"
            )
        case .authorizationCode:
            do {
                let session = try await authClient.session(from: payload.callbackURL)
                return mapAuthSession(from: session)
            } catch {
                if case AuthError.sessionMissing = error {
                    throw AuthServiceError.sessionMissing
                }
                throw error
            }
        }
    }

    private func mapAuthSession(from session: Session) -> AuthSession {
        AuthSession(
            userID: session.user.id,
            providers: resolveProviders(from: session),
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            isAnonymous: session.user.isAnonymous
        )
    }

    private func resolveProviders(from session: Session) -> [AuthProvider] {
        guard let identities = session.user.identities else {
            return []
        }

        var providers: [AuthProvider] = []
        for identity in identities {
            guard
                let provider = AuthProvider(rawValue: identity.provider.lowercased()),
                !providers.contains(provider)
            else {
                continue
            }
            providers.append(provider)
        }
        return providers
    }

    private func isCancelledError(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }

        #if canImport(AuthenticationServices)
        let nsError = error as NSError
        return nsError.domain == ASWebAuthenticationSessionError.errorDomain
            && nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue
        #else
        return false
        #endif
    }
}

private extension AuthProvider {
    var supabaseProvider: Provider {
        switch self {
        case .google:
            return .google
        case .github:
            return .github
        case .apple:
            return .apple
        }
    }

    var displayName: String {
        switch self {
        case .google:
            "Google"
        case .github:
            "GitHub"
        case .apple:
            "Apple"
        }
    }
}
