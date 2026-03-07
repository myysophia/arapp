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
                "Mock"
            case .client:
                "Client"
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
                "成功"
            case .failure:
                "失败"
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
                detail: error.errorDescription ?? "地图数据加载失败。",
                retryable: error.isRetryable
            )
        } catch let error as APIClientError {
            contentState = .failure(
                title: "Client 模式暂不可用",
                detail: error.errorDescription ?? "地图接口请求失败。",
                retryable: true
            )
        } catch {
            contentState = .failure(
                title: "地图数据加载失败",
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
                title: "地图数据暂时不可用",
                detail: "这是 Mock 失败态，用于验证热力层失败说明卡和重试路径。",
                retryable: true
            )
        }
    }

    private func makeClientState(using client: any PollenAPIClienting) async throws -> ContentState {
        async let suggestionsEnvelope = client.fetchLocationSuggestions(query: "上海", lang: Self.language)
        async let summaryEnvelope = client.fetchSummary(Self.summaryQuery)
        async let sourceMetaEnvelope = client.fetchSourceMeta(lang: Self.language)

        let suggestions = try await suggestionsEnvelope.payload
        let summary = try await summaryEnvelope.payload
        let sourceMeta = try await sourceMetaEnvelope.payload

        let selectedLocation = suggestions.first ?? Self.defaultLocation
        let source = sourceMeta.first(where: \.active) ?? sourceMeta.first ?? .placeholder(for: summary.source)
        let mapPoints = Self.makeClientPoints(from: summary)
        let state = MapScreenState(
            searchPlaceholder: "搜索城市或区域",
            selectedLocation: selectedLocation,
            source: source,
            mapPoints: mapPoints,
            searchItems: Self.makeSearchItems(from: suggestions)
        )
        selectedPointID = mapPoints.first?.id
        return .success(state)
    }

    private static let language = "zh-Hans"

    private static let summaryQuery = SummaryQuery(
        lat: 31.2304,
        lng: 121.4737,
        lang: language,
        unit: .metric
    )

    private static let defaultLocation = LocationSuggestion(
        id: UUID(uuidString: "6f222b19-b7c9-4baa-8661-2dd6905ddf00") ?? UUID(),
        name: "上海",
        countryCode: "CN",
        admin1: "上海市",
        lat: 31.2304,
        lng: 121.4737
    )

    private static let demoState = MapScreenState(
        searchPlaceholder: "搜索城市或区域",
        selectedLocation: defaultLocation,
        source: SourceMeta(
            id: UUID(uuidString: "8d11c444-0dd7-492d-a185-774bcc66a6f7") ?? UUID(),
            providerName: "Primary Model Provider",
            source: .model,
            coverageNote: "中国大陆主要城市模型覆盖",
            licenseNote: "仅用于风险参考，不代表采样监测",
            active: true,
            updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now
        ),
        mapPoints: [
            MapPointState(
                id: UUID(uuidString: "42106b0a-6200-44b0-9fbe-f0a4cce30001") ?? UUID(),
                locationName: "浦东新区",
                summary: PollenSummary(
                    id: "map-summary-pudong",
                    cityName: "浦东新区",
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
                locationName: "静安区",
                summary: PollenSummary(
                    id: "map-summary-jingan",
                    cityName: "静安区",
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
                locationName: "徐汇区",
                summary: PollenSummary(
                    id: "map-summary-xuhui",
                    cityName: "徐汇区",
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
            SearchSheetItem(id: "shanghai", title: "上海", subtitle: "中国 · 上海市", badge: "当前"),
            SearchSheetItem(id: "hangzhou", title: "杭州", subtitle: "中国 · 浙江省", badge: "可切换"),
            SearchSheetItem(id: "suzhou", title: "苏州", subtitle: "中国 · 江苏省", badge: "可切换")
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
                locationName: "相邻区域 A",
                summary: PollenSummary(
                    id: summary.id + "-a",
                    cityName: "相邻区域 A",
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
                locationName: "相邻区域 B",
                summary: PollenSummary(
                    id: summary.id + "-b",
                    cityName: "相邻区域 B",
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
                badge: suggestion.name == defaultLocation.name ? "当前" : "建议"
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
            "Client 模式未配置"
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
            "缺少 ARAPP_EDGE_BASE_URL，当前无法真正发起地图页请求。"
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

extension SourceMeta {
    static func placeholder(for source: PollenSourceType) -> SourceMeta {
        SourceMeta(
            id: UUID(),
            providerName: "未配置来源说明",
            source: source,
            coverageNote: "当前演示路径未返回来源说明，页面使用占位信息保证弹层和抽屉文案完整。",
            licenseNote: "风险参考，非医疗建议。",
            active: true,
            updatedAt: .now
        )
    }
}

extension PollenSummary {
    var mapRiskTitle: String {
        switch riskOverall {
        case .none:
            "风险很低"
        case .veryLow, .low:
            "低风险"
        case .moderate:
            "中等风险"
        case .high:
            "高风险"
        case .veryHigh:
            "极高风险"
        }
    }

    var mapRiskBadgeColor: Color { RiskPalette.color(for: riskOverall.uiLevel) }
    var mapRiskBadgeForeground: Color { RiskPalette.labelColor(for: riskOverall.uiLevel) }

    var updatedAtText: String {
        "更新于 \(updatedAt.relativeText)"
    }

    var sourceTag: String {
        source.displayText
    }
}

extension PollenRiskLevel {
    var uiLevel: AppRiskLevel {
        AppRiskLevel(rawValue: rawValue) ?? .none
    }
}

extension AppRiskLevel {
    var displayText: String {
        switch self {
        case .none:
            "极低"
        case .veryLow:
            "很低"
        case .low:
            "较低"
        case .moderate:
            "中等"
        case .high:
            "较高"
        case .veryHigh:
            "极高"
        }
    }
}

extension PollenSourceType {
    var displayText: String {
        switch self {
        case .model:
            "模型点"
        case .station:
            "监测站"
        case .vendor:
            "合作源"
        }
    }
}

extension Date {
    var relativeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_Hans")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
