// File: AnalyticsFormatterTests.swift
// Purpose: Test suite for analytics formatting functionality

import XCTest
import SwiftUI
@testable import CRAVE

final class AnalyticsFormatterTests: XCTestCase {
    var sut: AnalyticsFormatter!
    
    override func setUp() {
        super.setUp()
        sut = AnalyticsFormatter(
            configuration: .preview,
            locale: Locale(identifier: "en_US"),
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(identifier: "UTC")!
        )
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Date Formatting Tests
    func testDateFormatting() {
        let date = Date(timeIntervalSince1970: 1623456789) // June 11, 2021
        
        // Test different styles
        XCTAssertEqual(
            sut.formatDate(date, style: .short),
            "6/11/21"
        )
        
        XCTAssertEqual(
            sut.formatDate(date, style: .medium),
            "Jun 11, 2021"
        )
        
        XCTAssertEqual(
            sut.formatDate(date, style: .long),
            "June 11, 2021"
        )
    }
    
    // MARK: - Time Formatting Tests
    func testTimeFormatting() {
        let date = Date(timeIntervalSince1970: 1623456789) // 15:33:09
        
        XCTAssertEqual(
            sut.formatTime(date, style: .short),
            "3:33 PM"
        )
        
        XCTAssertEqual(
            sut.formatTime(date, style: .medium),
            "3:33:09 PM"
        )
    }
    
    // MARK: - Number Formatting Tests
    func testNumberFormatting() {
        let number = 1234.5678
        
        XCTAssertEqual(
            sut.formatNumber(number, style: .decimal),
            "1,234.57"
        )
        
        XCTAssertEqual(
            sut.formatNumber(number, style: .scientific),
            "1.23457E3"
        )
    }
    
    // MARK: - Percentage Formatting Tests
    func testPercentageFormatting() {
        XCTAssertEqual(sut.formatPercentage(0.7532), "75.3%")
        XCTAssertEqual(sut.formatPercentage(1.0), "100%")
        XCTAssertEqual(sut.formatPercentage(0.0), "0%")
    }
    
    // MARK: - Duration Formatting Tests
    func testDurationFormatting() {
        let duration: TimeInterval = 7384 // 2 hours, 3 minutes, 4 seconds
        
        XCTAssertEqual(
            sut.formatDuration(duration),
            "2h 3m 4s"
        )
    }
    
    // MARK: - Pattern Formatting Tests
    func testPatternFormatting() {
        let pattern = DetectedPattern(
            id: UUID(),
            type: .time,
            name: "Evening Cravings",
            description: "Frequent cravings in the evening",
            frequency: 0.8,
            strength: 0.75,
            metadata: PatternMetadata(),
            timeRange: DateInterval(start: Date(), end: Date())
        )
        
        let formatted = sut.formatPattern(pattern)
        
        XCTAssertEqual(formatted.title, "Time-based Pattern")
        XCTAssertEqual(formatted.strength, "75%")
    }
    
    // MARK: - Insight Formatting Tests
    func testInsightFormatting() {
        let insight = AnalyticsInsight(
            id: UUID(),
            title: "Test Insight",
            description: "Test Description",
            confidence: 0.85,
            recommendations: ["Recommendation 1", "Recommendation 2"]
        )
        
        let formatted = sut.formatInsight(insight)
        
        XCTAssertEqual(formatted.confidence, "85%")
        XCTAssertEqual(formatted.recommendations.count, 2)
    }
    
    // MARK: - Chart Data Formatting Tests
    func testChartDataFormatting() {
        let dataPoints = [
            ChartDataPoint(
                date: Date(),
                value: 75.5,
                labelType: .value
            )
        ]
        
        let formatted = sut.formatChartData(dataPoints)
        
        XCTAssertEqual(formatted.first?.value, "75.5")
    }
    
    // MARK: - Frequency Formatting Tests
    func testFrequencyFormatting() {
        XCTAssertEqual(
            sut.formatFrequency(5, timeFrame: .daily),
            "5 per day"
        )
        
        XCTAssertEqual(
            sut.formatFrequency(12, timeFrame: .weekly),
            "12 per week"
        )
        
        XCTAssertEqual(
            sut.formatFrequency(30, timeFrame: .monthly),
            "30 per month"
        )
    }
    
    // MARK: - Intensity Formatting Tests
    func testIntensityFormatting() {
        XCTAssertEqual(sut.formatCravingIntensity(7), "7/10")
        XCTAssertEqual(sut.formatCravingIntensity(10), "10/10")
    }
    
    // MARK: - Performance Tests
    func testFormattingPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = sut.formatDate(Date())
                _ = sut.formatNumber(Double.random(in: 0...1000))
                _ = sut.formatPercentage(Double.random(in: 0...1))
            }
        }
    }
}

