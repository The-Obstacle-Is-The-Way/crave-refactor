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
        CravingManager.shared.addCraving("Test craving", using: context)
        let results = try context.fetch(FetchDescriptor<Craving>())
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.text, "Test craving")
    }

    func testSoftDeleteCraving() throws {
        CravingManager.shared.addCraving("Soft-delete me", using: context)

        var fetched = try context.fetch(FetchDescriptor<Craving>())
        XCTAssertEqual(fetched.count, 1)

        guard let inserted = fetched.first else {
            return XCTFail("No craving found after insert.")
        }

        CravingManager.shared.softDeleteCraving(inserted, using: context)
        fetched = try context.fetch(FetchDescriptor<Craving>())

        XCTAssertEqual(fetched.count, 1)
        // Option 1: coalesce to false
        XCTAssertTrue(fetched.first?.isDeleted ?? false, "Craving should be marked as deleted")

        // or Option 2: compare with XCTAssertEqual
        // XCTAssertEqual(fetched.first?.isDeleted, true)
    }
}
