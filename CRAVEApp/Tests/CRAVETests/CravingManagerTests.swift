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
        // 1️⃣ Create and add a new craving
        let craving = Craving("Test Craving")
        let cravingID = craving.id  // Store ID for lookup
        context.insert(craving)

        if context.hasChanges {
            try context.save()
        }

        // 2️⃣ Confirm craving exists and is not deleted
        XCTAssertFalse(craving.isDeleted, "❌ Craving should NOT be marked as deleted initially.")

        // 3️⃣ Perform soft delete
        let deleteSuccess = cravingManager.softDeleteCraving(craving, using: context)
        XCTAssertTrue(deleteSuccess, "❌ Soft delete should return success.")

        if context.hasChanges {
            try context.save()
        }

        // 🔥 Force SwiftData to commit and sync changes
        context.processPendingChanges()

        // 5️⃣ Fetch the craving again from storage with correct predicate
        let fetchDescriptor = FetchDescriptor<Craving>(
            predicate: #Predicate { $0.id == cravingID }
        )
        let fetchedCravings = try context.fetch(fetchDescriptor)

        // 6️⃣ Validate the craving exists and is marked as deleted
        XCTAssertEqual(fetchedCravings.count, 1, "❌ Craving should exist in storage.")
        XCTAssertTrue(fetchedCravings.first!.isDeleted, "❌ Craving should be marked as deleted.")
    }
}
