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
    }

    func toggleLocale() {
        localeIdentifier = localeIdentifier == "zh-Hans" ? "en" : "zh-Hans"
    }
}
