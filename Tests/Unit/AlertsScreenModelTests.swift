import XCTest
@testable import ArApp

@MainActor
final class AlertsScreenModelTests: XCTestCase {
    func testClientSuccessProducesSuccessState() async {
        let model = AlertsScreenModel(
            dataMode: .client,
            liveClientFactory: {
                MockPollenAPIClient.demo
            }
        )

        await model.reload()

        guard case let .success(state) = model.contentState else {
            return XCTFail("期望 client 模式进入成功态。")
        }

        XCTAssertEqual(state.locationName, L10n.tr("common.default_city"))
        XCTAssertEqual(state.subscription.thresholdLevel, .moderate)
        XCTAssertTrue(state.subscription.enabled)
    }

    func testMockConfiguredProducesSuccessState() async {
        let model = AlertsScreenModel(dataMode: .mock, mockScenario: .configured)

        await model.reload()

        guard case let .success(state) = model.contentState else {
            return XCTFail("期望进入成功态。")
        }

        XCTAssertEqual(state.locationName, L10n.tr("common.default_city"))
        XCTAssertEqual(state.subscription.thresholdLevel, .moderate)
        XCTAssertEqual(state.history.count, 2)
    }

    func testUpdateEnabledAndThresholdMutatesSuccessState() async {
        let model = AlertsScreenModel(dataMode: .mock, mockScenario: .configured)
        await model.reload()

        await model.updateEnabled(false)
        await model.updateThreshold(.veryHigh)

        guard case let .success(state) = model.contentState else {
            return XCTFail("期望保留成功态。")
        }

        XCTAssertFalse(state.subscription.enabled)
        XCTAssertEqual(state.subscription.thresholdLevel, .veryHigh)
    }

    func testMockEmptyProducesEmptyState() async {
        let model = AlertsScreenModel(dataMode: .mock, mockScenario: .empty)

        await model.reload()

        guard case let .empty(title, detail) = model.contentState else {
            return XCTFail("期望进入空态。")
        }

        XCTAssertFalse(title.isEmpty)
        XCTAssertFalse(detail.isEmpty)
    }

    func testClientUpdateEnabledAndThresholdPersistsSubscription() async {
        let model = AlertsScreenModel(
            dataMode: .client,
            liveClientFactory: {
                MockPollenAPIClient.demo
            }
        )
        await model.reload()

        await model.updateEnabled(false)
        await model.updateThreshold(.veryHigh)

        guard case let .success(state) = model.contentState else {
            return XCTFail("期望 client 更新后保留成功态。")
        }

        XCTAssertFalse(state.subscription.enabled)
        XCTAssertEqual(state.subscription.thresholdLevel, .veryHigh)
    }

    func testClientTransportFailureProducesRetryableFailure() async {
        let model = AlertsScreenModel(
            dataMode: .client,
            liveClientFactory: {
                throw APIClientError.transportFailed("offline")
            }
        )

        await model.reload()

        guard case let .failure(_, detail, retryable) = model.contentState else {
            return XCTFail("期望进入失败态。")
        }

        XCTAssertTrue(detail.contains("offline"))
        XCTAssertTrue(retryable)
    }

    func testClientNonRetryableStatusFailureProducesNonRetryableState() async {
        let model = AlertsScreenModel(
            dataMode: .client,
            liveClientFactory: {
                throw APIClientError.unexpectedStatus(
                    code: 400,
                    message: "bad request",
                    retryable: false
                )
            }
        )

        await model.reload()

        guard case let .failure(_, detail, retryable) = model.contentState else {
            return XCTFail("期望进入失败态。")
        }

        XCTAssertTrue(detail.contains("400"))
        XCTAssertFalse(retryable)
    }

    func testClientPersistFailureProducesRetryableFailure() async {
        let flakyClient = FlakyAlertUpsertClient()
        let model = AlertsScreenModel(
            dataMode: .client,
            liveClientFactory: {
                flakyClient
            }
        )
        await model.reload()

        await model.updateEnabled(false)

        guard case let .failure(_, detail, retryable) = model.contentState else {
            return XCTFail("期望写回失败后进入失败态。")
        }

        XCTAssertTrue(detail.contains("timeout"))
        XCTAssertTrue(retryable)
    }
}

private actor UpsertCallCounter {
    private var value = 0

    func next() -> Int {
        defer { value += 1 }
        return value
    }
}

private final class FlakyAlertUpsertClient: PollenAPIClienting, @unchecked Sendable {
    private let base = MockPollenAPIClient.demo
    private let counter = UpsertCallCounter()

    func fetchSummary(_ query: SummaryQuery) async throws -> APIEnvelope<PollenSummary> {
        try await base.fetchSummary(query)
    }

    func fetchForecast(_ query: ForecastQuery) async throws -> APIEnvelope<PollenForecast> {
        try await base.fetchForecast(query)
    }

    func fetchSourceMeta(lang: String?) async throws -> APIEnvelope<[SourceMeta]> {
        try await base.fetchSourceMeta(lang: lang)
    }

    func fetchLocationSuggestions(query: String, lang: String?) async throws -> APIEnvelope<[LocationSuggestion]> {
        try await base.fetchLocationSuggestions(query: query, lang: lang)
    }

    func upsertAlertSubscription(_ request: AlertSubscriptionRequest) async throws -> APIEnvelope<AlertSubscription> {
        let callIndex = await counter.next()
        if callIndex == 0 {
            return try await base.upsertAlertSubscription(request)
        }
        throw APIClientError.transportFailed("timeout")
    }
}
