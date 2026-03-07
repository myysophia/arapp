import XCTest
@testable import ArApp

@MainActor
final class AlertsScreenModelTests: XCTestCase {
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

        model.updateEnabled(false)
        model.updateThreshold(.veryHigh)

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
}
