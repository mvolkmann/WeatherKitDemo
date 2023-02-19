import XCTest

final class ScreenshotTests: XCTestCase {
    let waitSeconds: TimeInterval =
        45.0 // waiting for WeatherKit data to be returned

    // This method is called before the invocation of each test method.
    override func setUpWithError() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // It is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    // This method is called after the invocation of each test method.
    override func tearDownWithError() throws {}

    func testScreenshots() throws {
        try infoSheet()
        try currentScreen()
        try forecastScreen()
        try chartScreen()
        try heatMapScreen()
        try settingsSheet()
    }

    func chartScreen() throws {
        tapTabBarButton(label: "chart-tab", wait: waitSeconds)
        try textExists("drag-help", wait: waitSeconds)
        snapshot("4-chart")
    }

    func currentScreen() throws {
        tapTabBarButton(label: "current-tab", wait: waitSeconds)
        try textExists("condition-label", wait: waitSeconds)
        snapshot("2-current")
    }

    func forecastScreen() throws {
        tapTabBarButton(label: "forecast-tab", wait: waitSeconds)
        try textExists("day-time-label", wait: waitSeconds)
        snapshot("3-forecast")
    }

    func heatMapScreen() throws {
        tapTabBarButton(label: "heat-map-tab", wait: waitSeconds)
        try textExists("day-label-0", wait: waitSeconds)
        snapshot("5-heatmap")
    }

    func infoSheet() throws {
        tapButton(label: "info-button", wait: waitSeconds) // opens sheet
        try textExists("info-title", wait: waitSeconds)
        snapshot("1-info")
        /* Using swipeDown seems to not work.
         let element = Self.app.staticTexts["info-title"]
         XCTAssertTrue(element.exists)
         element.swipeDown()
         */
        tapButton(label: "dismiss-button")
    }

    func settingsSheet() throws {
        tapButton(label: "settings-button", wait: waitSeconds) // opens sheet
        try textExists("settings-title", wait: waitSeconds)
        snapshot("6-settings")
        /* Using swipeDown seems to not work.
         let element = Self.app.staticTexts["settings-title"]
         XCTAssertTrue(element.exists)
         element.swipeDown()
         */
        tapButton(label: "dismiss-button")
    }
}
