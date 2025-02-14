// File: EventTrackingServiceTests.swift
// Purpose: Test suite for event tracking functionality

import XCTest
import Combine
@testable import CRAVE

final class EventTrackingServiceTests: XCTestCase {
    var sut: EventTrackingService!
    var mockStorage: MockAnalyticsStorage!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockAnalyticsStorage()
        sut = EventTrackingService(
            storage: mockStorage,
            configuration: .preview
        )
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        mockStorage = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - User Event Tests
    func testUserEventTracking() async throws {
        let userEvent = MockUserEvent(action: "button_tap")
        
        try await sut.trackUserEvent(userEvent)
        
        XCTAssertEqual(sut.trackingMetrics.totalTracked, 1)
        XCTAssertEqual(sut.trackingMetrics.eventCounts[.user], 1)
        XCTAssertNotNil(sut.lastTrackedEvent)
    }
    
    // MARK: - System Event Tests
    func testSystemEventTracking() async throws {
        let systemEvent = MockSystemEvent(type: "app_launch")
        
        try await sut.trackSystemEvent(systemEvent)
        
        XCTAssertEqual(sut.trackingMetrics.totalTracked, 1)
        XCTAssertEqual(sut.trackingMetrics.eventCounts[.system], 1)
    }
    
    // MARK: - Craving Event Tests
    func testCravingEventTracking() async throws {
        let cravingEvent = MockCravingEvent(intensity: 7)
        
        try await sut.trackCravingEvent(cravingEvent)
        
        XCTAssertEqual(sut.trackingMetrics.totalTracked, 1)
        XCTAssertEqual(sut.trackingMetrics.eventCounts[.craving], 1)
    }
    
    // MARK: - Interaction Event Tests
    func testInteractionEventTracking() async throws {
        let interactionEvent = MockInteractionEvent(duration: 5.0)
        
        try await sut.trackInteractionEvent(interactionEvent)
        
        XCTAssertEqual(sut.trackingMetrics.totalTracked, 1)
        XCTAssertEqual(sut.trackingMetrics.eventCounts[.interaction], 1)
    }
    
    // MARK: - Batch Processing Tests
    func testBatchProcessing() async throws {
        // Track multiple events
        for _ in 0..<5 {
            try await sut.trackUserEvent(MockUserEvent(action: "test"))
        }
        
        // Wait for batch processing
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        XCTAssertEqual(mockStorage.storedBatchCount, 1)
        XCTAssertEqual(sut.trackingMetrics.totalTracked, 5)
    }
    
    // MARK: - Critical Event Tests
    func testCriticalEventProcessing() async throws {
        let criticalEvent = MockUserEvent(
            action: "critical_action",
            priority: .critical
        )
        
        try await sut.trackUserEvent(criticalEvent)
        
        // Should be processed immediately
        XCTAssertEqual(mockStorage.storedEventCount, 1)
        XCTAssertEqual(mockStorage.storedBatchCount, 0)
    }
    
    // MARK: - Event Fetching Tests
    func testEventFetching() async throws {
        // Track some events
        try await sut.trackUserEvent(MockUserEvent(action: "test"))
        
        let timeRange = DateInterval(
            start: Date().addingTimeInterval(-3600),
            end: Date()
        )
        
        let events = try await sut.getEvents(
            ofType: .user,
            in: timeRange
        )
        
        XCTAssertFalse(events.isEmpty)
    }
    
    // MARK: - Configuration Tests
    func testTrackingToggle() {
        let expectation = expectation(description: "Tracking state change")
        
        sut.$trackingEnabled
            .dropFirst()
            .sink { enabled in
                XCTAssertFalse(enabled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate configuration update
        NotificationCenter.default.post(
            name: .analyticsConfigurationUpdated,
            object: nil,
            userInfo: ["isAnalyticsEnabled": false]
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    func testInvalidEventHandling() async {
        let invalidEvent = MockUserEvent(action: "", isValid: false)
        
        do {
            try await sut.trackUserEvent(invalidEvent)
            XCTFail("Expected validation error")
        } catch EventTrackingError.validationFailed {
            XCTAssertEqual(sut.trackingMetrics.errorCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Metadata Tests
    func testEventMetadata() async throws {
        let event = MockUserEvent(action: "test")
        
        try await sut.trackUserEvent(event)
        
        guard let trackedEvent = sut.lastTrackedEvent else {
            XCTFail("No tracked event found")
            return
        }
        
        XCTAssertNotNil(trackedEvent.metadata.sessionId)
        XCTAssertNotNil(trackedEvent.metadata.deviceInfo)
        XCTAssertNotNil(trackedEvent.metadata.appInfo)
    }
    
    // MARK: - Performance Tests
    func testTrackingPerformance() {
        measure {
            let expectation = expectation(description: "Batch processing")
            
            Task {
                do {
                    for _ in 0..<100 {
                        try await self.sut.trackUserEvent(
                            MockUserEvent(action: "performance_test")
                        )
                    }
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
}

// MARK: - Mock Types
struct MockUserEvent: UserEvent {
    let action: String
    let priority: EventPriority
    let isValid: Bool
    
    init(
        action: String,
        priority: EventPriority = .normal,
        isValid: Bool = true
    ) {
        self.action = action
        self.priority = priority
        self.isValid = isValid
    }
}

struct MockSystemEvent: SystemEvent {
    let type: String
}

struct MockCravingEvent: CravingEvent {
    let intensity: Int
}

struct MockInteractionEvent: InteractionEvent {
    let duration: TimeInterval
}

class MockAnalyticsStorage: AnalyticsStorage {
    var storedEventCount = 0
    var storedBatchCount = 0
    
    override func store(_ event: TrackedEvent) async throws {
        storedEventCount += 1
    }
    
    override func storeBatch(_ events: [TrackedEvent]) async throws {
        storedBatchCount += 1
    }
}
