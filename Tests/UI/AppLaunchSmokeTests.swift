import XCTest

final class AppLaunchSmokeTests: XCTestCase {
    func testCanSkipOnboardingAndSwitchTabs() {
        let app = XCUIApplication()
        app.launch()

        let skipButton = waitForFirstExistingElement(in: app.buttons, labels: ["Skip", "稍后"], timeout: 5)
        XCTAssertTrue(skipButton.exists, "启动后应能看到 Onboarding 的稍后按钮。")
        skipButton.tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "跳过 Onboarding 后应出现底部标签栏。")

        let tabExpectations: [[String]] = [
            ["Today", "今日"],
            ["Map", "地图"],
            ["Alerts", "提醒"],
            ["My", "我的"]
        ]

        for labels in tabExpectations {
            let button = waitForFirstExistingElement(in: tabBar.buttons, labels: labels, timeout: 2)
            XCTAssertTrue(button.exists, "标签不存在：\(labels)")
            button.tap()
        }
    }

    private func waitForFirstExistingElement(in query: XCUIElementQuery, labels: [String], timeout: TimeInterval) -> XCUIElement {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            for label in labels {
                let element = query[label]
                if element.exists {
                    return element
                }
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }

        return query[labels[0]]
    }
}
