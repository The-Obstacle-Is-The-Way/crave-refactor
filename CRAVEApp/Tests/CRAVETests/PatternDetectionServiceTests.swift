// File: PatternDetectionServiceTests.swift
// Purpose: Test suite for pattern detection functionality

import XCTest
import Combine
@testable import CRAVE

final class PatternDetectionServiceTests: XCTestCase {
    var sut: PatternDetectionService!
    var mockStorage: MockAnalyticsStorage!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockAnalyticsStorage()
        sut = PatternDetectionService(
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
    
    // MARK: - Pattern Detection Tests
    func testPatternDetection() async throws {
        // Setup test data
        mockStorage.mockAnalytics = createMockAnalytics()
        
        // Detect patterns
        let patterns = try await sut.detectPatterns()
        
        // Verify detection
        XCTAssertFalse(patterns.isEmpty)
        XCTAssertEqual(sut.detectionState, .completed)
        XCTAssertNotNil(sut.lastDetectionTime)
    }
    
    // MARK: - Pattern Validation Tests
    func testPatternValidation() async throws {
        let pattern = createMockPattern()
        
        let validation = try await sut.validatePattern(pattern)
        
        XCTAssertTrue(validation.isValid)
        XCTAssertGreaterThan(validation.confidence, 0)
    }
    
    // MARK: - Pattern Ranking Tests
    func testPatternRanking() async {
        let patterns = [
            createMockPattern(strength: 0.8),
            createMockPattern(strength: 0.5),
            createMockPattern(strength: 0.9)
        ]
        
        let rankedPatterns = await sut.rankPatterns(patterns)
        
        XCTAssertEqual(rankedPatterns.count, 3)
        XCTAssertGreaterThan(rankedPatterns<source_id data="0" title="README.md" />.score, rankedPatterns<source_id data="1" title="ContentView.swift" />.score)
    }
    
    // MARK: - Pattern Insights Tests
    func testPatternInsights() async throws {
        let pattern = createMockPattern()
        
        let insights = try await sut.getPatternInsights(pattern)
        
        XCTAssertFalse(insights.isEmpty)
        XCTAssertTrue(insights.allSatisfy { $0.confidence > 0 })
    }
    
    // MARK: - Concurrent Detection Tests
    func testConcurrentDetection() async throws {
        let expectation = expectation(description: "Concurrent detection")
        expectation.expectedFulfillmentCount = 2
        
        async let detection1 = detectAndVerify(expectation)
        async let detection2 = detectAndVerify(expectation)
        
        await _ = [detection1, detection2]
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Error Handling Tests
    func testInsufficientDataError() async {
        mockStorage.mockAnalytics = [] // Empty data
        
        do {
            _ = try await sut.detectPatterns()
            XCTFail("Expected insufficient data error")
        } catch PatternDetectionError.insufficientData {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    func testDetectionPerformance() {
        measure {
            let expectation = expectation(description: "Detection performance")
            
            Task {
                do {
                    mockStorage.mockAnalytics = createMockAnalytics(count: 1000)
                    _ = try await self.sut.detectPatterns()
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Helper Methods
    private func detectAndVerify(_ expectation: XCTestExpectation) async {
        do {
            _ = try await sut.detectPatterns()
            expectation.fulfill()
        } catch PatternDetectionError.alreadyProcessing {
            expectation.fulfill() // Expected for concurrent detection
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    private func createMockAnalytics(count: Int = 10) -> [CravingAnalytics] {
        return (0..<count).map { _ in
            CravingAnalytics.mock()
        }
    }
    
    private func createMockPattern(strength: Double = 0.8) -> DetectedPattern {
        return DetectedPattern(
            id: UUID(),
            type: .time,
            name: "Test Pattern",
            description: "Test Description",
            frequency: 0.7,
            strength: strength,
            metadata: PatternMetadata(),
            timeRange: DateInterval(start: Date(), end: Date())
        )
    }
}

// MARK: - Mock Types
class MockAnalyticsStorage: AnalyticsStorage {
    var mockAnalytics: [CravingAnalytics] = []
    
    override func fetchRange(_ dateRange: DateInterval) async throws -> [CravingAnalytics] {
        return mockAnalytics
    }
}
