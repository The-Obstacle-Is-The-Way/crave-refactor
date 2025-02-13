//
//  CravingManagerTests.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25
//

import XCTest
import SwiftData
@testable import CRAVE

@MainActor
final class CravingManagerTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([Craving.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func testAddCraving() throws {
        let addSuccess = CravingManager.shared.addCraving("Test craving", using: context)
        XCTAssertTrue(addSuccess, "❌ Craving was not added successfully.")

        let results = try context.fetch(FetchDescriptor<Craving>(predicate: #Predicate { !$0.isDeleted }))
        XCTAssertEqual(results.count, 1, "❌ Expected one craving after insertion.")
        XCTAssertEqual(results.first?.text, "Test craving", "❌ Craving text did not match.")
    }

    func testSoftDeleteCraving() throws {
        // 1. Add new craving
        let addSuccess = CravingManager.shared.addCraving("Soft-delete me", using: context)
        XCTAssertTrue(addSuccess, "❌ Craving was not added successfully before soft delete.")

        var fetched = try context.fetch(
            FetchDescriptor<Craving>(predicate: #Predicate { !$0.isDeleted })
        )
        XCTAssertEqual(fetched.count, 1, "❌ Expected one craving before soft deletion.")

        guard let inserted = fetched.first else {
            return XCTFail("❌ No craving found after insert.")
        }

        // ✅ Log the state before soft delete
        print("🔹 Before soft delete: \(inserted.text) | isDeleted: \(inserted.isDeleted)")

        // 2. Soft-delete that craving
        let deleteSuccess = CravingManager.shared.softDeleteCraving(inserted, using: context)
        XCTAssertTrue(deleteSuccess, "❌ Soft delete operation failed.")

        // ✅ Force SwiftData to commit and refresh
        RunLoop.current.run(until: Date().addingTimeInterval(1.0))

        // ✅ Re-fetch everything (including deleted)
        fetched = try context.fetch(FetchDescriptor<Craving>())
        print("🔍 All cravings after soft-delete:")
        fetched.forEach { print("📝 \(String(describing: $0.text)) | Deleted: \($0.isDeleted)") }

        // ✅ Verify that the craving is marked as deleted
        XCTAssertTrue(
            fetched.first?.isDeleted ?? false,
            "❌ Craving should be marked as deleted but was not."
        )

        // 5. Confirm soft-deleted items do NOT appear when includingDeleted = false
        let nonDeletedCravings = CravingManager.shared.fetchCravings(
            using: context,
            includingDeleted: false
        )
        XCTAssertEqual(
            nonDeletedCravings.count,
            0,
            "❌ Soft-deleted cravings should not appear in the non-deleted list."
        )
    }

    func testPermanentDeleteCraving() throws {
        let addSuccess = CravingManager.shared.addCraving("Permanent-delete me", using: context)
        XCTAssertTrue(addSuccess, "❌ Craving was not added successfully before permanent delete.")

        var fetched = try context.fetch(
            FetchDescriptor<Craving>(predicate: #Predicate { !$0.isDeleted })
        )
        XCTAssertEqual(fetched.count, 1, "❌ Expected one craving before permanent deletion.")

        guard let inserted = fetched.first else {
            return XCTFail("❌ No craving found after insert.")
        }

        let deleteSuccess = CravingManager.shared.permanentlyDeleteCraving(inserted, using: context)
        XCTAssertTrue(deleteSuccess, "❌ Permanent delete operation failed.")

        fetched = try context.fetch(FetchDescriptor<Craving>())
        XCTAssertEqual(fetched.count, 0, "❌ Craving should be fully deleted from the database.")
    }
}
