import XCTest
@testable import ArApp

@MainActor
final class MapScreenModelTests: XCTestCase {
    func testClientSuccessProducesSuccessState() async {
        let model = MapScreenModel(
            dataMode: .client,
            liveClientFactory: {
                MockPollenAPIClient.demo
            }
        )

        await model.reload()

        guard case let .success(state) = model.contentState else {
            return XCTFail("期望 client 模式进入成功态。")
        }

        XCTAssertFalse(state.mapPoints.isEmpty)
        XCTAssertFalse(state.searchItems.isEmpty)
        XCTAssertEqual(model.selectedPointID, state.mapPoints.first?.id)
    }

    func testClientTransportFailureProducesRetryableFailure() async {
        let model = MapScreenModel(
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
        let model = MapScreenModel(
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

    func testMockSuccessSelectsFirstPoint() async {
        let model = MapScreenModel(dataMode: .mock, mockScenario: .success)

        await model.reload()

        guard case let .success(state) = model.contentState else {
            return XCTFail("期望进入成功态。")
        }

        XCTAssertEqual(state.mapPoints.count, 3)
        XCTAssertEqual(model.selectedPointID, state.mapPoints.first?.id)
        XCTAssertEqual(state.selectedPoint(using: nil)?.id, state.mapPoints.first?.id)
    }

    func testSheetTogglesChangePresentationFlags() {
        let model = MapScreenModel()

        XCTAssertFalse(model.isSearchSheetPresented)
        XCTAssertFalse(model.isSourceSheetPresented)

        model.toggleSearchSheet()
        model.toggleSourceSheet()

        XCTAssertTrue(model.isSearchSheetPresented)
        XCTAssertTrue(model.isSourceSheetPresented)
    }

    func testMockFailureProducesRetryableFailure() async {
        let model = MapScreenModel(dataMode: .mock, mockScenario: .failure)

        await model.reload()

        guard case let .failure(title, detail, retryable) = model.contentState else {
            return XCTFail("期望进入失败态。")
        }

        XCTAssertFalse(title.isEmpty)
        XCTAssertFalse(detail.isEmpty)
        XCTAssertTrue(retryable)
    }
}
