import XCTest

final class WeatherKitDemoUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        XCUIApplication().launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        try textExists("Feather Weather")
    }

    func testChartScreen() throws {
        tapTabBarButton(label: "Chart")
        // Only passes with this wait.
        try textExists(
            "Drag across the chart to see hourly details.",
            wait: 100
        )
        try textExists("Temperature")
    }

    func testCurrent() throws {
        tapTabBarButton(label: "Current")
        // Only passes with this wait.
        try textExists("Condition", wait: 1000)
        try textExists("Temperature")
        try textExists("Feels Like")
        try textExists("Humidity")
        try textExists("Winds")
        // "Favorite Locations" is only present if
        // at least one location has been favorited.
    }

    func testForecastScreen() throws {
        tapTabBarButton(label: "Forecast")
        // Only passes with this wait.
        // try textExists("Day/Time", wait: 100)
        try textExists("Day/Time", wait: 1000)
        try textExists("Temp")
        try textExists("Wind")
        try textExists("Prec")
    }

    func testHeatMapScreen() throws {
        tapTabBarButton(label: "Heat Map")
        // Only passes with this wait.
        try textExists("Today", wait: 100)
    }
}
