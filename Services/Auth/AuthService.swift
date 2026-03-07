import Foundation

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
    let redirectScheme: String
}

struct SupabaseAuthService: AuthServicing {
    let configuration: SupabaseAuthConfiguration

    func currentSession() async throws -> AuthSession {
        throw AuthServiceError.unimplemented("尚未接入 Supabase SDK，会话读取先走 MockAuthService。")
    }

    func signIn(with provider: AuthProvider) async throws -> AuthSession {
        throw AuthServiceError.unimplemented("尚未接入 Supabase SDK，真实 OAuth 流程先由适配层协议占位。")
    }

    func signOut() async throws {
        throw AuthServiceError.unimplemented("尚未接入 Supabase SDK，登出流程先由适配层协议占位。")
    }
}

private extension AuthProvider {
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
