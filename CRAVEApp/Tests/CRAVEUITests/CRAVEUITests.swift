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

    // ✅ Logs a craving, then verifies it appears in the date-grouped list.
    func testLoggingCravingAndSeeingItInHistory() throws {
        let logTab = app.tabBars.buttons["Log"]
        XCTAssertTrue(logTab.waitForExistence(timeout: 5))
        logTab.tap()

        let editor = app.textViews["CravingTextEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText("Test Craving Entry")

        let submit = app.buttons["SubmitButton"]
        XCTAssertTrue(submit.waitForExistence(timeout: 5))
        submit.tap()

        // 🚨 WAIT LONGER for SwiftData to process
        sleep(10)

        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.waitForExistence(timeout: 5))
        historyTab.tap()

        // 🚨 WAIT AGAIN for UI to update
        sleep(10)

        // ✅ TRY MULTIPLE METHODS TO FIND THE DATE CELL
        let dateCellByIdentifier = app.cells["dateCell"].firstMatch
        let dateCellByIndex = app.tables.cells.element(boundBy: 0)

        // ✅ Log if no date cell found
        if !dateCellByIdentifier.waitForExistence(timeout: 10) && !dateCellByIndex.waitForExistence(timeout: 10) {
            print("❌ UI Test Error: No date cell found. Dumping app hierarchy.")
            let hierarchy = app.debugDescription
            print(hierarchy)
        }

        XCTAssertTrue(dateCellByIdentifier.exists || dateCellByIndex.exists, "❌ No date cell found in History list.")

        if dateCellByIdentifier.exists {
            dateCellByIdentifier.tap()
        } else {
            dateCellByIndex.tap()
        }

        let newCravingText = app.staticTexts["Test Craving Entry"]
        XCTAssertTrue(newCravingText.waitForExistence(timeout: 10), "❌ New craving did not appear in the detail list.")
    }

    // ✅ Ensures we can delete a craving from the date's detail screen.
    func testDeletingCraving() throws {
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        let dateCell = app.cells["dateCell"].firstMatch
        if !dateCell.waitForExistence(timeout: 5) {
            // No cravings present, so log one first
            try testLoggingCravingAndSeeingItInHistory()
            historyTab.tap()
            sleep(3)  // Give UI time to refresh again
        }

        // Tap the first date cell to see the cravings
        XCTAssertTrue(dateCell.exists, "No date cell found even after creating one.")
        dateCell.tap()

        // Swipe-to-delete the first craving in that date
        let firstCravingRow = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCravingRow.waitForExistence(timeout: 5), "No craving row found to delete.")

        firstCravingRow.swipeLeft()
        let deleteButton = firstCravingRow.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2), "Delete button not found after swipe.")
        deleteButton.tap()

        // Craving should disappear
        XCTAssertFalse(
            firstCravingRow.waitForExistence(timeout: 5),
            "❌ Craving was not deleted successfully."
        )
    }
}
