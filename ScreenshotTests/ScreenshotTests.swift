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
        tapTabBarButton(label: "Chart")
        try textExists(
            "Drag across the chart to see hourly details.",
            wait: waitSeconds
        )
        snapshot("3-chart")
    }

    func currentScreen() throws {
        tapTabBarButton(label: "Current")
        try textExists("Condition", wait: waitSeconds)
        snapshot("1-current")
    }

    func forecastScreen() throws {
        tapTabBarButton(label: "Forecast")
        try textExists("Day/Time", wait: waitSeconds)
        snapshot("2-forecast")
    }

    func heatMapScreen() throws {
        tapTabBarButton(label: "Heat Map")
        try textExists("Today", wait: waitSeconds)
        snapshot("4-heatmap")
    }
}
