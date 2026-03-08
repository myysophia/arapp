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
            return L10n.tr("auth.display_name.anonymous")
        }

        if let firstProvider = session.providers.first {
            return L10n.format("auth.display_name.provider_account", providerName(firstProvider))
        }

        return L10n.tr("auth.display_name.signed_in")
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
            return L10n.format("auth.status.signing_in", providerName(provider))
        case .failed:
            return L10n.tr("auth.status.failed")
        case .signedIn:
            return L10n.tr("auth.status.connected")
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

    func handleOAuthCallback(_ url: URL) async -> Bool {
        guard let callbackService = service as? any AuthCallbackSessionExchanging else {
            return false
        }

        do {
            let exchangedSession = try await callbackService.exchangeSession(fromCallbackURL: url)
            session = exchangedSession
            phase = exchangedSession.isAnonymous ? .idle : .signedIn
            hasBootstrapped = true
            return true
        } catch AuthServiceError.invalidCallback {
            return false
        } catch {
            session = anonymousSession
            phase = .failed(error.localizedDescription)
            hasBootstrapped = true
            return true
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
        isSigningIn(provider)
            ? L10n.format("auth.provider.connecting", providerName(provider))
            : L10n.format("auth.provider.continue_with", providerName(provider))
    }

    func providerSubtitle(_ provider: AuthProvider) -> String {
        switch provider {
        case .google:
            return isSigningIn(provider) ? L10n.tr("auth.provider.google.loading") : L10n.tr("auth.provider.google.subtitle")
        case .github:
            return isSigningIn(provider) ? L10n.tr("auth.provider.github.loading") : L10n.tr("auth.provider.github.subtitle")
        case .apple:
            return isSigningIn(provider) ? L10n.tr("auth.provider.apple.loading") : L10n.tr("auth.provider.apple.subtitle")
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
