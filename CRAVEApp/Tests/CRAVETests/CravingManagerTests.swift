import XCTest
import SwiftData
@testable import CRAVE

final class CravingManagerTests: XCTestCase {

    func testAddCraving() throws {
        let container = try ModelContainer(
            for: Craving.self,
            ModelConfiguration(.ephemeral) // ephemeral = in-memory
        )
        let context = ModelContext(container)

        // Insert
        let newCravingText = "This is a test craving"
        CravingManager.shared.addCraving(newCravingText, using: context)

        // Fetch
        let fetchedCravings = try context.fetch(FetchDescriptor<Craving>())

        // Assert
        XCTAssertEqual(fetchedCravings.count, 1)
        XCTAssertEqual(fetchedCravings.first?.text, newCravingText)
    }
    
    func testSoftDeleteCraving() throws {
        let container = try ModelContainer(
            for: Craving.self,
            ModelConfiguration(.ephemeral)
        )
        let context = ModelContext(container)

        // Insert
        let newCravingText = "Should be soft-deleted"
        CravingManager.shared.addCraving(newCravingText, using: context)

        // Fetch
        let fetchedCravings = try context.fetch(FetchDescriptor<Craving>())
        guard let inserted = fetchedCravings.first else {
            return XCTFail("Failed to insert craving.")
        }

        // Soft delete
        CravingManager.shared.softDeleteCraving(inserted, using: context)

        // Verify
        let refetched = try context.fetch(FetchDescriptor<Craving>())
        XCTAssertEqual(refetched.count, 1)
        XCTAssertTrue(refetched.first?.isDeleted == true)
    }
}
