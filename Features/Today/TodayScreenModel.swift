import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class TodayScreenModel {
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
        case empty
        case failure

        var id: String { rawValue }

        var title: String {
            switch self {
            case .success:
                L10n.tr("common.scenario.success")
            case .empty:
                L10n.tr("common.scenario.empty")
            case .failure:
                L10n.tr("common.scenario.failure")
            }
        }
    }

    enum ContentState {
        case loading
        case success(TodayScreenState)
        case empty(title: String, detail: String)
        case failure(title: String, detail: String, retryable: Bool)
    }

    var dataMode: DataMode
    var mockScenario: MockScenario
    var contentState: ContentState

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
                throw TodayScreenModelError.missingBaseURL
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
        } catch let error as TodayScreenModelError {
            contentState = .failure(
                title: error.title,
                detail: error.errorDescription ?? L10n.tr("today.error.load_failed"),
                retryable: error.isRetryable
            )
        } catch let error as APIClientError {
            contentState = .failure(
                title: L10n.tr("common.client_unavailable"),
                detail: error.errorDescription ?? L10n.tr("today.error.network_failed"),
                retryable: true
            )
        } catch {
            contentState = .failure(
                title: L10n.tr("today.error.screen_failed"),
                detail: error.localizedDescription,
                retryable: true
            )
        }
    }

    private func makeMockState() async throws -> ContentState {
        switch mockScenario {
        case .success:
            return .success(try await loadScreenState(using: mockClient))
        case .empty:
            return .empty(
                title: L10n.tr("today.empty.title"),
                detail: L10n.tr("today.empty.detail")
            )
        case .failure:
            return .failure(
                title: L10n.tr("today.mock_failure.title"),
                detail: L10n.tr("today.mock_failure.detail"),
                retryable: true
            )
        }
    }

    private func makeClientState(using client: any PollenAPIClienting) async throws -> ContentState {
        let screenState = try await loadScreenState(using: client)
        guard !screenState.forecast.days.isEmpty else {
            return .empty(
                title: L10n.tr("today.server_empty.title"),
                detail: L10n.tr("today.server_empty.detail")
            )
        }
        return .success(screenState)
    }

    private func loadScreenState(using client: any PollenAPIClienting) async throws -> TodayScreenState {
        async let summaryEnvelope = client.fetchSummary(Self.summaryQuery)
        async let forecastEnvelope = client.fetchForecast(Self.forecastQuery)
        async let sourceMetaEnvelope = client.fetchSourceMeta(lang: Self.language)

        let summary = try await summaryEnvelope.payload
        let forecast = try await forecastEnvelope.payload
        let sourceMeta = try await sourceMetaEnvelope.payload

        return TodayScreenState(
            summary: summary,
            forecast: forecast,
            source: sourceMeta.first(where: \ .active) ?? sourceMeta.first ?? .placeholder(for: summary.source),
            adviceItems: Self.makeAdviceItems(for: summary.riskOverall)
        )
    }

    private static let language = L10n.apiLanguageIdentifier

    private static let summaryQuery = SummaryQuery(
        lat: 31.2304,
        lng: 121.4737,
        lang: language,
        unit: .metric
    )

    private static let forecastQuery = ForecastQuery(
        lat: 31.2304,
        lng: 121.4737,
        days: 3,
        lang: language,
        unit: .metric
    )

    private static func makeAdviceItems(for risk: PollenRiskLevel) -> [TodayAdviceItem] {
        switch risk {
        case .none, .veryLow, .low:
            [
                TodayAdviceItem(title: L10n.tr("today.advice.low.1.title"), detail: L10n.tr("today.advice.low.1.detail"), systemImage: "figure.walk"),
                TodayAdviceItem(title: L10n.tr("today.advice.low.2.title"), detail: L10n.tr("today.advice.low.2.detail"), systemImage: "eye")
            ]
        case .moderate:
            [
                TodayAdviceItem(title: L10n.tr("today.advice.moderate.1.title"), detail: L10n.tr("today.advice.moderate.1.detail"), systemImage: "sun.max"),
                TodayAdviceItem(title: L10n.tr("today.advice.moderate.2.title"), detail: L10n.tr("today.advice.moderate.2.detail"), systemImage: "drop")
            ]
        case .high, .veryHigh:
            [
                TodayAdviceItem(title: L10n.tr("today.advice.high.1.title"), detail: L10n.tr("today.advice.high.1.detail"), systemImage: "house"),
                TodayAdviceItem(title: L10n.tr("today.advice.high.2.title"), detail: L10n.tr("today.advice.high.2.detail"), systemImage: "shield.lefthalf.filled"),
                TodayAdviceItem(title: L10n.tr("today.advice.high.3.title"), detail: L10n.tr("today.advice.high.3.detail"), systemImage: "bell.badge")
            ]
        }
    }
}

private enum TodayScreenModelError: LocalizedError {
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
            L10n.tr("today.error.missing_base_url")
        }
    }
}

struct TodayAdviceItem: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

struct TodayScreenState: Sendable {
    let summary: PollenSummary
    let forecast: PollenForecast
    let source: SourceMeta
    let adviceItems: [TodayAdviceItem]
}

extension PollenSummary {
    var uiLevel: AppRiskLevel { riskOverall.uiLevel }

    var riskTitle: String {
        switch riskOverall {
        case .none:
            L10n.tr("risk.title.none")
        case .veryLow, .low:
            L10n.tr("risk.title.low")
        case .moderate:
            L10n.tr("risk.title.moderate")
        case .high:
            L10n.tr("risk.title.high")
        case .veryHigh:
            L10n.tr("risk.title.very_high")
        }
    }

    var riskDescription: String {
        switch riskOverall {
        case .none:
            L10n.tr("today.risk_description.none")
        case .veryLow, .low:
            L10n.tr("today.risk_description.low")
        case .moderate:
            L10n.tr("today.risk_description.moderate")
        case .high:
            L10n.tr("today.risk_description.high")
        case .veryHigh:
            L10n.tr("today.risk_description.very_high")
        }
    }

    var riskBadgeText: String { uiLevel.displayText }
    var riskBadgeColor: Color { RiskPalette.color(for: uiLevel) }
    var riskBadgeForeground: Color { RiskPalette.labelColor(for: uiLevel) }

    var confidenceText: String {
        AppFormatters.percentText(confidence)
    }

    var heroMetrics: [RiskHeroMetric] {
        var items = [
            RiskHeroMetric(
                title: L10n.tr("today.hero.confidence"),
                value: confidenceText,
                systemImage: "shield.lefthalf.filled"
            )
        ]

        if isStale {
            items.append(
                RiskHeroMetric(
                    title: L10n.tr("today.hero.status"),
                    value: L10n.tr("today.hero.stale"),
                    systemImage: "clock.arrow.circlepath"
                )
            )
        } else {
            items.append(
                RiskHeroMetric(
                    title: L10n.tr("today.hero.source_type"),
                    value: sourceTag,
                    systemImage: "waveform.path.ecg"
                )
            )
        }

        return items
    }
}

extension ForecastPoint {
    var displayDate: String {
        guard let parsed = ISO8601DateFormatter().date(from: date + "T00:00:00Z") else {
            return date
        }
        return AppFormatters.monthDayText(parsed)
    }
}

extension PollenForecast {
    var trendItems: [TrendMiniChartItem] {
        days.map { day in
            TrendMiniChartItem(
                id: day.id,
                levelText: day.riskOverall.uiLevel.displayText,
                dateText: day.displayDate,
                level: day.riskOverall.uiLevel
            )
        }
    }
}
