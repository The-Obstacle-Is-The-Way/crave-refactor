//
//  BasicAnalyticsResult.swift
//  CRAVE
//

import Foundation

public struct BasicAnalyticsResult {
    public let cravingsPerDay: [Date: Int]
    public let cravingsByTimeSlot: [String: Int]
    
    public init(cravingsPerDay: [Date: Int], cravingsByTimeSlot: [String: Int]) {
        self.cravingsPerDay = cravingsPerDay
        self.cravingsByTimeSlot = cravingsByTimeSlot
    }
}
