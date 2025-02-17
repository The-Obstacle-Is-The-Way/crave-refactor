// Core/Domain/Entities/Analytics/BasicAnalyticsResult.swift

import Foundation

/// Represents aggregated analytics data derived from logged cravings.
public struct BasicAnalyticsResult {
    // MARK: - Core Metrics
    public let totalCravings: Int
    public let totalResisted: Int
    public let averageIntensity: Double?
    
    // MARK: - Time-Based Analytics
    public let cravingsByDate: [Date: Int]
    public let cravingsByHour: [Int: Int]
    public let cravingsByWeekday: [Int: Int]
    
    // MARK: - Pattern Analysis
    public let commonTriggers: [String: Int]
    public let timePatterns: [TimePattern]
    public let detectedPatterns: [DetectedPattern]
    
    // MARK: - Computed Properties
    public var successRate: Double {
        guard totalCravings > 0 else { return 0.0 }
        return Double(totalResisted) / Double(totalCravings)
    }
    
    public var peakHours: [Int] {
        cravingsByHour.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }
    
    public init(totalCravings: Int,
                totalResisted: Int,
                averageIntensity: Double?,
                cravingsByDate: [Date: Int],
                cravingsByHour: [Int: Int],
                cravingsByWeekday: [Int: Int],
                commonTriggers: [String: Int],
                timePatterns: [TimePattern],
                detectedPatterns: [DetectedPattern]) {
        self.totalCravings = totalCravings
        self.totalResisted = totalResisted
        self.averageIntensity = averageIntensity
        self.cravingsByDate = cravingsByDate
        self.cravingsByHour = cravingsByHour
        self.cravingsByWeekday = cravingsByWeekday
        self.commonTriggers = commonTriggers
        self.timePatterns = timePatterns
        self.detectedPatterns = detectedPatterns
    }
}

// MARK: - Supporting Types
extension BasicAnalyticsResult {
    public struct TimePattern: Equatable {
        public let hour: Int
        public let frequency: Int
        public let confidence: Double
        
        public var isSignificant: Bool {
            confidence >= 0.7 && frequency >= 3
        }
    }
    
    public struct DetectedPattern: Equatable {
        public let type: PatternType
        public let description: String
        public let confidence: Double
        public let supportingData: [String: Any]
    }
    
    public enum PatternType: String {
        case timeOfDay = "time_of_day"
        case dayOfWeek = "day_of_week"
        case trigger = "trigger"
        case sequence = "sequence"
        case intensity = "intensity"
    }
}

// MARK: - Factory Methods
extension BasicAnalyticsResult {
    public static var empty: BasicAnalyticsResult {
        BasicAnalyticsResult(
            totalCravings: 0,
            totalResisted: 0,
            averageIntensity: nil,
            cravingsByDate: [:],
            cravingsByHour: [:],
            cravingsByWeekday: [:],
            commonTriggers: [:],
            timePatterns: [],
            detectedPatterns: []
        )
    }
    
    public static func mock(forTesting: Bool = false) -> BasicAnalyticsResult {
        BasicAnalyticsResult(
            totalCravings: 42,
            totalResisted: 28,
            averageIntensity: 6.5,
            cravingsByDate: [Date(): 5],
            cravingsByHour: [14: 8, 16: 6, 18: 4],
            cravingsByWeekday: [1: 6, 3: 8, 5: 7],
            commonTriggers: ["stress": 12, "boredom": 8],
            timePatterns: [TimePattern(hour: 14, frequency: 8, confidence: 0.85)],
            detectedPatterns: [
                DetectedPattern(
                    type: .timeOfDay,
                    description: "Afternoon peak between 2-4 PM",
                    confidence: 0.85,
                    supportingData: [:]
                )
            ]
        )
    }
}

