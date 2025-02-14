// File: AnalyticsReporterTests.swift
// Purpose: Test suite for analytics reporting functionality

import XCTest
import SwiftData
@testable import CRAVE

final class AnalyticsReporterTests: XCTestCase {
    var sut: AnalyticsReporter!
    var storage: MockAnalyticsStorage!
    
    override func setUp() {
        super.setUp()
        storage = MockAnalyticsStorage()
        sut = AnalyticsReporter(
            configuration: .preview,
            storage: storage
        )
    }
    
    override func tearDown() {
        storage = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Report Generation Tests
    func testDailyReportGeneration() async throws {
        // Setup test data
        let today = Date()
        let timeRange = DateInterval(
            start: Calendar.current.startOfDay(for: today),
            end: today
        )
        
        // Generate report
        let report = try await sut.generateReport(
            type: .daily,
            timeRange: timeRange
        )
        
        // Verify report
        XCTAssertEqual(report.type, .daily)
        XCTAssertEqual(report.timeRange, timeRange)
        XCTAssertNotNil(report.data)
        XCTAssertEqual(sut.generationState, .completed)
        XCTAssertEqual(sut.generationProgress, 1.0)
    }
    
    // MARK: - Report Cache Tests
    func testReportCaching() async throws {
        let timeRange = DateInterval(
            start: Date().addingTimeInterval(-86400),
            end: Date()
        )
        
        // Generate first report
        let report1 = try await sut.generateReport(
            type: .daily,
            timeRange: timeRange
        )
        
        // Generate second report (should use cache)
        let report2 = try await sut.generateReport(
            type: .daily,
            timeRange: timeRange
        )
        
        // Verify cache usage
        XCTAssertEqual(report1.id, report2.id)
        XCTAssertEqual(storage.fetchCount, 1) // Should only fetch once
    }
    
    // MARK: - Export Tests
    func testJSONExport() async throws {
        // Generate report
        let report = try await sut.generateReport(
            type: .daily,
            timeRange: DateInterval(start: Date(), end: Date())
        )
        
        // Export to JSON
        let jsonData = try await sut.exportReport(report, to: .json)
        
        // Verify JSON
        XCTAssertNotNil(jsonData)
        let decodedReport = try JSONDecoder().decode(Report.self, from: jsonData)
        XCTAssertEqual(decodedReport.id, report.id)
    }
    
    func testCSVExport() async throws {
        let report = try await sut.generateReport(
            type: .daily,
            timeRange: DateInterval(start: Date(), end: Date())
        )
        
        let csvData = try await sut.exportReport(report, to: .csv)
        XCTAssertNotNil(csvData)
        // Add more specific CSV format verification
    }
    
    // MARK: - Error Handling Tests
    func testInvalidTimeRange() async {
        let invalidTimeRange = DateInterval(
            start: Date(),
            end: Date().addingTimeInterval(-86400) // End before start
        )
        
        do {
            _ = try await sut.generateReport(
                type: .daily,
                timeRange: invalidTimeRange
            )
            XCTFail("Expected invalid time range error")
        } catch ReportError.invalidTimeRange {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Progress Tracking Tests
    func testProgressTracking() async throws {
        var progressUpdates: [Double] = []
        
        let progressExpectation = expectation(description: "Progress updates")
        let cancellable = sut.$generationProgress
            .sink { progress in
                progressUpdates.append(progress)
                if progress == 1.0 {
                    progressExpectation.fulfill()
                }
            }
        
        // Generate report
        _ = try await sut.generateReport(
            type: .daily,
            timeRange: DateInterval(start: Date(), end: Date())
        )
        
        await fulfillment(of: [progressExpectation], timeout: 5.0)
        cancellable.cancel()
        
        // Verify progress updates
        XCTAssertGreaterThan(progressUpdates.count, 1)
        XCTAssertEqual(progressUpdates.last, 1.0)
    }
    
    // MARK: - Performance Tests
    func testReportGenerationPerformance() throws {
        measure {
            let expectation = expectation(description: "Report generation")
            
            Task {
                do {
                    _ = try await self.sut.generateReport(
                        type: .daily,
                        timeRange: DateInterval(start: Date(), end: Date())
                    )
                    expectation.fulfill()
                } catch {
                    XCTFail("Report generation failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
}

// MARK: - Mock Types
class MockAnalyticsStorage: AnalyticsStorage {
    var fetchCount = 0
    
    override func fetchRange(_ dateRange: DateInterval) async throws -> [CravingAnalytics] {
        fetchCount += 1
        return [CravingAnalytics.mock()]
    }
}

extension CravingAnalytics {
    static func mock() -> CravingAnalytics {
        CravingAnalytics(
            id: UUID(),
            timestamp: Date(),
            intensity: 5,
            triggers: ["test"],
            metadata: [:]
        )
    }
}
