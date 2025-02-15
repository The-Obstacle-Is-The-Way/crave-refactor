//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsModel.swift
//  Purpose
//
//

import Foundation
import SwiftData

// MARK: - AnalyticsMetadata Model
@Model
final class AnalyticsMetadata {
    // MARK: - Core Properties
    var id: UUID
    var cravingId: UUID
    var timestamp: Date

    // MARK: - Time-based Metrics
    var timeOfDay: TimeOfDay
    var dayOfWeek: DayOfWeek
    var weekNumber: Int
    var monthNumber: Int
    var year: Int

    // MARK: - Session Data
    var sessionDuration: TimeInterval
    var interactionCount: Int

    // MARK: - Transformed Complex Data
    @Attribute(.transformable(by: UserActionsTransformer.self))
    var userActions: [UserAction]

    @Attribute(.transformable(by: PatternIdentifiersTransformer.self))
    var patternIdentifiers: [String]

    @Attribute(.transformable(by: CorrelationFactorsTransformer.self))
    var correlationFactors: [CorrelationFactor]

    @Attribute(.transformable(by: StreakDataTransformer.self))
    var streakData: StreakData

    // MARK: - Processing Status
    var processingState: ProcessingState
    var lastProcessed: Date
    var processingAttempts: Int

    // MARK: - Relationships
    @Relationship(inverse: \CravingModel.analyticsMetadata)
    var craving: CravingModel?

    // MARK: - Initialization
    init(cravingId: UUID) {
        self.id = UUID()
        self.cravingId = cravingId
        self.timestamp = Date()
        self.timeOfDay = TimeOfDay.current
        self.dayOfWeek = DayOfWeek.current
        self.weekNumber = Calendar.current.component(.weekOfYear, from: Date())
        self.monthNumber = Calendar.current.component(.month, from: Date())
        self.year = Calendar.current.component(.year, from: Date())
        self.sessionDuration = 0
        self.interactionCount = 0
        self.userActions = []
        self.patternIdentifiers = []
        self.correlationFactors = []
        self.streakData = StreakData()
        self.processingState = .pending
        self.lastProcessed = Date()
        self.processingAttempts = 0
    }
}

// MARK: - Supporting Types
extension AnalyticsMetadata {
    enum TimeOfDay: String, Codable {
        case morning    // 5:00 - 11:59
        case afternoon // 12:00 - 16:59
        case evening   // 17:00 - 21:59
        case night     // 22:00 - 4:59

        static var current: TimeOfDay {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 5..<12: return .morning
            case 12..<17: return .afternoon
            case 17..<22: return .evening
            default: return .night
            }
        }
    }

    enum DayOfWeek: String, Codable {
        case sunday, monday, tuesday, wednesday, thursday, friday, saturday

        static var current: DayOfWeek {
            let weekday = Calendar.current.component(.weekday, from: Date())
            switch weekday {
            case 1: return .sunday
            case 2: return .monday
            case 3: return .tuesday
            case 4: return .wednesday
            case 5: return .thursday
            case 6: return .friday
            case 7: return .saturday
            default: fatalError("Invalid weekday component")
            }
        }
    }

    struct UserAction: Codable {
        let timestamp: Date
        let actionType: ActionType
        let metadata: [String: String]

        enum ActionType: String, Codable {
            case viewEntry
            case createEntry
            case modifyEntry
            case deleteEntry
            case viewAnalytics
            case exportData
        }
    }

    struct CorrelationFactor: Codable {
        let factor: String
        let correlation: Double // -1.0 to 1.0
        let confidence: Double // 0.0 to 1.0
        let sampleSize: Int
    }

    struct StreakData: Codable {
        var currentStreak: Int = 0
        var longestStreak: Int = 0
        var totalStreaks: Int = 0
        var streakHistory: [StreakPeriod] = []

        struct StreakPeriod: Codable {
            let startDate: Date
            let endDate: Date
            let duration: Int
        }
    }

    enum ProcessingState: String, Codable {
        case pending
        case processing
        case completed
        case failed
    }
}

// MARK: - Value Transformers
class UserActionsTransformer: ValueTransformer, NSSecureCoding { // Added NSSecureCoding
    static var supportsSecureCoding = true

    override func transformedValue(_ value: Any?) -> Any? {
        guard let actions = value as? [AnalyticsMetadata.UserAction] else { return nil }
        return try? JSONEncoder().encode(actions)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([AnalyticsMetadata.UserAction].self, from: data)
    }

    required init?(coder: NSCoder) { // Added required initializer
        super.init()
    }

    override func encode(with coder: NSCoder) { // Added encode method
    }
}

class PatternIdentifiersTransformer: ValueTransformer, NSSecureCoding { // Added NSSecureCoding
    static var supportsSecureCoding = true
    override func transformedValue(_ value: Any?) -> Any? {
        guard let patterns = value as? [String] else { return nil }
        return try? JSONEncoder().encode(patterns)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([String].self, from: data)
    }
    required init?(coder: NSCoder) { // Added required initializer
        super.init()
    }

    override func encode(with coder: NSCoder) { // Added encode method
    }
}

class CorrelationFactorsTransformer: ValueTransformer, NSSecureCoding { // Added NSSecureCoding
    static var supportsSecureCoding = true
    override func transformedValue(_ value: Any?) -> Any? {
        guard let factors = value as? [AnalyticsMetadata.CorrelationFactor] else { return nil }
        return try? JSONEncoder().encode(factors)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([AnalyticsMetadata.CorrelationFactor].self, from: data)
    }
    required init?(coder: NSCoder) { // Added required initializer
        super.init()
    }

    override func encode(with coder: NSCoder) { // Added encode method
    }
}

class StreakDataTransformer: ValueTransformer, NSSecureCoding { // Added NSSecureCoding
    static var supportsSecureCoding = true
    override func transformedValue(_ value: Any?) -> Any? {
        guard let streakData = value as? AnalyticsMetadata.StreakData else { return nil }
        return try? JSONEncoder().encode(streakData)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode(AnalyticsMetadata.StreakData.self, from: data)
    }
    required init?(coder: NSCoder) { // Added required initializer
        super.init()
    }

    override func encode(with coder: NSCoder) { // Added encode method
    }
}


// MARK: - Analytics Processing (This part was moved from AnalyticsMetadata to AnalyticsManager - Correct place for processing logic)
extension AnalyticsManager { // Changed extension to AnalyticsManager - Processing will be handled by manager

}

