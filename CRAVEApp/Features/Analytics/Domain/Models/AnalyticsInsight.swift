//
//  🍒
//  CRAVEApp/Analytics/AnalyticsInsight.swift
//  Purpose: Defines the insight generation system for analytics data
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
    let source: InsightSource
    var dataPoints: Int
    var timeRange: DateInterval?
    var relatedInsights: [UUID]
    var tags: Set<String>
    
    init(
        source: InsightSource = .analytics,
        dataPoints: Int = 0,
        timeRange: DateInterval? = nil,
        relatedInsights: [UUID] = [],
        tags: Set<String> = []
    ) {
        self.source = source
        self.dataPoints = dataPoints
        self.timeRange = timeRange
        self.relatedInsights = relatedInsights
        self.tags = tags
    }

    enum InsightSource: String, Codable {
        case analytics
        case userFeedback
        case system
        case manual
    }
}

struct InsightRecommendation: Identifiable, Codable {
    let id: UUID
    let title: String
    let action: String
    let priority: Priority
    let difficulty: Difficulty
    
    init(
        id: UUID = UUID(),
        title: String,
        action: String,
        priority: Priority,
        difficulty: Difficulty
    ) {
        self.id = id
        self.title = title
        self.action = action
        self.priority = priority
        self.difficulty = difficulty
    }

    enum Priority: Int, Codable, Comparable {
        case low = 1
        case medium = 2
        case high = 3
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    enum Difficulty: Int, Codable, Comparable {
        case easy = 1
        case moderate = 2
        case challenging = 3
        
        static func < (lhs: Difficulty, rhs: Difficulty) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    func validate() -> Bool {
        !title.isEmpty && !action.isEmpty
    }
}

// MARK: - Helper Extensions

extension InsightRecommendation {
    var score: Double {
        Double(priority.rawValue * (4 - difficulty.rawValue)) / 6.0
    }
}

extension InsightMetadata {
    var isRecentInsight: Bool {
        guard let range = timeRange else { return false }
        return range.end.timeIntervalSinceNow < 86400 // 24 hours
    }
    
    var hasSignificantData: Bool {
        dataPoints >= 10
    }
}

extension AnalyticsInsight {
    var shouldBeHighlighted: Bool {
        confidence >= 0.8 && relevanceScore >= 0.7
    }
    
    var priorityRecommendations: [InsightRecommendation] {
        recommendations.filter { $0.priority == .high }
    }
}
