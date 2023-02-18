import XCTest

final class ScreenshotTests: XCTestCase {
    let waitSeconds = 100.0 // waiting for WeatherKit data to be returned

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
        try forecastScreen()
        try chartScreen()
        try heatMapScreen()
        try currentScreen()
    }

    func chartScreen() throws {
        tapTabBarButton(label: "chart-tab")
        try textExists("drag-help", wait: waitSeconds)
        snapshot("3-chart")
    }

    func currentScreen() throws {
        tapTabBarButton(label: "current-tab")
        try textExists("condition-label", wait: waitSeconds)
        snapshot("1-current")
    }

    func forecastScreen() throws {
        tapTabBarButton(label: "forecast-tab")
        try textExists("day-time-label", wait: waitSeconds)
        snapshot("2-forecast")
    }

    func heatMapScreen() throws {
        tapTabBarButton(label: "heat-map-tab")
        try textExists("day-label", wait: waitSeconds)
        snapshot("4-heatmap")
    }
}
