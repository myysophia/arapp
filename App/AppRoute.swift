import Foundation

enum AppRoute: Hashable, Identifiable {
    case login
    case onboarding
    case statesCatalog

    var id: String {
        switch self {
        case .login:
            "login"
        case .onboarding:
            "onboarding"
        case .statesCatalog:
            "statesCatalog"
        }
    }
}
