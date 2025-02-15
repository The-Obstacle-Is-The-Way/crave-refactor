//
//
//  CRAVEApp/Data/Entities/AnalyticsMetadata.swift
//  Purpose:
//
//

import Foundation
import SwiftData

@Model
final class AnalyticsMetadata {
    // MARK: - Core Properties
    @Attribute(.unique) var id: UUID
    var cravingId: UUID // Keep this to link back to the CravingModel
    var timestamp: Date

    // MARK: - Time-based Metrics (Simplified)
    var timeOfDay: String // Store as String, use enum for calculations
    var dayOfWeek: String // Store as String
    var weekNumber: Int
    var monthNumber: Int
    var year: Int

    // MARK: - Session Data (Optional - Consider if really needed)
    var sessionDuration: TimeInterval
    var interactionCount: Int

    // MARK: - Complex Data (Stored as simple types or JSON)
    @Attribute(.transformable(by: UserActionsTransformer.self))
    var userActions: [UserAction]
    @Attribute(.transformable(by: PatternIdentifiersTransformer.self))
    var patternIdentifiers: [String]
    @Attribute(.transformable(by: CorrelationFactorsTransformer.self))
    var correlationFactors: [CorrelationFactor]
    @Attribute(.transformable(by: StreakDataTransformer.self))
    var streakData: StreakData

    // MARK: - Processing Status
    var processingState: String // Store as String, use enum for calculations
    var lastProcessed: Date
    var processingAttempts: Int

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade) // Consider if cascade is the right rule
    var craving: CravingModel? // Optional, inverse relationship

    // MARK: - Initialization
    init(cravingId: UUID) {
        self.id = UUID()
        self.cravingId = cravingId
        self.timestamp = Date()
        self.timeOfDay = TimeOfDay.current.rawValue
        self.dayOfWeek = DayOfWeek.current.rawValue
        self.weekNumber = Calendar.current.component(.weekOfYear, from: Date())
        self.monthNumber = Calendar.current.component(.month, from: Date())
        self.year = Calendar.current.component(.year, from: Date())
        self.sessionDuration = 0
        self.interactionCount = 0
        self.userActions = []
        self.patternIdentifiers = []
        self.correlationFactors = []
        self.streakData = StreakData()
        self.processingState = ProcessingState.pending.rawValue // Use rawValue
        self.lastProcessed = Date()
        self.processingAttempts = 0
    }
}

// MARK: - Supporting Types (Consolidated within the file)
extension AnalyticsMetadata {

    enum TimeOfDay: String, Codable, CaseIterable {
        case morning, afternoon, evening, night

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

    enum DayOfWeek: String, Codable, CaseIterable {
        case sunday, monday, tuesday, wednesday, thursday, friday, saturday

        static var current: DayOfWeek {
            let weekday = Calendar.current.component(.weekday, from: Date())
            // Swift's weekday starts with 1 (Sunday), adjust if needed
            switch weekday {
            case 1: return .sunday
            case 2: return .monday
            case 3: return .tuesday
            case 4: return .wednesday
            case 5: return .thursday
            case 6: return .friday
            case 7: return .saturday
            default: fatalError("Invalid weekday component") // Should never happen
            }
        }
    }

    struct UserAction: Codable {
        let timestamp: Date
        let actionType: String // Store as String, use enum for calculations
        let metadata: [String: String]
    }

    struct CorrelationFactor: Codable {
        let factor: String
        let correlation: Double // -1.0 to 1.0
        let confidence: Double // 0.0 to 1.0
        let sampleSize: Int
    }

    struct StreakData: Codable { // Removed from the main model.
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
    
    enum ProcessingState: String, Codable, CaseIterable { //added case iterable
        case pending, processing, completed, failed
    }
}
