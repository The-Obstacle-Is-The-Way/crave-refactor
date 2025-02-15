//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsInsight.swift
//  Purpose: Defines the insight generation system for analytics data
//
//

import Foundation
import SwiftData
import SwiftUI // Keep SwiftUI import

// MARK: - Insight Protocol
protocol AnalyticsInsight: Identifiable, Codable {
    var id: UUID { get }
    var type: InsightType { get }
    var title: String { get }
    var description: String { get }
    var confidence: Double { get }
    var timestamp: Date { get }
    var relevanceScore: Double { get }
    var metadata: InsightMetadata { get }
    var recommendations: [InsightRecommendation] { get }

    func validate() -> Bool
    func calculateRelevance() -> Double
}

// MARK: - Base Insight Implementation
struct BaseInsight: AnalyticsInsight {
    let id: UUID
    let type: InsightType
    let title: String
    let description: String
    let confidence: Double
    let timestamp: Date
    var relevanceScore: Double
    let metadata: InsightMetadata
    var recommendations: [InsightRecommendation]

    init(
        type: InsightType,
        title: String,
        description: String,
        confidence: Double,
        metadata: InsightMetadata = InsightMetadata(),
        recommendations: [InsightRecommendation] = []
    ) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.timestamp = Date()
        self.relevanceScore = 0.0
        self.metadata = metadata
        self.recommendations = recommendations

        self.relevanceScore = calculateRelevance()
    }

    func validate() -> Bool {
        guard !title.isEmpty, !description.isEmpty else { return false }
        guard confidence >= 0 && confidence <= 1 else { return false }
        guard recommendations.allSatisfy({ $0.validate() }) else { return false }
        return true
    }

    func calculateRelevance() -> Double {
        let timeDecay = calculateTimeDecay()
        let confidenceFactor = confidence
        let importanceFactor = type.importanceWeight

        return timeDecay * confidenceFactor * importanceFactor
    }

    private func calculateTimeDecay() -> Double {
        let hoursSinceGeneration = Date().timeIntervalSince(timestamp) / 3600
        return exp(-hoursSinceGeneration / 24) // Decay over 24 hours
    }
}

// MARK: - Specific Insight Types
struct TimePatternInsight: AnalyticsInsight { // ✅ Conformed to AnalyticsInsight Protocol
    let id: UUID = UUID()
    let type: InsightType = .timePattern
    let title: String
    let description: String
    let confidence: Double
    let timestamp: Date = Date()
    var relevanceScore: Double
    let metadata: InsightMetadata
    var recommendations: [InsightRecommendation]

    let peakHours: [Int]
    let averageIntensity: Double

    init(peakHours: [Int], averageIntensity: Double, confidence: Double) {
        self.peakHours = peakHours
        self.averageIntensity = averageIntensity
        self.confidence = confidence
        self.metadata = InsightMetadata()
        self.recommendations = []

        self.title = "Time-based Craving Pattern Detected"
        self.description = generateDescription()
        self.relevanceScore = calculateRelevance()

        generateRecommendations()
    }

    private func generateDescription() -> String {
        let formattedHours = peakHours
            .map { String(format: "%02d:00", $0) }
            .joined(separator: ", ")

        return "You tend to experience cravings around \(formattedHours) with an average intensity of \(String(format: "%.1f", averageIntensity))/10"
    }

    private func generateRecommendations() {
        // Generate time-specific recommendations
    }

    func validate() -> Bool {
        guard !peakHours.isEmpty else { return false }
        guard averageIntensity >= 0 && averageIntensity <= 10 else { return false }
        return true
    }

    func calculateRelevance() -> Double {
        let baseRelevance = confidence * type.importanceWeight
        let intensityFactor = averageIntensity / 10.0
        return baseRelevance * intensityFactor
    }
}

// MARK: - Supporting Types
enum InsightType: String, Codable {
    case timePattern
    case locationPattern
    case triggerPattern
    case behaviorChange
    case milestone
    case warning

    var importanceWeight: Double {
        switch self {
        case .warning: return 1.0
        case .milestone: return 0.9
        case .behaviorChange: return 0.8
        case .timePattern: return 0.7
        case .locationPattern: return 0.7
        case .triggerPattern: return 0.7
        }
    }
}

