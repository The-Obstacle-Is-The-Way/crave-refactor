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

    /// ✅ Test Soft Deletion
    func testSoftDeleteCraving() throws {
        let craving = Craving("Test Craving")
        context.insert(craving)
        try context.save()

        XCTAssertFalse(craving.isDeleted, "❌ Craving should NOT be marked as deleted initially.")

        // ✅ Perform soft delete
        let deleteSuccess = cravingManager.softDeleteCraving(craving, using: context)
        XCTAssertTrue(deleteSuccess, "❌ Soft delete should return success.")

        // ✅ Ensure changes are committed before fetching
        context.processPendingChanges()
        try context.save()

        // ✅ Fetch WITHOUT a predicate to ensure `isDeleted = true` is included
        var fetchDescriptor = FetchDescriptor<Craving>()
        fetchDescriptor.includePendingChanges = true

        let fetchedCravings = try context.fetch(fetchDescriptor)

        // ✅ Debugging Print
        print("🟡 DEBUG: All cravings after delete → \(fetchedCravings)")

        XCTAssertEqual(fetchedCravings.count, 1, "❌ Craving should exist in storage.")
        XCTAssertTrue(fetchedCravings.first!.isDeleted, "❌ Craving should be marked as deleted.")
    }
}
