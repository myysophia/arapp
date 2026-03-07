import XCTest
@testable import ArApp

@MainActor
final class MapScreenModelTests: XCTestCase {
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
