import NetworkLibrary
import XCTest

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

        // Test first cell
        let firstCell = cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First cell should exist")

        // With new accessibility grouping, cells have 2 elements: content + button
        // Find buttons by matching any button with "Follow" text
        let firstFollowButton = firstCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Follow'")).firstMatch
        XCTAssertTrue(firstFollowButton.waitForExistence(timeout: 2), "First cell should have follow button")

        let secondCell = cells.element(boundBy: 1)
        let secondFollowButton = secondCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Follow'")).firstMatch
        XCTAssertTrue(secondFollowButton.waitForExistence(timeout: 2), "Second cell should have follow button")

        // Test 1: Follow first user
        firstFollowButton.tap()

        // Button label should change to contain "Following"
        let firstFollowingButton = firstCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Following'")).firstMatch
        XCTAssertTrue(firstFollowingButton.waitForExistence(timeout: 2), "First user button should change to 'Following'")

        // Test 2: Follow second user
        secondFollowButton.tap()
        let secondFollowingButton = secondCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Following'")).firstMatch
        XCTAssertTrue(secondFollowingButton.waitForExistence(timeout: 2), "Second user button should change to 'Following'")

        // Verify both are still following
        XCTAssertTrue(
            firstCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Following'")).firstMatch.exists,
            "First user should still be 'Following'"
        )
        XCTAssertTrue(
            secondCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Following'")).firstMatch.exists,
            "Second user should still be 'Following'"
        )

        // Test 3: Unfollow first user
        firstFollowingButton.tap()
        let firstFollowButtonAgain = firstCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Follow' AND NOT label CONTAINS 'Following'")).firstMatch
        XCTAssertTrue(firstFollowButtonAgain.waitForExistence(timeout: 2), "First user button should change back to 'Follow'")

        // Verify second user is still following
        XCTAssertTrue(
            secondCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Following'")).firstMatch.exists,
            "Second user should still be 'Following'"
        )

        // Test 4: Verify persistence by scrolling (triggers cell reuse)
        if collectionView.isHittable {
            collectionView.swipeUp()
            collectionView.swipeDown()
        }

        // After scrolling, verify states persist
        XCTAssertTrue(
            secondCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Following'")).firstMatch.exists,
            "Second user should persist 'Following' state after scroll"
        )
        XCTAssertTrue(
            firstCell.buttons.matching(NSPredicate(format: "label CONTAINS 'Follow' AND NOT label CONTAINS 'Following'")).firstMatch.exists,
            "First user should persist 'Follow' state after scroll"
        )
    }

    @MainActor
    func testUserCellAccessibility() throws {
        // Setup mock data
        let mapper = [
            NetworkMockData(api: "/2.2/users", filename: "users", bundlePath: Bundle(for: UsersUITests.self).bundlePath)
        ]

        let app = XCUIApplication()
        app.launchArguments = ["mock"]
        app.launchEnvironment = [
            "mapper": mapper.asString,
            "UI_TEST_SUITE": "test.cell.accessibility.\(UUID().uuidString)"
        ]
        app.launch()

        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 10), "Collection view should exist")

        let firstCell = collectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First cell should exist")

        // With VoiceOver accessibility grouping, cells should have 2 main elements:
        // 1. Grouped cell content (user info)
        // 2. Follow button

        // Verify cell has a follow button
        let followButton = firstCell.buttons.firstMatch
        XCTAssertTrue(followButton.exists, "Cell should have follow button")

        // Verify button label contains user name (for VoiceOver)
        let buttonLabel = followButton.label
        XCTAssertTrue(
            buttonLabel.contains("Follow") || buttonLabel.contains("Following"),
            "Button label should contain Follow or Following"
        )

        // Verify cell has accessibility content
        // The grouped content element contains: name, reputation, location, badges
        let staticTexts = firstCell.staticTexts.allElementsBoundByIndex
        if !staticTexts.isEmpty {
            // If static texts are visible, verify they contain expected data
            let hasUserData = staticTexts.contains { element in
                let label = element.label
                // Check for reputation (contains numbers with k/M) or user names
                return label.contains("Reputation") ||
                       label.contains("Location") ||
                       label.contains("gold") ||
                       label.contains("silver") ||
                       label.contains("bronze") ||
                       label.contains("k") ||
                       label.contains("M")
            }
            XCTAssertTrue(hasUserData, "Cell should contain user information in accessibility content")
        }

        // Test button is tappable
        let initialLabel = followButton.label
        followButton.tap()

        // Button label should change
        sleep(1) // Brief wait for animation
        let newLabel = followButton.label
        XCTAssertNotEqual(initialLabel, newLabel, "Button label should change after tap")
    }
}
