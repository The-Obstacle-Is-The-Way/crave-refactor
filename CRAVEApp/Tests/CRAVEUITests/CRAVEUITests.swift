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
        // Tap the "Log" tab
        let logTab = app.tabBars.buttons["Log"]
        XCTAssertTrue(logTab.waitForExistence(timeout: 5), "Log tab not found.")
        logTab.tap()
        
        // Look for the text view with accessibility identifier "CravingTextEditor"
        let textEditor = app.textViews["CravingTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5), "❌ Craving input field not found.")
        textEditor.tap()
        textEditor.typeText("Test Craving")
        
        // Find and tap the Submit button (with accessibility identifier "SubmitButton")
        let submitButton = app.buttons["SubmitButton"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5), "❌ Save button not found.")
        submitButton.tap()
        
        // Tap the "History" tab (ensure your app has this tab in its TabView)
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.waitForExistence(timeout: 5), "History tab not found.")
        historyTab.tap()
        
        // Wait for the history list to update
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "❌ No date cell found in History list.")
        
        // Swipe left on the cell to reveal the Delete button and tap it
        firstCell.swipeLeft()
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5), "❌ Delete button not found.")
        deleteButton.tap()
        
        // Verify the cell no longer exists
        XCTAssertFalse(firstCell.exists, "❌ Deleted craving still appears in the history list.")
    }
}
