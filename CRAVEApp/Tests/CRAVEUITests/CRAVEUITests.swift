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

    // Test Deleting a Craving and Verifying Removal from History
    func testDeletingCraving() throws {
        let logTab = app.tabBars.buttons["Log"]
        logTab.tap()

        let textField = app.textViews["CravingTextEditor"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5), "❌ Craving input field not found.")

        textField.tap()
        textField.typeText("Test Craving")

        let saveButton = app.buttons["SubmitButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "❌ Save button not found.")
        saveButton.tap()

        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        // Wait for the history list to update
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "❌ No date cell found in History list.")

        firstCell.swipeLeft()
        app.buttons["Delete"].tap()

        // Verify the cell no longer exists
        XCTAssertFalse(firstCell.exists, "❌ Deleted craving still appears in the history list.")
    }
}
