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

    /// ✅ Test Deleting a Craving and Verifying Removal from History
    func testDeletingCraving() throws {
        let logTab = app.tabBars.buttons["Log"]
        logTab.tap()
        
        let textField = app.textViews["CravingTextEditor"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5), "❌ Craving input field not found.")
        
        textField.tap()
        textField.typeText("Test Craving")

        // ✅ Updated to use the correct button identifier
        let saveButton = app.buttons["SubmitButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "❌ Save button not found.")
        saveButton.tap()
        
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        // 🚨 DEBUG: Print all elements in History screen
        print("🟡 DEBUG: Checking all elements in History screen...")
        print(app.debugDescription) // 🔍 Print all visible UI elements

        // ✅ Try matching history cells dynamically
        let historyCell = app.cells.containing(NSPredicate(format: "identifier BEGINSWITH 'historyDateCell'")).firstMatch
        XCTAssertTrue(historyCell.waitForExistence(timeout: 5), "❌ No date cell found in History list.")

        historyCell.swipeLeft()
        app.buttons["Delete"].tap()
        
        XCTAssertFalse(historyCell.waitForExistence(timeout: 3), "❌ Deleted craving still appears in the history list.")
    }
}
