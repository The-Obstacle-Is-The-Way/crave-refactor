//
//  AnalyticsManager.swift
//  CRAVE
//

import SwiftUI

@MainActor
public class AnalyticsManager {
    public let cravingManager: CravingManager
    private let frequencyQuery = FrequencyQuery()
    private let timeOfDayQuery = TimeOfDayQuery()
    
    public init(cravingManager: CravingManager) {
        self.cravingManager = cravingManager
    }
    
    public func getBasicStats() async -> BasicAnalyticsResult {
        let allCravings = await cravingManager.fetchAllCravings()
        let freqDict = frequencyQuery.cravingsPerDay(using: allCravings)
        let dayParts = timeOfDayQuery.cravingsByTimeSlot(using: allCravings)
        return BasicAnalyticsResult(cravingsPerDay: freqDict, cravingsByTimeSlot: dayParts)
    }
}
