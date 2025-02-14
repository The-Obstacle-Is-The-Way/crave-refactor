//
//  AnalyticsManagerTests.swift
//  CRAVE
//
//

import XCTest
import SwiftData
@testable import CRAVE

final class AnalyticsManagerTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var analyticsManager: AnalyticsManager!

    // MARK: - Setup Before Each Test
    override func setUpWithError() throws {
        modelContainer = try ModelContainer(for: CravingModel.self, configurations: .init(isStoredInMemoryOnly: true))
        modelContext = modelContainer.mainContext
        analyticsManager = AnalyticsManager()
        analyticsManager.modelContext = modelContext // ✅ Inject test context
    }

    // MARK: - Cleanup After Each Test
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
        analyticsManager = nil
    }

    // MARK: - Test Cravings Grouped by Date
    func testCravingsGroupedByDate() async throws {
        let craving1 = CravingModel(cravingText: "Soda", timestamp: dateFromString("2024-02-10"))
        let craving2 = CravingModel(cravingText: "Candy", timestamp: dateFromString("2024-02-10"))
        let craving3 = CravingModel(cravingText: "Chips", timestamp: dateFromString("2024-02-11"))

        analyticsManager.insert(craving1)
        analyticsManager.insert(craving2)
        analyticsManager.insert(craving3)

        let groupedData = await analyticsManager.cravingsByDate()

        XCTAssertEqual(groupedData["Feb 10, 2024"], 2)
        XCTAssertEqual(groupedData["Feb 11, 2024"], 1)
    }

    // MARK: - Test Cravings Grouped by Time of Day
    func testCravingsGroupedByTimeOfDay() async throws {
        let morningCraving = CravingModel(cravingText: "Donut", timestamp: dateFromHour(9))
        let afternoonCraving = CravingModel(cravingText: "Fries", timestamp: dateFromHour(14))
        let eveningCraving = CravingModel(cravingText: "Burger", timestamp: dateFromHour(19))
        let nightCraving = CravingModel(cravingText: "Ice Cream", timestamp: dateFromHour(23))

        analyticsManager.insert(morningCraving)
        analyticsManager.insert(afternoonCraving)
        analyticsManager.insert(eveningCraving)
        analyticsManager.insert(nightCraving)

        let timeData = await analyticsManager.cravingsByTimeOfDay()

        XCTAssertEqual(timeData["Morning"], 1)
        XCTAssertEqual(timeData["Afternoon"], 1)
        XCTAssertEqual(timeData["Evening"], 1)
        XCTAssertEqual(timeData["Night"], 1)
    }

    // MARK: - Test Zero Cravings
    func testZeroCravings() async throws {
        let groupedData = await analyticsManager.cravingsByDate()
        let timeData = await analyticsManager.cravingsByTimeOfDay()

        XCTAssertTrue(groupedData.isEmpty) // ✅ No data should exist
        XCTAssertTrue(timeData.isEmpty) // ✅ No time data should exist
    }

    // MARK: - Helper Functions
    private func dateFromString(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }

    private func dateFromHour(_ hour: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        return Calendar.current.date(from: components) ?? Date()
    }
}
