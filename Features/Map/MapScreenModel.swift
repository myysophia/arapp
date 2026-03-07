import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class MapScreenModel {
    enum DataMode: String, CaseIterable, Identifiable {
        case mock
        case client

        var id: String { rawValue }

        var title: String {
            switch self {
            case .mock:
                L10n.tr("common.mode.mock")
            case .client:
                L10n.tr("common.mode.client")
            }
        }
    }

    enum MockScenario: String, CaseIterable, Identifiable {
        case success
        case failure

        var id: String { rawValue }

        var title: String {
            switch self {
            case .success:
                L10n.tr("common.scenario.success")
            case .failure:
                L10n.tr("common.scenario.failure")
            }
        }
    }

    enum ContentState {
        case loading
        case success(MapScreenState)
        case failure(title: String, detail: String, retryable: Bool)
    }

    var dataMode: DataMode
    var mockScenario: MockScenario
    var contentState: ContentState
    var isSearchSheetPresented = false
    var isSourceSheetPresented = false
    var selectedPointID: UUID?

    private let mockClient: MockPollenAPIClient
    private let liveClientFactory: @Sendable () throws -> any PollenAPIClienting

    init(
        dataMode: DataMode = .mock,
        mockScenario: MockScenario = .success,
        mockClient: MockPollenAPIClient = .demo,
        liveClientFactory: @escaping @Sendable () throws -> any PollenAPIClienting = {
            let environment = ProcessInfo.processInfo.environment
            guard
                let rawBaseURL = environment["ARAPP_EDGE_BASE_URL"],
                let baseURL = URL(string: rawBaseURL)
            else {
                throw MapScreenModelError.missingBaseURL
            }

            return EdgeFunctionsPollenAPIClient(
                baseURL: baseURL,
                accessToken: environment["ARAPP_ACCESS_TOKEN"]
            )
        }
    ) {
        self.dataMode = dataMode
        self.mockScenario = mockScenario
        self.contentState = .loading
        self.mockClient = mockClient
        self.liveClientFactory = liveClientFactory
    }

    var reloadKey: String {
        "\(dataMode.rawValue):\(mockScenario.rawValue)"
    }

    func reload() async {
        contentState = .loading

        do {
            switch dataMode {
            case .mock:
                try await Task.sleep(for: .milliseconds(250))
                contentState = try await makeMockState()
            case .client:
                let client = try liveClientFactory()
                contentState = try await makeClientState(using: client)
            }
        } catch let error as MapScreenModelError {
            contentState = .failure(
                title: error.title,
                detail: error.errorDescription ?? L10n.tr("map.error.load_failed"),
                retryable: error.isRetryable
            )
        } catch let error as APIClientError {
            contentState = .failure(
                title: L10n.tr("common.client_unavailable"),
                detail: error.errorDescription ?? L10n.tr("map.error.client_request_failed"),
                retryable: true
            )
        } catch {
            contentState = .failure(
                title: L10n.tr("map.error.screen_failed"),
                detail: error.localizedDescription,
                retryable: true
            )
        }
    }

    func selectPoint(_ pointID: UUID) {
        selectedPointID = pointID
    }

    func toggleSearchSheet() {
        isSearchSheetPresented.toggle()
    }

    func toggleSourceSheet() {
        isSourceSheetPresented.toggle()
    }

    private func makeMockState() async throws -> ContentState {
        switch mockScenario {
        case .success:
            let state = Self.demoState
            selectedPointID = state.mapPoints.first?.id
            return .success(state)
        case .failure:
            return .failure(
                title: L10n.tr("map.mock_failure.title"),
                detail: L10n.tr("map.mock_failure.detail"),
                retryable: true
            )
        }
    }

    private func makeClientState(using client: any PollenAPIClienting) async throws -> ContentState {
        async let suggestionsEnvelope = client.fetchLocationSuggestions(query: L10n.tr("common.default_city"), lang: Self.language)
        async let summaryEnvelope = client.fetchSummary(Self.summaryQuery)
        async let sourceMetaEnvelope = client.fetchSourceMeta(lang: Self.language)

        let suggestions = try await suggestionsEnvelope.payload
        let summary = try await summaryEnvelope.payload
        let sourceMeta = try await sourceMetaEnvelope.payload

        let selectedLocation = suggestions.first ?? Self.defaultLocation
        let source = sourceMeta.first(where: \.active) ?? sourceMeta.first ?? .placeholder(for: summary.source)
        let mapPoints = Self.makeClientPoints(from: summary)
        let state = MapScreenState(
            searchPlaceholder: L10n.tr("map.search.placeholder"),
            selectedLocation: selectedLocation,
            source: source,
            mapPoints: mapPoints,
            searchItems: Self.makeSearchItems(from: suggestions)
        )
        selectedPointID = mapPoints.first?.id
        return .success(state)
    }

    private static let language = L10n.apiLanguageIdentifier

    private static let summaryQuery = SummaryQuery(
        lat: 31.2304,
        lng: 121.4737,
        lang: language,
        unit: .metric
    )

    private static let defaultLocation = LocationSuggestion(
        id: UUID(uuidString: "6f222b19-b7c9-4baa-8661-2dd6905ddf00") ?? UUID(),
        name: L10n.tr("common.default_city"),
        countryCode: "CN",
        admin1: L10n.tr("common.default_city_admin"),
        lat: 31.2304,
        lng: 121.4737
    )

    private static let demoState = MapScreenState(
        searchPlaceholder: L10n.tr("map.search.placeholder"),
        selectedLocation: defaultLocation,
        source: SourceMeta(
            id: UUID(uuidString: "8d11c444-0dd7-492d-a185-774bcc66a6f7") ?? UUID(),
            providerName: L10n.tr("map.demo.provider"),
            source: .model,
            coverageNote: L10n.tr("map.demo.coverage"),
            licenseNote: L10n.tr("map.demo.license"),
            active: true,
            updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now
        ),
        mapPoints: [
            MapPointState(
                id: UUID(uuidString: "42106b0a-6200-44b0-9fbe-f0a4cce30001") ?? UUID(),
                locationName: L10n.tr("map.demo.location.pudong"),
                summary: PollenSummary(
                    id: "map-summary-pudong",
                    cityName: L10n.tr("map.demo.location.pudong"),
                    locationID: UUID(uuidString: "42106b0a-6200-44b0-9fbe-f0a4cce30001"),
                    riskOverall: .veryHigh,
                    treeLevel: .moderate,
                    grassLevel: .veryHigh,
                    weedLevel: .high,
                    confidence: 0.88,
                    updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now,
                    source: .model,
                    isStale: false
                ),
                offset: CGSize(width: 84, height: 24)
            ),
            MapPointState(
                id: UUID(uuidString: "42106b0a-6200-44b0-9fbe-f0a4cce30002") ?? UUID(),
                locationName: L10n.tr("map.demo.location.jingan"),
                summary: PollenSummary(
                    id: "map-summary-jingan",
                    cityName: L10n.tr("map.demo.location.jingan"),
                    locationID: UUID(uuidString: "42106b0a-6200-44b0-9fbe-f0a4cce30002"),
                    riskOverall: .high,
                    treeLevel: .low,
                    grassLevel: .high,
                    weedLevel: .moderate,
                    confidence: 0.82,
                    updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now,
                    source: .model,
                    isStale: false
                ),
                offset: CGSize(width: -72, height: -52)
            ),
            MapPointState(
                id: UUID(uuidString: "42106b0a-6200-44b0-9fbe-f0a4cce30003") ?? UUID(),
                locationName: L10n.tr("map.demo.location.xuhui"),
                summary: PollenSummary(
                    id: "map-summary-xuhui",
                    cityName: L10n.tr("map.demo.location.xuhui"),
                    locationID: UUID(uuidString: "42106b0a-6200-44b0-9fbe-f0a4cce30003"),
                    riskOverall: .moderate,
                    treeLevel: .low,
                    grassLevel: .moderate,
                    weedLevel: .low,
                    confidence: 0.79,
                    updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now,
                    source: .model,
                    isStale: false
                ),
                offset: CGSize(width: 12, height: 154)
            )
        ],
        searchItems: [
            SearchSheetItem(id: "shanghai", title: L10n.tr("common.default_city"), subtitle: L10n.tr("map.search.item.shanghai"), badge: L10n.tr("map.search.badge.current")),
            SearchSheetItem(id: "hangzhou", title: L10n.tr("map.search.city.hangzhou"), subtitle: L10n.tr("map.search.item.hangzhou"), badge: L10n.tr("map.search.badge.switchable")),
            SearchSheetItem(id: "suzhou", title: L10n.tr("map.search.city.suzhou"), subtitle: L10n.tr("map.search.item.suzhou"), badge: L10n.tr("map.search.badge.switchable"))
        ]
    )

    private static func makeClientPoints(from summary: PollenSummary) -> [MapPointState] {
        [
            MapPointState(
                id: UUID(),
                locationName: summary.cityName,
                summary: summary,
                offset: CGSize(width: 36, height: 12)
            ),
            MapPointState(
                id: UUID(),
                locationName: L10n.tr("map.client.neighbor_a"),
                summary: PollenSummary(
                    id: summary.id + "-a",
                    cityName: L10n.tr("map.client.neighbor_a"),
                    locationID: UUID(),
                    riskOverall: summary.riskOverall == .veryHigh ? .high : summary.riskOverall,
                    treeLevel: summary.treeLevel,
                    grassLevel: summary.grassLevel,
                    weedLevel: summary.weedLevel,
                    confidence: summary.confidence,
                    updatedAt: summary.updatedAt,
                    source: summary.source,
                    isStale: summary.isStale
                ),
                offset: CGSize(width: -64, height: -28)
            ),
            MapPointState(
                id: UUID(),
                locationName: L10n.tr("map.client.neighbor_b"),
                summary: PollenSummary(
                    id: summary.id + "-b",
                    cityName: L10n.tr("map.client.neighbor_b"),
                    locationID: UUID(),
                    riskOverall: summary.riskOverall == .none ? .low : .moderate,
                    treeLevel: summary.treeLevel,
                    grassLevel: summary.grassLevel,
                    weedLevel: summary.weedLevel,
                    confidence: summary.confidence,
                    updatedAt: summary.updatedAt,
                    source: summary.source,
                    isStale: summary.isStale
                ),
                offset: CGSize(width: 18, height: 148)
            )
        ]
    }

    private static func makeSearchItems(from suggestions: [LocationSuggestion]) -> [SearchSheetItem] {
        let mapped = suggestions.prefix(3).map { suggestion in
            SearchSheetItem(
                id: suggestion.id.uuidString,
                title: suggestion.name,
                subtitle: [suggestion.countryCode, suggestion.admin1].compactMap { $0 }.joined(separator: " · "),
                badge: suggestion.name == defaultLocation.name ? L10n.tr("map.search.badge.current") : L10n.tr("map.search.badge.recommended")
            )
        }

        return mapped.isEmpty ? demoState.searchItems : mapped
    }
}

