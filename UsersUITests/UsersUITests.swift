import NetworkLibrary
import XCTest

final class UsersUITests: XCTestCase {

    @MainActor
    func testGetUsersWithError() throws {
        let mapper = [
            NetworkMockData(api: "/2.2/users", filename: "error", bundlePath: Bundle(for: UsersUITests.self).bundlePath)
        ]

        let app = XCUIApplication()
        app.launchArguments = ["mock"]
        app.launchEnvironment = ["mapper": mapper.asString]
        app.launch()

        XCTAssertTrue(app.staticTexts["network.error"].waitForExistence(timeout: 10))
    }
}
