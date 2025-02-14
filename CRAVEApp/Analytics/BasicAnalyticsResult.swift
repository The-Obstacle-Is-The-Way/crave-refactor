//
//  BasicAnalyticsResult.swift
//  CRAVE
//

import Foundation

struct BasicAnalyticsResult {
    let cravingsByFrequency: [Date: Int] // ✅ Added frequency tracking
    let cravingsPerDay: [Date: Int]
    let cravingsByTimeSlot: [String: Int]
}
