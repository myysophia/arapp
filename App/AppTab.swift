import SwiftUI

enum AppTab: String, CaseIterable, Hashable, Identifiable {
    case today
    case map
    case alerts
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            L10n.tr("tab.today")
        case .map:
            L10n.tr("tab.map")
        case .alerts:
            L10n.tr("tab.alerts")
        case .profile:
            L10n.tr("tab.profile")
        }
    }

    var systemImage: String {
        switch self {
        case .today:
            "sun.max"
        case .map:
            "map"
        case .alerts:
            "bell"
        case .profile:
            "person"
        }
    }
}
