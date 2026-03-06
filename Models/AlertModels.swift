import Foundation

struct AlertSubscription: Codable, Identifiable, Sendable {
    let id: UUID
    let userID: UUID?
    let locationID: UUID
    let thresholdLevel: PollenRiskLevel
    let enabled: Bool
    let quietHours: QuietHours
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case locationID = "location_id"
        case thresholdLevel = "threshold_level"
        case enabled
        case quietHours = "quiet_hours"
        case updatedAt = "updated_at"
    }
}

struct QuietHours: Codable, Sendable {
    let enabled: Bool
    let start: String?
    let end: String?
}

struct AlertHistoryItem: Codable, Identifiable, Sendable {
    let id: UUID
    let date: String
    let riskLevel: PollenRiskLevel
    let title: String

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case riskLevel = "risk_level"
        case title
    }
}
