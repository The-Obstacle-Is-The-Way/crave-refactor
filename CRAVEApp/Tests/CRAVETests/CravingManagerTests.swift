import XCTest
import SwiftData
@testable import CRAVE

@MainActor  // ✅ Ensures everything in this class runs on the main actor
final class CravingManagerTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([Craving.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)  // ✅ Now runs on the main actor
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func testAddCraving() throws {
        let newCravingText = "This is a test craving"

        CravingManager.shared.addCraving(newCravingText, using: context)  // ✅ No `await` needed

        let fetchedCravings = try context.fetch(FetchDescriptor<Craving>())  // ✅ No `await` needed

        XCTAssertEqual(fetchedCravings.count, 1, "Craving count should be 1")
        XCTAssertEqual(fetchedCravings.first?.text, newCravingText, "Craving text should match")
    }

    func testSoftDeleteCraving() throws {
        let newCravingText = "Should be soft-deleted"

        CravingManager.shared.addCraving(newCravingText, using: context)

        let fetchedCravings = try context.fetch(FetchDescriptor<Craving>())
        guard let insertedCraving = fetchedCravings.first else {
            return XCTFail("Failed to insert craving.")
        }

        CravingManager.shared.softDeleteCraving(insertedCraving, using: context)

        let refetchedCravings = try context.fetch(FetchDescriptor<Craving>())
        XCTAssertEqual(refetchedCravings.count, 1, "Craving count should still be 1")
        XCTAssertTrue(refetchedCravings.first?.isDeleted == true, "Craving should be marked as deleted")
    }
}
