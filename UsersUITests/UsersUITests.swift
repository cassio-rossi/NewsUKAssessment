import NetworkLibrary
import XCTest

// swiftlint:disable empty_count
final class UsersUITests: XCTestCase {

    @MainActor
    func testGetUsersWithError() throws {
        let mapper = [
            NetworkMockData(api: "/users", filename: "error", bundlePath: Bundle(for: UsersUITests.self).bundlePath)
        ]

        let app = XCUIApplication()
        app.launchArguments = ["mock"]
        app.launchEnvironment = ["mapper": mapper.asString]
        app.launch()

        XCTAssertTrue(app.staticTexts["network.error"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testUsersListAndFollowFunctionality() throws {
        // Setup mock data
        let mapper = [
            NetworkMockData(api: "/2.2/users", filename: "users", bundlePath: Bundle(for: UsersUITests.self).bundlePath)
        ]

        let app = XCUIApplication()
        app.launchArguments = ["mock"]
        app.launchEnvironment = [
            "mapper": mapper.asString,
            "UI_TEST_SUITE": "test.follow.functionality.\(UUID().uuidString)"
        ]
        app.launch()

        // Wait for collection view to load
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 10), "Collection view should exist")

        // Verify navigation title
        XCTAssertTrue(app.navigationBars["Users"].exists, "Navigation bar with 'Users' title should exist")

        // Get the cells
        let cells = collectionView.cells
        XCTAssertTrue(cells.count >= 2, "Should have at least 2 user cells")

        // Test first cell elements
        let firstCell = cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First cell should exist")

        // Verify cell contains expected elements
        XCTAssertTrue(firstCell.images.count > 0, "Cell should contain profile image")
        XCTAssertTrue(firstCell.staticTexts.count > 0, "Cell should contain text labels (name, location, badges)")
        XCTAssertTrue(firstCell.buttons.count > 0, "Cell should contain follow button")

        // Get follow buttons
        let firstFollowButton = firstCell.buttons["Follow"]
        let secondCell = cells.element(boundBy: 1)
        let secondFollowButton = secondCell.buttons["Follow"]

        // Verify initial state - both buttons should show "Follow"
        XCTAssertTrue(firstFollowButton.exists, "First user should have 'Follow' button")
        XCTAssertTrue(secondFollowButton.exists, "Second user should have 'Follow' button")

        // Test 1: Follow first user
        firstFollowButton.tap()
        let firstFollowingButton = firstCell.buttons["Following"]
        XCTAssertTrue(firstFollowingButton.waitForExistence(timeout: 2), "First user button should change to 'Following'")

        // Test 2: Follow second user
        secondFollowButton.tap()
        let secondFollowingButton = secondCell.buttons["Following"]
        XCTAssertTrue(secondFollowingButton.waitForExistence(timeout: 2), "Second user button should change to 'Following'")

        // Verify both are still following
        XCTAssertTrue(firstCell.buttons["Following"].exists, "First user should still be 'Following'")
        XCTAssertTrue(secondCell.buttons["Following"].exists, "Second user should still be 'Following'")

        // Test 3: Unfollow first user
        firstFollowingButton.tap()
        let firstFollowButtonAgain = firstCell.buttons["Follow"]
        XCTAssertTrue(firstFollowButtonAgain.waitForExistence(timeout: 2), "First user button should change back to 'Follow'")

        // Verify second user is still following
        XCTAssertTrue(secondCell.buttons["Following"].exists, "Second user should still be 'Following'")

        // Test 4: Verify persistence by scrolling (triggers cell reuse)
        if collectionView.isHittable {
            collectionView.swipeUp()
            collectionView.swipeDown()
        }

        // After scrolling, second user should still be following
        XCTAssertTrue(secondCell.buttons["Following"].exists, "Second user should persist 'Following' state after scroll")
        XCTAssertTrue(firstCell.buttons["Follow"].exists, "First user should persist 'Follow' state after scroll")
    }

    @MainActor
    func testUserCellElements() throws {
        // Setup mock data
        let mapper = [
            NetworkMockData(api: "/2.2/users", filename: "users", bundlePath: Bundle(for: UsersUITests.self).bundlePath)
        ]

        let app = XCUIApplication()
        app.launchArguments = ["mock"]
        app.launchEnvironment = [
            "mapper": mapper.asString,
            "UI_TEST_SUITE": "test.cell.elements.\(UUID().uuidString)"
        ]
        app.launch()

        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 10))

        let firstCell = collectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)

        // Verify specific elements exist in the cell
        // Profile image
        XCTAssertTrue(firstCell.images.count > 0, "Cell should have profile image")

        // Name label (should be visible)
        let cellLabels = firstCell.staticTexts
        XCTAssertTrue(cellLabels.count > 0, "Cell should have text labels")

        // Follow button
        let followButton = firstCell.buttons.element(boundBy: 0)
        XCTAssertTrue(followButton.exists, "Cell should have follow button")
        XCTAssertTrue(followButton.label == "Follow" || followButton.label == "Following",
                     "Follow button should have correct label")

        // Verify reputation badge exists (checking for numeric text)
        let hasReputationBadge = cellLabels.allElementsBoundByIndex.contains { element in
            // Reputation should contain 'k' or 'M' or be a number
            let label = element.label
            return label.contains("k") || label.contains("M") || Int(label) != nil
        }
        XCTAssertTrue(hasReputationBadge, "Cell should display reputation badge")
    }
}
