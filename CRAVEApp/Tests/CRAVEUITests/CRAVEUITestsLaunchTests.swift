//
//  CRAVEUITestsLaunchTests.swift
//
//  Created by John H Jung on 2/12/25.
//

import XCTest

final class CRAVEUITestsLaunchTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testLaunchAndVerifyMainViews() throws {
        // ✅ Wait a bit to ensure the app is fully loaded before checking UI elements
        sleep(1)

        // ✅ Ensure we are in the correct tab before checking for elements
        let logTab = app.tabBars.buttons["Log"]
        if logTab.waitForExistence(timeout: 2) {
            logTab.tap()
        }

        // ✅ Ensure Log Craving screen loads
        let logTextField = app.textViews["CravingTextEditor"]
        XCTAssertTrue(logTextField.waitForExistence(timeout: 5), "❌ Craving input field not found")

        // ✅ Ensure navigation tab exists
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.waitForExistence(timeout: 5), "❌ History tab not found")

        // ✅ Capture a screenshot for debugging if test fails
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
