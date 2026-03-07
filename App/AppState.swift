import Foundation
import Observation

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

    init() {
        self.localeIdentifier = L10n.storedLocaleIdentifier
        L10n.setLocaleIdentifier(localeIdentifier)
    }

    func toggleLocale() {
        localeIdentifier = localeIdentifier == "zh-Hans" ? "en" : "zh-Hans"
    }
}
