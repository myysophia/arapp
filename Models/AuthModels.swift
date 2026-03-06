import Foundation

enum AuthProvider: String, Codable, Sendable, CaseIterable {
    case google
    case github
    case apple
}

enum UnitSystem: String, Codable, Sendable {
    case metric
    case imperial
}

struct AuthMe: Codable, Sendable {
    let userID: UUID?
    let isAnonymous: Bool
    let providers: [AuthProvider]
    let locale: String
    let region: String?
    let unitSystem: UnitSystem?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case isAnonymous = "is_anonymous"
        case providers
        case locale
        case region
        case unitSystem = "unit_system"
    }
}
