//
//
// CRAVEApp/Analytics/AnalyticsManager.swift
// // Purpose: Central manager for all analytics operations and data processing
//
//

import Foundation
import SwiftData
import Combine // Add Combine import

@MainActor
class AnalyticsManager: ObservableObject { // Added ObservableObject
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getBasicStats() async -> BasicAnalyticsResult { // No 'throws' as we handle errors internally
        do {
            let fetchDescriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let allCravings = try modelContext.fetch(fetchDescriptor)

            // Use helper functions for clarity and testability
            let cravingsByFrequency = cravingsPerDay(using: allCravings)
            let cravingsPerDay = cravingsByDate(using: allCravings)  // Consistent naming
            let cravingsByTimeSlot = cravingsByTimeOfDay(using: allCravings)

            return BasicAnalyticsResult(
                cravingsByFrequency: cravingsByFrequency,
                cravingsPerDay: cravingsPerDay,
                cravingsByTimeSlot: cravingsByTimeSlot
            )
        } catch {
            print("Error fetching cravings: \(error)")
            // Return an empty result on error.  Consider a more robust error handling strategy.
            return BasicAnalyticsResult(cravingsByFrequency: [:], cravingsPerDay: [:], cravingsByTimeSlot: [:])
        }
    }

    // Helper functions to encapsulate the logic (and make it testable later)

    private func cravingsPerDay(using cravings: [CravingModel]) -> [Date: Int] {
        Dictionary(grouping: cravings, by: { $0.timestamp.onlyDate }).mapValues { $0.count }
    }

    private func cravingsByDate(using cravings: [CravingModel]) -> [Date: Int] {
        Dictionary(grouping: cravings, by: {$0.timestamp.onlyDate}).mapValues {$0.count }
    }

    private func cravingsByTimeOfDay(using cravings: [CravingModel]) -> [String: Int] {
        var timeSlots: [String: Int] = [:]
        for craving in cravings {
            let hour = Calendar.current.component(.hour, from: craving.timestamp)
            let timeSlot = timeSlotString(for: hour)
            timeSlots[timeSlot, default: 0] += 1
        }
        return timeSlots
    }

    private func timeSlotString(for hour: Int) -> String {
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<22: return "Evening"
        default: return "Night"
        }
    }
}

//Added for use in AnalyticsDashboardViewModel
struct BasicAnalyticsResult {
    let cravingsByFrequency: [Date: Int]
    let cravingsPerDay: [Date: Int]
    let cravingsByTimeSlot: [String: Int]
}

