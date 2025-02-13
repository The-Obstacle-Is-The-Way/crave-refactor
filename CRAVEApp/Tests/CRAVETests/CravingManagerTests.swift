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
        let schema = Schema([CravingModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        context = container.mainContext
        cravingManager = CravingManager(context: context)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        cravingManager = nil
    }

    // Test Soft Deletion
    func testSoftDeleteCraving() throws {
        // 1. Create and add a new craving
        let craving = CravingModel(intensity: 5, note: "Test Craving")
        // Store the auto-generated id (assuming CravingModel conforms to Identifiable)
        let cravingID = craving.id
        context.insert(craving)

        if context.hasChanges {
            try context.save()
        }

        // 2. Confirm craving exists and is not archived
        XCTAssertFalse(craving.isArchived, "❌ Craving should NOT be marked as archived initially.")

        // 3. Perform soft delete via CravingManager
        let deleteSuccess = cravingManager.softDeleteCraving(craving, using: context)
        XCTAssertTrue(deleteSuccess, "❌ Soft delete should return success.")

        if context.hasChanges {
            try context.save()
        }

        // 4. Force SwiftData to process pending changes
        context.processPendingChanges()

        // 5. Fetch the craving again from storage with the correct predicate
        let fetchDescriptor = FetchDescriptor<CravingModel>(
            predicate: #Predicate { $0.id == cravingID }
        )
        let fetchedCravings = try context.fetch(fetchDescriptor)

        // 6. Validate the craving exists and is marked as archived
        XCTAssertEqual(fetchedCravings.count, 1, "❌ Craving should exist in storage.")
        XCTAssertTrue(fetchedCravings.first!.isArchived, "❌ Craving should be marked as archived.")
    }
}
