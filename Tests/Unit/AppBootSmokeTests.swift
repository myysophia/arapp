import XCTest
@testable import ArApp

final class AppBootSmokeTests: XCTestCase {
    func testAppTabCountMatchesSpec() {
        XCTAssertEqual(AppTab.allCases.count, 4)
    }
}
