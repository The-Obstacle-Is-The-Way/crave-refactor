// Core/Domain/Entities/Analytics/BasicAnalyticsResult.swift

import Foundation

/// Represents aggregated analytics data derived from logged cravings.
public struct BasicAnalyticsResult {
    // MARK: - Core Metrics
    /// Total number of cravings logged.
    public let totalCravings: Int
    /// Total number of cravings that were successfully resisted.
    public let totalResisted: Int
    /// The average reported intensity of cravings, if available.
    public let averageIntensity: Double?
    
    // MARK: - Time-Based Analytics
    /// A mapping of dates to the number of cravings logged on that day.
    public let cravingsByDate: [Date: Int]
    /// A mapping of each hour (0–23) to the number of cravings logged during that hour.
    public let cravingsByHour: [Int: Int]
    /// A mapping of each weekday (1 for Sunday, 7 for Saturday) to the number of cravings logged.
    public let cravingsByWeekday: [Int: Int]
    
    // MARK: - Pattern Analysis
    /// A dictionary counting the occurrences of common triggers (e.g., "stress", "boredom").
    public let commonTriggers: [String: Int]
    /// An array of recurring time-based patterns detected in the data.
    public let timePatterns: [TimePattern]
    /// An array of patterns detected by more advanced analytics.
    public let detectedPatterns: [DetectedPattern]
    
    // MARK: - Computed Properties
    /// The success rate of resisting cravings.
    public var successRate: Double {
        guard totalCravings > 0 else { return 0.0 }
        return Double(totalResisted) / Double(totalCravings)
    }
    
    /// The top three hours with the highest frequency of logged cravings.
    public var peakHours: [Int] {
        cravingsByHour.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }
    
    /// Creates a new instance of aggregated analytics.
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
    /// Represents a recurring pattern based on time.
    public struct TimePattern: Equatable {
        /// The hour of the day (0–23) when the pattern occurs.
        public let hour: Int
        /// Frequency count for that hour.
        public let frequency: Int
        /// Confidence level (0.0 to 1.0) that this pattern is significant.
        public let confidence: Double
        
        /// Returns true if the pattern is considered significant.
        public var isSignificant: Bool {
            confidence >= 0.7 && frequency >= 3
        }
    }
    
    /// Represents a pattern detected from the data.
    public struct DetectedPattern: Equatable {
        /// The type of pattern detected.
        public let type: PatternType
        /// A descriptive summary of the pattern.
        public let description: String
        /// Confidence level (0.0 to 1.0) that the pattern is valid.
        public let confidence: Double
        /// Any supporting data or additional details.
        public let supportingData: [String: Any]
    }
    
    /// Enumerates the types of patterns that can be detected.
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
    /// Returns an empty analytics result.
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
    
    /// Returns a mock analytics result for testing and previews.
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

// MARK: - Analysis Methods
extension BasicAnalyticsResult {
    /// Returns a formatted string for the most active (peak) time slot.
    public func getMostActiveTimeSlot() -> String {
        guard let peak = peakHours.first else { return "No data" }
        // Construct a date using today's year, month, and day, but with the peak hour.
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = peak
        let dateWithPeakHour = Calendar.current.date(from: components) ?? Date()
        return DateFormatter.timeFormatter.string(from: dateWithPeakHour)
    }
    
    /// Filters and returns only the detected patterns that meet a significance threshold.
    public func getSignificantPatterns() -> [DetectedPattern] {
        detectedPatterns.filter { $0.confidence >= 0.7 }
    }
    
    /// Returns a summary of insights from the analytics.
    public func getInsightSummary() -> String {
        var insights: [String] = []
        
        if let mostCommonTrigger = commonTriggers.max(by: { $0.value < $1.value }) {
            insights.append("Most common trigger: \(mostCommonTrigger.key)")
        }
        
        if let peak = peakHours.first {
            insights.append("Peak craving time: \(peak):00")
        }
        
        return insights.joined(separator: "\n")
    }
}

// MARK: - Date Formatter Helper
private extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"  // e.g., "2PM"
        return formatter
    }()
}

