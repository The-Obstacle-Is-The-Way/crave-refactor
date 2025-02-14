// File: AnalyticsInsight.swift
// Purpose: Defines the insight generation system for analytics data

import Foundation
import SwiftData

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
struct TimePatternInsight: AnalyticsInsight {
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
    private var insights: [AnalyticsInsight] = []
    
    init(configuration: InsightConfiguration = .default) {
        self.configuration = configuration
    }
    
    func generateInsights(from analytics: AnalyticsData) -> [AnalyticsInsight] {
        var newInsights: [AnalyticsInsight] = []
        
        // Generate time pattern insights
        if let timeInsight = generateTimePatternInsight(from: analytics) {
            newInsights.append(timeInsight)
        }
        
        // Generate other types of insights...
        
        // Filter and sort insights
        newInsights = filterInsights(newInsights)
        insights.append(contentsOf: newInsights)
        
        return newInsights
    }
    
    private func generateTimePatternInsight(from analytics: AnalyticsData) -> TimePatternInsight? {
        // Implement time pattern detection logic
        return nil
    }
    
    private func filterInsights(_ insights: [AnalyticsInsight]) -> [AnalyticsInsight] {
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
