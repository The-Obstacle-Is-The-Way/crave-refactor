//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsInsight.swift
//  Purpose: Defines the insight generation system for analytics data
//
//

import Foundation

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
        case .timePattern, .locationPattern, .triggerPattern: return 0.7
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
