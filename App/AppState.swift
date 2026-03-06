import Observation

@Observable
final class AppState {
    var hasSeenOnboarding = false
    var selectedTab: AppTab = .today
    var route: AppRoute?
}
