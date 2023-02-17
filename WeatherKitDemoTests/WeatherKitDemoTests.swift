import XCTest

final class WeatherKitDemoTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Swift does not support public extensions,
    // so those cannot be directly tested by XCTest.
    func testAppInfo() async throws {
        let appInfo = try! await AppInfo.create()
        // print("appInfo.author =", appInfo.author)
        XCTAssertEqual(appInfo.author, "Richard Mark Volkmann")
    }
}
