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
        tapTabBarButton(label: "Chart")
        // Only passes with this wait.
        try textExists(
            "Drag across the chart to see hourly details.",
            wait: waitSeconds
        )
        try textExists("Temperature")
    }

    func currentScreen() throws {
        tapTabBarButton(label: "Current")
        // Only passes with this wait.
        try textExists("Condition", wait: waitSeconds)
        try textExists("Temperature")
        try textExists("Feels Like")
        try textExists("Humidity")
        try textExists("Winds")
        // "Favorite Locations" is only present if
        // at least one location has been favorited.
    }

    func forecastScreen() throws {
        tapTabBarButton(label: "Forecast")
        // Only passes with this wait.
        try textExists("Day/Time", wait: waitSeconds)
        try textExists("Temp")
        try textExists("Wind")
        try textExists("Prec")
    }

    func heatMapScreen() throws {
        tapTabBarButton(label: "Heat Map")
        // Only passes with this wait.
        try textExists("Today", wait: waitSeconds)
    }
}
