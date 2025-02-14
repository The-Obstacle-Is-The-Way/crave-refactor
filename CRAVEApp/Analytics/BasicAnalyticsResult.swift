//
//  BasicAnalyticsResult.swift
//  CRAVE
//

import Foundation

struct BasicAnalyticsResult {
    let cravingsByFrequency: [Date: Int]
    let cravingsPerDay: [Date: Int]
    let cravingsByTimeSlot: [String: Int]
}
