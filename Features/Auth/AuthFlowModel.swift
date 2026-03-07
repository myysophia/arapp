import Foundation
import Observation

@MainActor
@Observable
final class AuthFlowModel {
    enum Phase: Equatable {
        case idle
        case signingIn(AuthProvider)
        case signedIn
        case failed(String)
    }

    static let shared = AuthFlowModel()

    var phase: Phase = .idle
    var session: AuthSession

    private var hasBootstrapped = false
    private let service: any AuthServicing
    private let anonymousSession: AuthSession

    init(service: any AuthServicing = MockAuthService.anonymous) {
        let initialAnonymousSession = AuthSession(
            userID: nil,
            providers: [],
            accessToken: nil,
            refreshToken: nil,
            isAnonymous: true
        )
        self.service = service
        self.session = initialAnonymousSession
        self.anonymousSession = initialAnonymousSession
    }

    var authMe: AuthMe {
        AuthMe(
            userID: session.userID,
            isAnonymous: session.isAnonymous,
            providers: session.providers,
            locale: "zh-Hans",
            region: "CN",
            unitSystem: .metric
        )
    }

    var displayName: String {
        guard !session.isAnonymous else {
            return "匿名使用中"
        }

        if let firstProvider = session.providers.first {
            return "\(providerName(firstProvider)) 账户"
        }

        return "已登录用户"
    }

    var isAnonymous: Bool {
        session.isAnonymous
    }

    var isSigningIn: Bool {
        if case .signingIn = phase {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case let .failed(message) = phase {
            return message
        }
        return nil
    }

    var statusChipText: String? {
        switch phase {
        case let .signingIn(provider):
            return "\(providerName(provider)) 登录中"
        case .failed:
            return "登录失败"
        case .signedIn:
            return "已连接"
        case .idle:
            return nil
        }
    }

    func bootstrapIfNeeded() async {
        guard !hasBootstrapped else { return }
        hasBootstrapped = true
        await refreshSession()
    }

    func refreshSession() async {
        do {
            let currentSession = try await service.currentSession()
            session = currentSession
            phase = currentSession.isAnonymous ? .idle : .signedIn
        } catch {
            session = anonymousSession
            phase = .failed(error.localizedDescription)
        }
    }

    func signIn(with provider: AuthProvider) async {
        phase = .signingIn(provider)

        do {
            let signedInSession = try await service.signIn(with: provider)
            session = signedInSession
            phase = .signedIn
        } catch {
            session = anonymousSession
            phase = .failed(error.localizedDescription)
        }
    }

    func continueAnonymously() {
        session = anonymousSession
        phase = .idle
    }

    func signOut() async {
        do {
            try await service.signOut()
        } catch {
            phase = .failed(error.localizedDescription)
            return
        }

        session = anonymousSession
        phase = .idle
    }

    func dismissError() {
        if case .failed = phase {
            phase = session.isAnonymous ? .idle : .signedIn
        }
    }

    func isSigningIn(_ provider: AuthProvider) -> Bool {
        if case let .signingIn(currentProvider) = phase {
            return currentProvider == provider
        }
        return false
    }

    func providerTitle(_ provider: AuthProvider) -> String {
        isSigningIn(provider) ? "正在连接 \(providerName(provider))" : "使用 \(providerName(provider)) 继续"
    }

    func providerSubtitle(_ provider: AuthProvider) -> String {
        switch provider {
        case .google:
            return isSigningIn(provider) ? "正在模拟 OAuth 回调和会话建立" : "适合需要快速同步设置的用户"
        case .github:
            return isSigningIn(provider) ? "正在模拟开发者账号登录" : "适合开发者账号体系保持一致"
        case .apple:
            return isSigningIn(provider) ? "正在模拟原生 Apple 登录" : "遵循 iOS 原生登录习惯"
        }
    }

    private func providerName(_ provider: AuthProvider) -> String {
        switch provider {
        case .google:
            return "Google"
        case .github:
            return "GitHub"
        case .apple:
            return "Apple"
        }
    }
}