private enum MapScreenModelError: LocalizedError {
    case missingBaseURL

    var title: String {
        switch self {
        case .missingBaseURL:
            L10n.tr("common.client_not_configured")
        }
    }

    var isRetryable: Bool {
        switch self {
        case .missingBaseURL:
            false
        }
    }

    var errorDescription: String? {
        switch self {
        case .missingBaseURL:
            L10n.tr("map.error.missing_base_url")
        }
    }
}

struct MapScreenState: Sendable {
    let searchPlaceholder: String
    let selectedLocation: LocationSuggestion
    let source: SourceMeta
    let mapPoints: [MapPointState]
    let searchItems: [SearchSheetItem]
}

struct MapPointState: Identifiable, Sendable {
    let id: UUID
    let locationName: String
    let summary: PollenSummary
    let offset: CGSize
}

extension MapScreenState {
    func selectedPoint(using pointID: UUID?) -> MapPointState? {
        if let pointID, let matched = mapPoints.first(where: { $0.id == pointID }) {
            return matched
        }
        return mapPoints.first
    }
}

extension PollenSummary {
    var mapRiskTitle: String {
        switch riskOverall {
        case .none:
            L10n.tr("map.risk.none")
        case .veryLow, .low:
            L10n.tr("map.risk.low")
        case .moderate:
            L10n.tr("map.risk.moderate")
        case .high:
            L10n.tr("map.risk.high")
        case .veryHigh:
            L10n.tr("map.risk.very_high")
        }
    }

    var mapRiskBadgeColor: Color { RiskPalette.color(for: riskOverall.uiLevel) }
    var mapRiskBadgeForeground: Color { RiskPalette.labelColor(for: riskOverall.uiLevel) }
}
