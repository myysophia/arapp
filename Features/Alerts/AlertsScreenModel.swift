import Foundation
import Observation

@MainActor
@Observable
final class AlertsScreenModel {
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
        case configured
        case empty
        case failure

        var id: String { rawValue }

        var title: String {
            switch self {
            case .configured:
                "已配置"
            case .empty:
                "空态"
            case .failure:
                "失败"
            }
        }
    }

    enum ContentState {
        case loading
        case success(AlertsScreenState)
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
        mockScenario: MockScenario = .configured,
        mockClient: MockPollenAPIClient = .demo,
        liveClientFactory: @escaping @Sendable () throws -> any PollenAPIClienting = {
            let environment = ProcessInfo.processInfo.environment
            guard
                let rawBaseURL = environment["ARAPP_EDGE_BASE_URL"],
                let baseURL = URL(string: rawBaseURL)
            else {
                throw AlertsScreenModelError.missingBaseURL
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
        } catch let error as AlertsScreenModelError {
            contentState = .failure(
                title: error.title,
                detail: error.errorDescription ?? "提醒页面加载失败。",
                retryable: error.isRetryable
            )
        } catch let error as APIClientError {
            contentState = .failure(
                title: "Client 模式暂不可用",
                detail: error.errorDescription ?? "提醒接口请求失败。",
                retryable: true
            )
        } catch {
            contentState = .failure(
                title: "提醒页面加载失败",
                detail: error.localizedDescription,
                retryable: true
            )
        }
    }

    func updateEnabled(_ enabled: Bool) {
        guard case var .success(state) = contentState else { return }
        state.subscription = state.subscription.withEnabled(enabled)
        contentState = .success(state)
    }

    func updateThreshold(_ level: AppRiskLevel) {
        guard case var .success(state) = contentState else { return }
        state.subscription = state.subscription.withThreshold(level)
        contentState = .success(state)
    }

    private func makeMockState() async throws -> ContentState {
        switch mockScenario {
        case .configured:
            return .success(.demo)
        case .empty:
            return .empty(
                title: "当前还没有提醒配置",
                detail: "这是 Mock 空态，用于验证用户尚未选择关注城市或还未开启提醒时的展示。"
            )
        case .failure:
            return .failure(
                title: "提醒配置读取失败",
                detail: "这是 Mock 失败态，用于验证重试、错误提示与降级展示。",
                retryable: true
            )
        }
    }

    private func makeClientState(using client: any PollenAPIClienting) async throws -> ContentState {
        let subscription = try await client.upsertAlertSubscription(Self.defaultRequest).payload
        return .success(
            AlertsScreenState(
                auth: .demoSignedIn,
                locationName: Self.defaultLocationName,
                subscription: subscription,
                history: Self.clientHistory,
                notificationPermission: .granted
            )
        )
    }

    private static let defaultLocationName = "上海"

    private static let defaultRequest = AlertSubscriptionRequest(
        userID: UUID(uuidString: "66a5660a-5233-4dc5-9f4e-e4df7c610001"),
        locationID: UUID(uuidString: "66a5660a-5233-4dc5-9f4e-e4df7c610002") ?? UUID(),
        thresholdLevel: .moderate,
        enabled: true,
        quietHours: QuietHours(enabled: true, start: "22:00", end: "07:00")
    )

    private static let clientHistory: [AlertHistoryItem] = [
        AlertHistoryItem(id: UUID(), date: "2026-03-06T07:00:00Z", riskLevel: .high, title: "Client 回放：草类花粉升至 4 级"),
        AlertHistoryItem(id: UUID(), date: "2026-03-05T07:00:00Z", riskLevel: .moderate, title: "Client 回放：总体风险达到 3 级")
    ]
}

private enum AlertsScreenModelError: LocalizedError {
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
            "缺少 ARAPP_EDGE_BASE_URL，当前无法真正发起提醒页面请求。"
        }
    }
}
