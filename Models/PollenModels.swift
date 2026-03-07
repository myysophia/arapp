import Foundation

enum PollenSourceType: String, Codable, Sendable {
    case model
    case station
    case vendor
}

enum PollenRiskLevel: Int, Codable, Sendable, CaseIterable {
    case none = 0
    case veryLow = 1
    case low = 2
    case moderate = 3
    case high = 4
    case veryHigh = 5
}

struct PollenSummary: Codable, Identifiable, Sendable {
    let id: String
    let cityName: String
    let locationID: UUID?
    let riskOverall: PollenRiskLevel
    let treeLevel: PollenRiskLevel
    let grassLevel: PollenRiskLevel
    let weedLevel: PollenRiskLevel
    let confidence: Double
    let updatedAt: Date
    let source: PollenSourceType
    let isStale: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case cityName = "city_name"
        case locationID = "location_id"
        case riskOverall = "risk_overall"
        case treeLevel = "tree_level"
        case grassLevel = "grass_level"
        case weedLevel = "weed_level"
        case confidence
        case updatedAt = "updated_at"
        case source
        case isStale = "is_stale"
    }
}

struct ForecastPoint: Codable, Identifiable, Sendable {
    let id: String
    let date: String
    let riskOverall: PollenRiskLevel
    let treeLevel: PollenRiskLevel
    let grassLevel: PollenRiskLevel
    let weedLevel: PollenRiskLevel

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case riskOverall = "risk_overall"
        case treeLevel = "tree_level"
        case grassLevel = "grass_level"
        case weedLevel = "weed_level"
    }
}

struct PollenForecast: Codable, Sendable {
    let days: [ForecastPoint]
}
