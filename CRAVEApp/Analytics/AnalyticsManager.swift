// File: AnalyticsManager.swift
// Purpose: Central manager for all analytics operations and data processing

import Foundation
import SwiftData
import Combine

@MainActor
final class AnalyticsManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentAnalytics: AnalyticsSnapshot?
    @Published private(set) var processingState: ProcessingState = .idle
    @Published private(set) var lastUpdateTime: Date?
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    private let analyticsStorage: AnalyticsStorage
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Analytics Processors
    private let frequencyAnalyzer: FrequencyAnalyzer
    private let patternAnalyzer: PatternAnalyzer
    private let insightGenerator: InsightGenerator
    private let predictionEngine: PredictionEngine
    
    // Rest of AnalyticsManager.swift implementation...
    [Previous implementation continues...]
}

// File: CalendarViewQuery.swift
// Purpose: Handles calendar-based analytics queries

import Foundation

struct CalendarViewQuery {
    func cravingsPerDay(using cravings: [CravingModel]) -> [Date: Int] {
        let calendar = Calendar.current
        let groupedCravings = Dictionary(grouping: cravings) { craving in
            calendar.startOfDay(for: craving.timestamp)
        }
        return groupedCravings.mapValues { $0.count }
    }
    
    func getWeeklyTrend(using cravings: [CravingModel]) -> [(week: Date, count: Int)] {
        let calendar = Calendar.current
        let groupedByWeek = Dictionary(grouping: cravings) { craving in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: craving.timestamp))!
        }
        return groupedByWeek.map { (week: $0.key, count: $0.value.count) }
            .sorted { $0.week < $1.week }
    }
}

// File: FrequencyQuery.swift
// Purpose: Handles frequency-based analytics queries

import Foundation

struct FrequencyQuery {
    func cravingsPerDay(using cravings: [CravingModel]) -> [Date: Int] {
        let groupedCravings = Dictionary(grouping: cravings) { $0.timestamp.onlyDate }
        return groupedCravings.mapValues { $0.count }
    }
}

// File: TimeOfDayQuery.swift
// Purpose: Handles time-based analytics queries

import Foundation
import SwiftData

struct TimeOfDayQuery {
    enum TimeSlot: String, CaseIterable {
        case earlyMorning = "Early Morning" // 5-8
        case morning = "Morning" // 8-11
        case midday = "Midday" // 11-14
        case afternoon = "Afternoon" // 14-17
        case evening = "Evening" // 17-20
        case night = "Night" // 20-23
        case lateNight = "Late Night" // 23-5
        
        static func from(hour: Int) -> TimeSlot {
            switch hour {
            case 5..<8: return .earlyMorning
            case 8..<11: return .morning
            case 11..<14: return .midday
            case 14..<17: return .afternoon
            case 17..<20: return .evening
            case 20..<23: return .night
            default: return .lateNight
            }
        }
    }
    
    func cravingsByTimeSlot(using cravings: [CravingModel]) -> [String: Int] {
        var slots = Dictionary(uniqueKeysWithValues: TimeSlot.allCases.map { ($0.rawValue, 0) })
        
        for craving in cravings {
            let hour = Calendar.current.component(.hour, from: craving.timestamp)
            let slot = TimeSlot.from(hour: hour)
            slots[slot.rawValue, default: 0] += 1
        }
        
        return slots
    }
}

// File: AnalyticsStorage.swift
// Purpose: Manages persistent storage of analytics data with caching and optimization

[Previous AnalyticsStorage.swift implementation...]

// File: BasicAnalyticsResult.swift
// Purpose: Defines the basic analytics result structure

import Foundation

struct BasicAnalyticsResult {
    let cravingsByFrequency: [Date: Int]
    let cravingsPerDay: [Date: Int]
    let cravingsByTimeSlot: [String: Int]
}

// File: CRAVEDesignSystem.swift
// Purpose: Centralized design system for CRAVE

import UIKit
import SwiftUI

enum CRAVEDesignSystem {
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    }

    enum Typography {
        static let titleFont    = Font.system(size: 20, weight: .bold)
        static let headingFont  = Font.system(size: 17, weight: .semibold)
        static let bodyFont     = Font.system(size: 16, weight: .regular)
        static let captionFont  = Font.system(size: 14, weight: .regular)
    }

    enum Layout {
        static let standardPadding: CGFloat = 16
        static let compactPadding: CGFloat  = 8
        static let buttonHeight: CGFloat    = 50
        static let textFieldHeight: CGFloat = 40
        static let cornerRadius: CGFloat    = 8
    }

    enum Animation {
        static let standardDuration = 0.3
        static let quickDuration    = 0.2
    }

    enum Haptics {
        static func success() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        static func warning() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        static func error() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}
