import Foundation

struct SourceMeta: Codable, Identifiable, Sendable {
    let id: UUID
    let providerName: String
    let source: PollenSourceType
    let coverageNote: String
    let licenseNote: String
    let active: Bool
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case providerName = "provider_name"
        case source
        case coverageNote = "coverage_note"
        case licenseNote = "license_note"
        case active
        case updatedAt = "updated_at"
    }
}

struct LocationSuggestion: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let countryCode: String
    let admin1: String?
    let lat: Double
    let lng: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case countryCode = "country_code"
        case admin1
        case lat
        case lng
    }
}
