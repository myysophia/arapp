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
                "Mock"
            case .client:
                "Client"
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
                "成功"
            case .empty:
                "空态"
            case .failure:
                "失败"
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
                detail: error.errorDescription ?? "加载 Today 页面失败。",
                retryable: error.isRetryable
            )
        } catch let error as APIClientError {
            contentState = .failure(
                title: "Client 模式暂不可用",
                detail: error.errorDescription ?? "网络请求失败。",
                retryable: true
            )
        } catch {
            contentState = .failure(
                title: "Today 页面加载失败",
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
                title: "当前没有可展示的数据",
                detail: "这是 Mock 空态，用于验证页面在无结果时的展示与操作提示。"
            )
        case .failure:
            return .failure(
                title: "Mock 数据加载失败",
                detail: "这是 Mock 失败态，用于验证重试按钮、错误提示和页面韧性。",
                retryable: true
            )
        }
    }

    private func makeClientState(using client: any PollenAPIClienting) async throws -> ContentState {
        let screenState = try await loadScreenState(using: client)
        guard !screenState.forecast.days.isEmpty else {
            return .empty(
                title: "服务端暂无预测数据",
                detail: "当前接口返回的 forecast.days 为空，页面已切换到空态。"
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

    private static let language = "zh-Hans"

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
                TodayAdviceItem(title: "按常规活动安排出行", detail: "当前总体风险较低，优先保持日常节奏即可。", systemImage: "figure.walk"),
                TodayAdviceItem(title: "保留基础观察", detail: "若你对某类花粉特别敏感，建议继续关注明天趋势。", systemImage: "eye")
            ]
        case .moderate:
            [
                TodayAdviceItem(title: "缩短高暴露时段外出", detail: "中午到傍晚花粉水平更容易抬升。", systemImage: "sun.max"),
                TodayAdviceItem(title: "回家后及时清洁", detail: "更换外套并清洗面部，减少花粉残留。", systemImage: "drop")
            ]
        case .high, .veryHigh:
            [
                TodayAdviceItem(title: "减少长时间户外暴露", detail: "今天更适合以室内活动为主。", systemImage: "house"),
                TodayAdviceItem(title: "外出提前做个人防护", detail: "口罩、眼镜和回家后的清洁会更有帮助。", systemImage: "shield.lefthalf.filled"),
                TodayAdviceItem(title: "开启阈值提醒", detail: "让明天和后天的高风险变化提前通知你。", systemImage: "bell.badge")
            ]
        }
    }
}

private enum TodayScreenModelError: LocalizedError {
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
            "缺少 ARAPP_EDGE_BASE_URL，当前无法真正发起 Edge Functions 请求。"
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

    var riskDescription: String {
        switch riskOverall {
        case .none:
            "今天的空气花粉影响较弱，日常活动基本不受影响。"
        case .veryLow, .low:
            "今天可以正常外出，但对花粉敏感人群仍建议保持观察。"
        case .moderate:
            "今天花粉水平正在抬升，建议缩短长时间户外停留。"
        case .high:
            "今天不建议长时间暴露在户外花粉环境中。"
        case .veryHigh:
            "今天建议尽量减少外出，并提前准备个人防护。"
        }
    }

    var riskBadgeText: String { uiLevel.displayText }
    var riskBadgeColor: Color { RiskPalette.color(for: uiLevel) }
    var riskBadgeForeground: Color { RiskPalette.labelColor(for: uiLevel) }

    var updatedAtText: String {
        "更新于 \(updatedAt.relativeText)"
    }

    var confidenceText: String {
        "\(Int(confidence * 100))%"
    }

    var sourceTag: String {
        source.displayText
    }

    var heroMetrics: [RiskHeroMetric] {
        var items = [
            RiskHeroMetric(
                title: "可信度",
                value: confidenceText,
                systemImage: "shield.lefthalf.filled"
            )
        ]

        if isStale {
            items.append(
                RiskHeroMetric(
                    title: "状态",
                    value: "更新较早",
                    systemImage: "clock.arrow.circlepath"
                )
            )
        } else {
            items.append(
                RiskHeroMetric(
                    title: "模型点",
                    value: sourceTag,
                    systemImage: "waveform.path.ecg"
                )
            )
        }

        return items
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

    var progress: CGFloat {
        CGFloat(rawValue) / CGFloat(AppRiskLevel.veryHigh.rawValue)
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

extension ForecastPoint {
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans")
        formatter.dateFormat = "MM/dd"
        guard let parsed = ISO8601DateFormatter().date(from: date + "T00:00:00Z") else {
            return date
        }
        return formatter.string(from: parsed)
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

extension SourceMeta {
    static func placeholder(for source: PollenSourceType) -> SourceMeta {
        SourceMeta(
            id: UUID(),
            providerName: "未配置来源说明",
            source: source,
            coverageNote: "当前演示路径未返回来源说明，页面使用占位信息保证布局完整。",
            licenseNote: "风险参考，非医疗建议。",
            active: true,
            updatedAt: .now
        )
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
