// CRAVE/Tests/CRAVETests/ContextualDataTests.swift

import XCTest
@testable import CRAVE

final class ContextualDataTests: XCTestCase {
    var sut: ContextualData!
    
    override func setUp() {
        super.setUp()
        sut = ContextualData(cravingId: UUID())
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.timeContext)
        XCTAssertTrue(sut.environmentalFactors.isEmpty)
    }
    
    // MARK: - Context Analysis Tests
    func testContextAnalysis() {
        let analysis = sut.analyzeContext()
        XCTAssertNotNil(analysis)
        XCTAssertTrue(analysis.overallRisk >= 0 && analysis.overallRisk <= 1)
    }
    
    // Add more tests for each context type...
}
