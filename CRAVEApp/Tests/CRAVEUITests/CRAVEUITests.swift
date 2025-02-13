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

    func testDeletingCraving() throws {
        let logTab = app.tabBars.buttons["Log"]
        XCTAssertTrue(logTab.exists, "❌ Log tab button not found.")
        logTab.tap()
        
        let textField = app.textViews["CravingTextEditor"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5), "❌ Craving input field not found.")
        
        textField.tap()
        textField.typeText("Test Craving")

        let saveButton = app.buttons["SubmitButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "❌ Save button not found.")
        saveButton.tap()
        
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.exists, "❌ History tab button not found.")
        historyTab.tap()

        // ✅ Print all UI elements for debugging
        print("🟡 DEBUG: Checking all elements in History screen...")
        print(app.debugDescription)

        let historyCell = app.cells.matching(identifier: "historyDateCell").firstMatch
        XCTAssertTrue(historyCell.waitForExistence(timeout: 8), "❌ No date cell found in History list.")

        historyCell.swipeLeft()
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.exists, "❌ Delete button not found.")
        deleteButton.tap()

        let doesNotExist = NSPredicate(format: "exists == false")
        expectation(for: doesNotExist, evaluatedWith: historyCell, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(historyCell.exists, "❌ Deleted craving still appears in the history list.")
    }
}
