//
//  InteractionDataTests.swift
//  CRAVE
//


import XCTest
@testable import CRAVE

final class InteractionDataTests: XCTestCase {
    var sut: InteractionData!
    
    override func setUp() {
        super.setUp()
        sut = InteractionData(cravingId: UUID())
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.interactionResult, .pending)
        XCTAssertTrue(sut.userActions.isEmpty)
    }
    
    // MARK: - Action Tracking Tests
    func testActionTracking() {
        let action = UserInteractionEvent(
            timestamp: Date(),
            eventType: .buttonTap,
            duration: 0.5,
            metadata: ["button": "submit"]
        )
        
        sut.trackAction(action)
        XCTAssertEqual(sut.userActions.count, 1)
    }
    
    // MARK: - Interaction Flow Tests
    func testInteractionCompletion() {
        sut.startInteraction()
        Thread.sleep(forTimeInterval: 0.1)
        sut.completeInteraction(result: .success)
        
        XCTAssertEqual(sut.interactionResult, .success)
        XCTAssertTrue(sut.completionTime > 0)
    }
    
    // MARK: - Validation Tests
    func testValidationErrorTracking() {
        let error = ValidationError(
            field: "text",
            errorType: .required,
            message: "Required field",
            timestamp: Date()
        )
        
        sut.addValidationError(error)
        XCTAssertEqual(sut.validationAttempts, 1)
        XCTAssertFalse(sut.isValidated)
    }
    
    // MARK: - Performance Tests
    func testPerformanceTracking() {
        sut.trackPerformance(loadTime: 0.05, renderTime: 0.02)
        XCTAssertTrue(sut.isPerformanceOptimal)
    }
    
    // MARK: - Analytics Tests
    func testAnalyticsGeneration() {
        let analytics = sut.generateAnalytics()
        XCTAssertEqual(analytics.interactionId, sut.id)
        XCTAssertEqual(analytics.cravingId, sut.cravingId)
    }
}
