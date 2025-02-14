//
//  AnalyticsManager.swift
//  CRAVE
//

import Foundation
import SwiftData

class AnalyticsManager {
    private let cravingManager: CravingManager
    private let frequencyQuery = FrequencyQuery()
    private let timeOfDayQuery = TimeOfDayQuery()
    private let calendarQuery = CalendarViewQuery()
    
    init(cravingManager: CravingManager) {
        self.cravingManager = cravingManager
    }
    
    func getBasicStats() async -> BasicAnalyticsResult {
        let allCravings = await cravingManager.fetchAllActiveCravings() // ✅ Updated method call
        
        let cravingsByDate = calendarQuery.cravingsPerDay(using: allCravings) // ✅ Fixed method call
        let cravingsByTime = timeOfDayQuery.cravingsByTimeSlot(using: allCravings) // ✅ Fixed method call
        let cravingsByFrequency = frequencyQuery.cravingsPerDay(using: allCravings) // ✅ Fixed method call
        
        return BasicAnalyticsResult(
            cravingsByFrequency: cravingsByFrequency, // ✅ Restored missing argument
            cravingsPerDay: cravingsByDate,
            cravingsByTimeSlot: cravingsByTime
        )
    }
}
