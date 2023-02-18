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
        try infoSheet()
        try currentScreen()
        try forecastScreen()
        try chartScreen()
        try heatMapScreen()
        try settingsSheet()
    }

    func chartScreen() throws {
        tapTabBarButton(label: "chart-tab")
        try textExists("drag-help", wait: waitSeconds)
        snapshot("4-chart")
    }

    func currentScreen() throws {
        tapTabBarButton(label: "current-tab")
        try textExists("condition-label", wait: waitSeconds)
        snapshot("2-current")
    }

    func forecastScreen() throws {
        tapTabBarButton(label: "forecast-tab")
        try textExists("day-time-label", wait: waitSeconds)
        snapshot("3-forecast")
    }

    func heatMapScreen() throws {
        tapTabBarButton(label: "heat-map-tab")
        try textExists("day-label-0", wait: waitSeconds)
        snapshot("5-heatmap")
    }

    func infoSheet() throws {
        tapButton(label: "info-button") // opens sheet
        try textExists("info-title", wait: waitSeconds)
        snapshot("1-info")
        tapButton(label: "dismiss-button")
    }

    func settingsSheet() throws {
        tapButton(label: "settings-button") // opens sheet
        snapshot("5-settings")
        tapButton(label: "dismiss-button")
    }
}
