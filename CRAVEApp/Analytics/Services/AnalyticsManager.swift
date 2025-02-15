//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsManager.swift
//  Purpose: Central manager for all analytics operations and data processing
//
//

import Foundation
import SwiftData

@MainActor
final class AnalyticsManager {
    private let modelContext: ModelContext
    private let timeOfDayQuery = TimeOfDayQuery()
    private let frequencyQuery = FrequencyQuery()
    private let calendarViewQuery = CalendarViewQuery()
    private let storage: AnalyticsStorage
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.storage = AnalyticsStorage(modelContext: modelContext)
    }
    
    func getBasicStats() async -> BasicAnalyticsResult {
        do {
            let fetchDescriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\CravingModel.timestamp, order: .reverse)]
            )
            
            let allCravings = try modelContext.fetch(fetchDescriptor)
            
            let cravingsByFrequency = frequencyQuery.cravingsPerDay(using: allCravings)
            let cravingsPerDay = calendarViewQuery.cravingsPerDay(using: allCravings)
            let cravingsByTimeSlot = timeOfDayQuery.cravingsByTimeSlot(using: allCravings)
            
            return BasicAnalyticsResult(
                cravingsByFrequency: cravingsByFrequency,
                cravingsPerDay: cravingsPerDay,
                cravingsByTimeSlot: cravingsByTimeSlot
            )
        } catch {
            print("Error fetching cravings: \(error)")
            return BasicAnalyticsResult()
        }
    }
    
    func trackEvent(_ event: CravingModel) async throws {
        let metadata = AnalyticsMetadata(cravingId: event.id)
        event.analyticsMetadata = metadata
        
        storage.modelContext.insert(metadata)
        storage.modelContext.insert(event)
        try storage.modelContext.save()
    }
    
    func processHistoricalData(_ startDate: Date, _ endDate: Date) async {
        print("Processing historical data from \(startDate) to \(endDate)")
    }
}

// MARK: - Preview Support
extension AnalyticsManager {
    static func preview(modelContext: ModelContext) -> AnalyticsManager {
        AnalyticsManager(modelContext: modelContext)
    }
}
