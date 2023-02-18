import XCTest

final class WeatherKitDemoUITests: XCTestCase {
    let waitSeconds = 100.0

    // This method is called before the invocation of each test method.
    override func setUpWithError() throws {
        XCUIApplication().launch()

        // It is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    // This method is called after the invocation of each test method.
    override func tearDownWithError() throws {}

    func testApp() throws {
        try titleTest()
        try forecastScreen()
        try chartScreen()
        try heatMapScreen()
        try currentScreen()
    }

    func titleTest() throws {
        try textExists("Feather Weather")
    }

    func chartScreen() throws {
        tapTabBarButton(label: "chart-tab")
        // Only passes with this wait.
        try textExists("drag-help", wait: waitSeconds)
        try textExists("temperature-label")
    }

    func currentScreen() throws {
        tapTabBarButton(label: "current-tab")
        // Only passes with this wait.
        try textExists("condition-label", wait: waitSeconds)
        try textExists("temperature-label")
        try textExists("feels-like-label")
        try textExists("humidity-label")
        try textExists("winds-label")
        // "Favorite Locations" is only present if
        // at least one location has been favorited.
    }

    func forecastScreen() throws {
        tapTabBarButton(label: "forecast-tab")
        // Only passes with this wait.
        try textExists("day-time-label", wait: waitSeconds)
        try textExists("temperature-label")
        try textExists("wind-label")
        try textExists("precipitation-label")
    }

    func heatMapScreen() throws {
        tapTabBarButton(label: "heat-map-tab")
        // Only passes with this wait.
        try textExists("day-label", wait: waitSeconds)
    }
}
