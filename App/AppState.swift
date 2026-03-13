import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var hasSeenOnboarding = false
    var selectedTab: AppTab = .today
    var route: AppRoute?
    var localeIdentifier: String {
        didSet {
            L10n.setLocaleIdentifier(localeIdentifier)
        }
    }

    let dependencies: AppDependencies
    let todayScreenModel: TodayScreenModel
    let mapScreenModel: MapScreenModel
    let alertsScreenModel: AlertsScreenModel
    let authFlowModel: AuthFlowModel

    init(dependencies: AppDependencies = AppDependencies()) {
        self.dependencies = dependencies
        self.todayScreenModel = dependencies.makeTodayScreenModel()
        self.mapScreenModel = dependencies.makeMapScreenModel()
        self.alertsScreenModel = dependencies.makeAlertsScreenModel()
        self.authFlowModel = dependencies.makeAuthFlowModel()
        self.localeIdentifier = L10n.storedLocaleIdentifier
        L10n.setLocaleIdentifier(localeIdentifier)

        applyUITestOverridesIfNeeded()
    }

    func toggleLocale() {
        localeIdentifier = localeIdentifier == "zh-Hans" ? "en" : "zh-Hans"
    }

    func openPhase3StatesCatalog() {
        route = .statesCatalog
    }

    func reopenOnboardingForReview() {
        hasSeenOnboarding = false
        route = .onboarding
    }

    func openLoginForReview() {
        route = .login
    }

    func jumpToTab(_ tab: AppTab) {
        selectedTab = tab
        route = nil
    }

    private func applyUITestOverridesIfNeeded() {
        let env = ProcessInfo.processInfo.environment
        if let skipValue = env[AppUITestEnvironmentKey.skipOnboarding], skipValue == "1" {
            hasSeenOnboarding = true
        }

        if let routeValue = env[AppUITestEnvironmentKey.initialRoute]?.lowercased(), routeValue == "login" {
            route = .login
        }

        if let errorMessage = env[AppUITestEnvironmentKey.loginErrorMessage] {
            authFlowModel.primeForUITestFailure(message: errorMessage)
        }
    }
}

private enum AppUITestEnvironmentKey {
    static let skipOnboarding = "ARAPP_UI_SKIP_ONBOARDING"
    static let initialRoute = "ARAPP_UI_INITIAL_ROUTE"
    static let loginErrorMessage = "ARAPP_UI_LOGIN_ERROR_MESSAGE"
}
