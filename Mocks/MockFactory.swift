import Foundation

enum MockFactory {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func loadSummaryHighRisk() throws -> PollenSummary {
        try loadJSON(named: "pollen-summary-high-risk", as: PollenSummary.self)
    }

    static func loadSummaryLowConfidence() throws -> PollenSummary {
        try loadJSON(named: "pollen-summary-low-confidence", as: PollenSummary.self)
    }

    static func loadForecastThreeDay() throws -> PollenForecast {
        try loadJSON(named: "pollen-forecast-3day", as: PollenForecast.self)
    }

    static func loadAlertSubscription() throws -> AlertSubscription {
        try loadJSON(named: "alert-subscription-default", as: AlertSubscription.self)
    }

    static func loadAlertHistory() throws -> [AlertHistoryItem] {
        try loadJSON(named: "alert-history-week", as: [AlertHistoryItem].self)
    }

    static func loadSourceMeta() throws -> [SourceMeta] {
        try loadJSON(named: "source-meta-list", as: [SourceMeta].self)
    }

    static func loadAuthAnonymous() throws -> AuthMe {
        try loadJSON(named: "auth-me-anonymous", as: AuthMe.self)
    }

    static func loadAuthSignedIn() throws -> AuthMe {
        try loadJSON(named: "auth-me-signed-in", as: AuthMe.self)
    }

    static func loadSuggestions() throws -> [LocationSuggestion] {
        try loadJSON(named: "location-suggestions", as: [LocationSuggestion].self)
    }

    private static func loadJSON<T: Decodable>(named name: String, as type: T.Type) throws -> T {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("JSON")
            .appendingPathComponent("\(name).json")
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
}
