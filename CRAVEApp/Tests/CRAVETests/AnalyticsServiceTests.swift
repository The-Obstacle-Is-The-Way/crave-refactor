// File: AnalyticsServiceTests.swift
// Purpose: Test suite for analytics service functionality

import XCTest
import SwiftData
import Combine
@testable import CRAVE

final class AnalyticsServiceTests: XCTestCase {
    var sut: AnalyticsService!
    var modelContext: ModelContext!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: CravingModel.self, configurations: config)
        modelContext = container.mainContext
        sut = AnalyticsService(configuration: .preview, modelContext: modelContext)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        modelContext = nil
        super.tearDown()
    }
    
    // MARK: - Event Tracking Tests
    func testEventTracking() async throws {
        // Create test event
        let event = MockAnalyticsEvent(
            priority: .normal,
            metadata: ["test": "data"]
        )
        
        // Track event
        try await sut.trackEvent(event)
        
        // Verify metrics
        XCTAssertEqual(sut.processingMetrics.totalEventsTracked, 1)
        XCTAssertEqual(sut.currentState, .idle)
    }
    
    func testCriticalEventProcessing() async throws {
        let criticalEvent = MockAnalyticsEvent(
            priority: .critical,
            metadata: ["critical": "true"]
        )
        
        // Track critical event
        try await sut.trackEvent(criticalEvent)
        
        // Verify immediate processing
        XCTAssertEqual(sut.processingMetrics.totalEventsTracked, 1)
        XCTAssertNotNil(sut.lastProcessingTime)
    }
    
    // MARK: - Analytics Processing Tests
    func testAnalyticsProcessing() async throws {
        // Add some events
        for _ in 0..<3 {
            try await sut.trackEvent(MockAnalyticsEvent())
        }
        
        // Process analytics
        try await sut.processAnalytics()
        
        // Verify processing
        XCTAssertFalse(sut.isProcessing)
        XCTAssertNotNil(sut.lastProcessingTime)
        
        if case .completed(let insights, let predictions) = sut.currentState {
            XCTAssertFalse(insights.isEmpty)
            XCTAssertFalse(predictions.isEmpty)
        } else {
            XCTFail("Expected completed state with insights and predictions")
        }
    }
    
    // MARK: - Concurrent Processing Tests
    func testConcurrentProcessing() async throws {
        let expectation = expectation(description: "Concurrent processing")
        expectation.expectedFulfillmentCount = 2
        
        // Attempt concurrent processing
        async let process1 = processAndVerify(expectation)
        async let process2 = processAndVerify(expectation)
        
        // Only one should succeed
        await _ = [process1, process2]
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    private func processAndVerify(_ expectation: XCTestExpectation) async {
        do {
            try await sut.processAnalytics()
            expectation.fulfill()
        } catch {
            // Expected for one of the concurrent calls
            expectation.fulfill()
        }
    }
    
    // MARK: - Report Generation Tests
    func testReportGeneration() async throws {
        let timeRange = DateInterval(
            start: Date().addingTimeInterval(-86400),
            end: Date()
        )
        
        let report = try await sut.generateReport(
            type: .daily,
            timeRange: timeRange
        )
        
        XCTAssertNotNil(report)
        XCTAssertEqual(report.timeRange, timeRange)
    }
    
    // MARK: - Reset Tests
    func testServiceReset() async throws {
        // Add some data
        try await sut.trackEvent(MockAnalyticsEvent())
        try await sut.processAnalytics()
        
        // Reset service
        try await sut.reset()
        
        // Verify reset
        XCTAssertEqual(sut.currentState, .idle)
        XCTAssertEqual(sut.processingMetrics.totalEventsTracked, 0)
        XCTAssertFalse(sut.isProcessing)
    }
    
    // MARK: - State Change Tests
    func testStateChanges() async throws {
        let stateChanges = expectation(description: "State changes")
        var states: [AnalyticsState] = []
        
        sut.$currentState
            .sink { state in
                states.append(state)
                if states.count >= 3 { // idle -> processing -> completed
                    stateChanges.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger state changes
        try await sut.trackEvent(MockAnalyticsEvent())
        try await sut.processAnalytics()
        
        await fulfillment(of: [stateChanges], timeout: 5.0)
        
        XCTAssertEqual(states.first, .idle)
        XCTAssertTrue(states.contains(.processing))
    }
    
    // MARK: - Error Handling Tests
    func testErrorHandling() async {
        let invalidEvent = MockAnalyticsEvent(isValid: false)
        
        do {
            try await sut.trackEvent(invalidEvent)
            XCTFail("Expected error for invalid event")
        } catch {
            XCTAssertTrue(error is AnalyticsServiceError)
            XCTAssertEqual(sut.processingMetrics.totalErrors, 1)
        }
    }
    
    // MARK: - Performance Tests
    func testProcessingPerformance() throws {
        measure {
            let expectation = expectation(description: "Processing performance")
            
            Task {
                do {
                    // Track multiple events
                    for _ in 0..<100 {
                        try await self.sut.trackEvent(MockAnalyticsEvent())
                    }
                    
                    try await self.sut.processAnalytics()
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
}

// MARK: - Mock Types
struct MockAnalyticsEvent: AnalyticsEvent {
    let id = UUID()
    let timestamp = Date()
    let eventType: AnalyticsEventType = .appLaunch
    let metadata: [String: AnyHashable]
    let priority: EventPriority
    let isValid: Bool
    
    init(
        priority: EventPriority = .normal,
        metadata: [String: AnyHashable] = [:],
        isValid: Bool = true
    ) {
        self.priority = priority
        self.metadata = metadata
        self.isValid = isValid
    }
}
