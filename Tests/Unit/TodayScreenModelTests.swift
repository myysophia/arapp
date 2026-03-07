import XCTest
@testable import ArApp

@MainActor
final class TodayScreenModelTests: XCTestCase {
    func testMockSuccessProducesSuccessState() async {
        let model = TodayScreenModel(dataMode: .mock, mockScenario: .success)

        await model.reload()

        guard case let .success(state) = model.contentState else {
            return XCTFail("期望进入成功态。")
        }

        XCTAssertEqual(state.summary.cityName, "上海")
        XCTAssertEqual(state.forecast.days.count, 3)
        XCTAssertFalse(state.adviceItems.isEmpty)
        XCTAssertTrue(state.source.active)
    }

    func testMockEmptyProducesEmptyState() async {
        let model = TodayScreenModel(dataMode: .mock, mockScenario: .empty)

        await model.reload()

        guard case let .empty(title, detail) = model.contentState else {
            return XCTFail("期望进入空态。")
        }

        XCTAssertFalse(title.isEmpty)
        XCTAssertFalse(detail.isEmpty)
    }

    func testClientTransportFailureProducesRetryableFailure() async {
        let model = TodayScreenModel(
            dataMode: .client,
            liveClientFactory: {
                throw APIClientError.transportFailed("offline")
            }
        )

        await model.reload()

        guard case let .failure(title, detail, retryable) = model.contentState else {
            return XCTFail("期望进入失败态。")
        }

        XCTAssertEqual(title, L10n.tr("common.client_unavailable"))
        XCTAssertTrue(detail.contains("offline"))
        XCTAssertTrue(retryable)
    }
}
