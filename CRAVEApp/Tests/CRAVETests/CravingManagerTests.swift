//
//  CravingManagerTests.swift
//  CRAVE
//

import XCTest
import SwiftData
@testable import CRAVE

@MainActor
final class CravingManagerTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!
    var cravingManager: CravingManager!

    override func setUpWithError() throws {
        let schema = Schema([Craving.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
        cravingManager = CravingManager.shared
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        cravingManager = nil
    }

    func testSoftDeleteCraving() throws {
        let craving = Craving("Test Craving")
        context.insert(craving)
        try context.save()

        XCTAssertFalse(craving.isArchived, "❌ Craving should NOT be archived initially.")

        let deleteSuccess = cravingManager.softDeleteCraving(craving, using: context)
        XCTAssertTrue(deleteSuccess, "❌ Soft delete should return success.")

        context.processPendingChanges()
        try context.save()

        var fetchDescriptor = FetchDescriptor<Craving>()
        fetchDescriptor.includePendingChanges = true

        let fetchedCravings = try context.fetch(fetchDescriptor)

        print("🟡 DEBUG: All cravings after delete → \(fetchedCravings)")

        XCTAssertEqual(fetchedCravings.count, 1, "❌ Craving should exist in storage.")
        XCTAssertTrue(fetchedCravings.first!.isArchived, "❌ Craving should be marked as archived.")
    }
}
