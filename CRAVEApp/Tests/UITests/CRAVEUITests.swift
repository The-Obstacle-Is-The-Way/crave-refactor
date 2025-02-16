//
//  CRAVEUITests.swift
//  CRAVEUITests
//
//

import XCTest

final class CRAVEUITests: XCTestCase {
    private var app: XCUIApplication!

    // MARK: - Setup Before Each Test
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Test Tab Navigation
    func testTabNavigation() {
        let cravingsTab = app.tabBars.buttons["CravingsTab"]
        let logTab = app.tabBars.buttons["LogCravingTab"]
        let analyticsTab = app.tabBars.buttons["AnalyticsTab"]

        XCTAssertTrue(cravingsTab.exists)
        XCTAssertTrue(logTab.exists)
        XCTAssertTrue(analyticsTab.exists)

        logTab.tap()
        XCTAssertTrue(app.navigationBars["Log Craving"].exists)

        analyticsTab.tap()
        XCTAssertTrue(app.navigationBars["Analytics"].exists)

        cravingsTab.tap()
        XCTAssertTrue(app.navigationBars["Cravings"].exists)
    }

    // MARK: - Test Adding a Craving
    func testAddingCraving() {
        let logTab = app.tabBars.buttons["LogCravingTab"]
        logTab.tap()

        let cravingField = app.textFields["Enter craving..."]
        XCTAssertTrue(cravingField.exists)
        
        cravingField.tap()
        cravingField.typeText("Test Craving")

        let logButton = app.buttons["Log Craving"]
        XCTAssertTrue(logButton.isEnabled) // ✅ Ensure button is enabled after input
        logButton.tap()

        let cravingsTab = app.tabBars.buttons["CravingsTab"]
        cravingsTab.tap()

        XCTAssertTrue(app.staticTexts["Test Craving"].exists) // ✅ Ensure new craving appears
    }

    // MARK: - Test Soft Deleting a Craving
    func testSoftDeleteCraving() {
        let cravingsTab = app.tabBars.buttons["CravingsTab"]
        cravingsTab.tap()

        let firstCraving = app.cells.firstMatch
        XCTAssertTrue(firstCraving.exists)

        let deleteButton = firstCraving.buttons["trash"]
        XCTAssertTrue(deleteButton.exists)

        deleteButton.tap()

        XCTAssertFalse(firstCraving.exists) // ✅ Ensure craving disappears after soft delete
    }

    // MARK: - Test Analytics UI
    func testAnalyticsDisplays() {
        let analyticsTab = app.tabBars.buttons["AnalyticsTab"]
        analyticsTab.tap()

        XCTAssertTrue(app.staticTexts["Cravings Analytics"].exists)
    }
}