struct InsightMetadata: Codable {
    var dataPoints: Int = 0
    var timeRange: DateInterval?
    var relatedInsights: [UUID] = []
    var tags: Set<String> = []
    var source: InsightSource = .analytics

    enum InsightSource: String, Codable {
        case analytics
        case userFeedback
        case system
        case manual
    }
}

struct InsightRecommendation: Codable {
    let id: UUID = UUID()
    let title: String
    let action: String
    let priority: Priority
    let difficulty: Difficulty

    enum Priority: Int, Codable {
        case low = 1
        case medium = 2
        case high = 3
    }

    enum Difficulty: Int, Codable {
        case easy = 1
        case moderate = 2
        case challenging = 3
    }

    func validate() -> Bool {
        return !title.isEmpty && !action.isEmpty
    }
}

// MARK: - Insight Generator
class InsightGenerator {
    private let configuration: InsightConfiguration
    private var insights: [any AnalyticsInsight] = [] // ✅ Use 'any AnalyticsInsight'

    init(configuration: InsightConfiguration = .default) {
        self.configuration = configuration
    }

    func generateInsights(from analyticsData: [CravingAnalytics]) -> [any AnalyticsInsight] { // ✅ Use 'any AnalyticsInsight'
        var newInsights: [any AnalyticsInsight] = [] // ✅ Use 'any AnalyticsInsight'

        // Generate time pattern insights
        if let timeInsight = generateTimePatternInsight(from: analyticsData) {
            newInsights.append(timeInsight)
        }

        // Generate other types of insights...

        // Filter and sort insights
        newInsights = filterInsights(newInsights)
        insights.append(contentsOf: newInsights)

        return newInsights
    }

    private func generateTimePatternInsight(from analyticsData: [CravingAnalytics]) -> TimePatternInsight? {
        // Implement time pattern detection logic using analyticsData
        // 1. Group cravings by hour of the day.
        let cravingsByHour = Dictionary(grouping: analyticsData, by: {
            Calendar.current.component(.hour, from: $0.timestamp)
        })

        // 2. Find the hours with the most cravings.  (This is a *very* basic
        //    example.  You'd likely want to use a more sophisticated
        //    statistical approach.)
        let sortedByCount = cravingsByHour.sorted { $0.value.count > $1.value.count }
        guard let (peakHour, cravings) = sortedByCount.first else {
            return nil // No data
        }

        let peakHours: [Int]
        //Added this condition to include cravings that happened in the surrounding hour
        if let secondPeak = sortedByCount.dropFirst().first, Double(secondPeak.value.count) / Double(cravings.count) > 0.60 {
            peakHours = [peakHour, secondPeak.key].sorted()
        } else{
            peakHours = [peakHour]
        }


        // 3. Calculate the average intensity for those hours.
        let totalIntensity = cravings.reduce(0) { $0 + $1.intensity }
        let averageIntensity = Double(totalIntensity) / Double(cravings.count)

        // 4.  Create an insight if the count is above a threshold.  (This
        //     threshold would ideally be determined through data analysis
        //     and potentially user-specific.)
        let confidence: Double = Double(cravings.count) / 15.0 //Made a basic confidence measure
        guard cravings.count >= 3 else { // Example threshold
            return nil
        }

        // 5.  Create and return the insight.
        return TimePatternInsight(peakHours: peakHours, averageIntensity: Double(averageIntensity), confidence: confidence)
    }

    private func filterInsights(_ insights: [any AnalyticsInsight]) -> [any AnalyticsInsight] { // ✅ Use 'any AnalyticsInsight'
        insights
            .filter { $0.validate() }
            .filter { $0.confidence >= configuration.minimumConfidence }
            .sorted { $0.relevanceScore > $1.relevanceScore }
            .prefix(configuration.maximumInsights)
            .map { $0 }
    }
}

// MARK: - Configuration
struct InsightConfiguration {
    let minimumConfidence: Double
    let maximumInsights: Int
    let relevanceThreshold: Double

    static let `default` = InsightConfiguration(
        minimumConfidence: 0.6,
        maximumInsights: 10,
        relevanceThreshold: 0.3
    )
}

// MARK: - Testing Support
extension BaseInsight {
    static func mock() -> BaseInsight {
        BaseInsight(
            type: .timePattern,
            title: "Test Insight",
            description: "Test Description",
            confidence: 0.8
        )
    }
}

