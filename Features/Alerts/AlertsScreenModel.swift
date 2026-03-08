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
                L10n.tr("common.mode.mock")
            case .client:
                L10n.tr("common.mode.client")
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
                L10n.tr("alerts.scenario.configured")
            case .empty:
                L10n.tr("common.scenario.empty")
            case .failure:
                L10n.tr("common.scenario.failure")
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
        dataMode: DataMode? = nil,
        mockScenario: MockScenario = .configured,
        mockClient: MockPollenAPIClient = .demo,
        environment: AppEnvironment = .current,
        liveClientFactory: (@Sendable () throws -> any PollenAPIClienting)? = nil
    ) {
        self.dataMode = dataMode ?? (environment.prefersLiveServices ? .client : .mock)
        self.mockScenario = mockScenario
        self.contentState = .loading
        self.mockClient = mockClient
        let resolvedFactory = LivePollenClientFactory(environment: environment)
        self.liveClientFactory = liveClientFactory ?? {
            try resolvedFactory.makeClient()
        }
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
        } catch {
            contentState = failureState(for: error)
        }
    }

    func updateEnabled(_ enabled: Bool) async {
        guard case var .success(state) = contentState else { return }
        state.subscription = state.subscription.withEnabled(enabled)
        contentState = .success(state)

        guard dataMode == .client else { return }
        await persistSubscription(state.subscription)
    }

    func updateThreshold(_ level: AppRiskLevel) async {
        guard case var .success(state) = contentState else { return }
        state.subscription = state.subscription.withThreshold(level)
        contentState = .success(state)

        guard dataMode == .client else { return }
        await persistSubscription(state.subscription)
    }

    private func makeMockState() async throws -> ContentState {
        switch mockScenario {
        case .configured:
            return .success(.demo)
        case .empty:
            return .empty(
                title: L10n.tr("alerts.empty.title"),
                detail: L10n.tr("alerts.empty.detail")
            )
        case .failure:
            return .failure(
                title: L10n.tr("alerts.mock_failure.title"),
                detail: L10n.tr("alerts.mock_failure.detail"),
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

    private static let defaultLocationName = L10n.tr("common.default_city")

    private static let defaultRequest = AlertSubscriptionRequest(
        userID: UUID(uuidString: "66a5660a-5233-4dc5-9f4e-e4df7c610001"),
        locationID: UUID(uuidString: "66a5660a-5233-4dc5-9f4e-e4df7c610002") ?? UUID(),
        thresholdLevel: .moderate,
        enabled: true,
        quietHours: QuietHours(enabled: true, start: "22:00", end: "07:00")
    )

    private static let clientHistory: [AlertHistoryItem] = [
        AlertHistoryItem(id: UUID(), date: "2026-03-06T07:00:00Z", riskLevel: .high, title: L10n.tr("alerts.history.client.1")),
        AlertHistoryItem(id: UUID(), date: "2026-03-05T07:00:00Z", riskLevel: .moderate, title: L10n.tr("alerts.history.client.2"))
    ]

    private func persistSubscription(_ subscription: AlertSubscription) async {
        let request = AlertSubscriptionRequest(
            userID: subscription.userID,
            locationID: subscription.locationID,
            thresholdLevel: subscription.thresholdLevel,
            enabled: subscription.enabled,
            quietHours: subscription.quietHours
        )

        do {
            let client = try liveClientFactory()
            let updatedSubscription = try await client.upsertAlertSubscription(request).payload

            guard case var .success(state) = contentState else { return }
            state.subscription = updatedSubscription
            contentState = .success(state)
        } catch {
            contentState = failureState(for: error)
        }
    }

    private func failureState(for error: Error) -> ContentState {
        if let configError = error as? LivePollenClientFactoryError {
            return .failure(
                title: L10n.tr("common.client_not_configured"),
                detail: configError.errorDescription ?? L10n.tr("alerts.error.missing_base_url"),
                retryable: false
            )
        }

        if let apiError = error as? APIClientError {
            return .failure(
                title: L10n.tr("common.client_unavailable"),
                detail: apiError.errorDescription ?? L10n.tr("alerts.error.client_request_failed"),
                retryable: apiError.isRetryable
            )
        }

        return .failure(
            title: L10n.tr("alerts.error.screen_failed"),
            detail: error.localizedDescription,
            retryable: true
        )
    }
}
