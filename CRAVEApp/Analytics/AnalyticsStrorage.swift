//
//  AnalyticsManager.swift
//  CRAVE
//

import Foundation
import SwiftData

@MainActor
class AnalyticsManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getBasicStats() async -> BasicAnalyticsResult {
        do {
            let fetchDescriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
            let allCravings = try modelContext.fetch(fetchDescriptor)
            
            let cravingsByFrequency = FrequencyQuery().cravingsPerDay(using: allCravings)
            let cravingsPerDay = CalendarViewQuery().cravingsPerDay(using: allCravings)
            let cravingsByTimeSlot = TimeOfDayQuery().cravingsByTimeSlot(using: allCravings)
            
            return BasicAnalyticsResult(
                cravingsByFrequency: cravingsByFrequency,
                cravingsPerDay: cravingsPerDay,
                cravingsByTimeSlot: cravingsByTimeSlot
            )
        } catch {
            print("Error fetching cravings: \(error)")
            return BasicAnalyticsResult(
                cravingsByFrequency: [:],
                cravingsPerDay: [:],
                cravingsByTimeSlot: [:]
            )
        }
    }
}

