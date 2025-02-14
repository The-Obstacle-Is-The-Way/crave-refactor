//
//  AnalyticsMetadataTests.swift
//  CRAVE
//

import XCTest
@testable import CRAVE

@MainActor
final class AnalyticsMetadataTests: XCTestCase {
    var sut: AnalyticsMetadata!
    var mockContainer: ModelContainer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockContainer = try ModelContainer(
            for: AnalyticsMetadata.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        sut = AnalyticsMetadata(cravingId: UUID())
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initialization Tests
    func testInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.processingState, .pending)
        XCTAssertEqual(sut.processingAttempts, 0)
        XCTAssertTrue(sut.userActions.isEmpty)
        XCTAssertTrue(sut.patternIdentifiers.isEmpty)
        XCTAssertTrue(sut.correlationFactors.isEmpty)
    }
    
    // MARK: - Time Category Tests
    func testTimeOfDayCalculation() {
        let calendar = Calendar.current
        
        // Test morning (8:00 AM)
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let morningMetadata = AnalyticsMetadata(cravingId: UUID())
        XCTAssertEqual(AnalyticsMetadata.TimeOfDay.current, .morning)
        
        // Test afternoon (2:00 PM)
        let afternoon = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!
        let afternoonMetadata = AnalyticsMetadata(cravingId: UUID())
        XCTAssertEqual(AnalyticsMetadata.TimeOfDay.current, .afternoon)
        
        // Test evening (7:00 PM)
        let evening = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
        let eveningMetadata = AnalyticsMetadata(cravingId: UUID())
        XCTAssertEqual(AnalyticsMetadata.TimeOfDay.current, .evening)
        
        // Test night (11:00 PM)
        let night = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!
        let nightMetadata = AnalyticsMetadata(cravingId: UUID())
        XCTAssertEqual(AnalyticsMetadata.TimeOfDay.current, .night)
    }
    
    // MARK: - Processing Tests
    func testMetadataProcessing() async throws {
        // Initial state
        XCTAssertEqual(sut.processingState, .pending)
        XCTAssertEqual(sut.processingAttempts, 0)
        
        // Process metadata
        try await sut.processMetadata()
        
        // Verify state after processing
        XCTAssertEqual(sut.processingState, .completed)
        XCTAssertEqual(sut.processingAttempts, 1)
        XCTAssertEqual(sut.lastProcessed.timeIntervalSinceNow, Date().timeIntervalSinceNow, accuracy: 1.0)
    }
    
    // MARK: - Persistence Tests
    func testPersistence() throws {
        let context = mockContainer.mainContext
        
        // Create and save metadata
        context.insert(sut)
        XCTAssertNoThrow(try context.save())
        
        // Fetch and verify
        let fetchDescriptor = FetchDescriptor<AnalyticsMetadata>()
        let results = try context.fetch(fetchDescriptor)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, sut.id)
    }
    
    // MARK: - Value Transformer Tests
    func testUserActionsTransformer() {
        let action = AnalyticsMetadata.UserAction(
            timestamp: Date(),
            actionType: .createEntry,
            metadata: ["key": "value"]
        )
        sut.userActions = [action]
        
        // Save to context
        let context = mockContainer.mainContext
        context.insert(sut)
        XCTAssertNoThrow(try context.save())
        
        // Fetch and verify
        let fetchDescriptor = FetchDescriptor<AnalyticsMetadata>()
        let results = try? context.fetch(fetchDescriptor)
        XCTAssertEqual(results?.first?.userActions.count, 1)
        XCTAssertEqual(results?.first?.userActions.first?.actionType, .createEntry)
    }
    
    func testStreakDataTransformer() {
        var streakData = AnalyticsMetadata.StreakData()
        streakData.currentStreak = 5
        streakData.longestStreak = 10
        sut.streakData = streakData
        
        // Save to context
        let context = mockContainer.mainContext
        context.insert(sut)
        XCTAssertNoThrow(try context.save())
        
        // Fetch and verify
        let fetchDescriptor = FetchDescriptor<AnalyticsMetadata>()
        let results = try? context.fetch(fetchDescriptor)
        XCTAssertEqual(results?.first?.streakData.currentStreak, 5)
        XCTAssertEqual(results?.first?.streakData.longestStreak, 10)
    }
}
