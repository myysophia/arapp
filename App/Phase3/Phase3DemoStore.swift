import SwiftUI

@MainActor
final class Phase3DemoStore: ObservableObject {
    @Published var flowState: Phase3FlowState = .onboarding
    @Published var selectedTab: AppTab = .today
    @Published var onboardingIndex = 0
    @Published var onboardingState: Phase3OnboardingState = .baseline
    @Published var loginState: Phase3LoginState = .idle
    @Published var todayState: Phase3TodayState = .success
    @Published var mapState: Phase3MapState = .selected
    @Published var alertsState: Phase3AlertsState = .saved
    @Published var profileState: Phase3ProfileState = .anonymous
    @Published var isDebugPanelPresented = false

    let loginModel = Phase3MockFixtures.login
    let todayModel = Phase3MockFixtures.today
    let mapModel = Phase3MockFixtures.map
    let alertsModel = Phase3MockFixtures.alerts
    let profileModel = Phase3MockFixtures.profile
    let onboardingSteps = Phase3MockFixtures.onboarding

    func continueOnboarding() {
        if onboardingIndex < onboardingSteps.count - 1 {
            onboardingIndex += 1
        } else {
            flowState = .login
        }
    }

    func skipOnboarding() {
        flowState = .login
    }

    func continueWithoutLogin() {
        profileState = .anonymous
        selectedTab = .today
        flowState = .main
        loginState = .idle
    }

    func completeLogin(with provider: AuthProvider) {
        switch provider {
        case .google:
            loginState = .loadingGoogle
        case .github:
            loginState = .loadingGitHub
        case .apple:
            loginState = .loadingApple
        }
        profileState = .signedIn
        selectedTab = .today
        flowState = .main
        loginState = .idle
    }

    func failLogin() {
        loginState = .failed
    }

    func dismissLoginError() {
        loginState = .idle
    }

    func openDebugPanel() {
        isDebugPanelPresented = true
    }
}
