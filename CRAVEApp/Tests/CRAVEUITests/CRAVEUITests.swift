//
//  CRAVEUITests.swift
//  CRAVEUITests
//

import XCTest

final class CRAVEUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // 1) Logs a craving, then verifies it appears in the date-grouped list.
    func testLoggingCravingAndSeeingItInHistory() throws {
        // Switch to "Log" tab
        let logTab = app.tabBars.buttons["Log"]
        XCTAssertTrue(logTab.waitForExistence(timeout: 2))
        logTab.tap()

        // Enter craving text
        let editor = app.textViews["CravingTextEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5), "No CravingTextEditor found.")
        editor.tap()
        editor.typeText("Test Craving Entry")

        // Submit
        let submit = app.buttons["SubmitButton"]
        XCTAssertTrue(submit.waitForExistence(timeout: 2), "No Submit button.")
        submit.tap()

        // Add a small delay to ensure the UI updates
        sleep(2)

        // Switch to "History" tab
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.waitForExistence(timeout: 2), "No History tab.")
        historyTab.tap()

        // Find the first date cell
        let firstDateCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstDateCell.waitForExistence(timeout: 5), "No date cell found in History list.")

        // Tap the date cell to see the cravings for that date
        firstDateCell.tap()

        // Now we expect to see "Test Craving Entry" in CravingListView
        let newCravingText = app.staticTexts["Test Craving Entry"]
        XCTAssertTrue(newCravingText.waitForExistence(timeout: 5), "❌ New craving did not appear in the detail list.")
    }

    // 2) Ensures we can delete a craving from the date's detail screen.
    func testDeletingCraving() throws {
        // Create a craving if none exist
        // (Try tapping History; if no cells, log a new craving first.)
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        let firstDateCell = app.tables.cells.element(boundBy: 0)
        if !firstDateCell.waitForExistence(timeout: 5) {
            // No cravings present, so log one
            try testLoggingCravingAndSeeingItInHistory()
            historyTab.tap()

            // Add a small delay to ensure the UI updates
            sleep(2)
        }

        // Tap the first date cell to see the cravings
        XCTAssertTrue(firstDateCell.exists, "No date cell found even after creating one.")
        firstDateCell.tap()

        // Swipe-to-delete the first craving
        let firstCravingRow = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCravingRow.waitForExistence(timeout: 5), "No craving row found to delete.")

        firstCravingRow.swipeLeft()
        let deleteButton = firstCravingRow.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2), "Delete button not found after swipe.")
        deleteButton.tap()

        // Craving should disappear
        XCTAssertFalse(firstCravingRow.waitForExistence(timeout: 5), "Craving was not deleted successfully.")
    }
}
