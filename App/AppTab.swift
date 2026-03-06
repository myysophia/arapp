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
            "今日"
        case .map:
            "地图"
        case .alerts:
            "提醒"
        case .profile:
            "我的"
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
