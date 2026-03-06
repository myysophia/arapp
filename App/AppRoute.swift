import Foundation

enum AppRoute: Hashable, Identifiable {
    case login
    case onboarding

    var id: String {
        switch self {
        case .login:
            "login"
        case .onboarding:
            "onboarding"
        }
    }
}
