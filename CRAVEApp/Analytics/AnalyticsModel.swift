//
//  AnalyticsModel.swift
//  CRAVE
//

import Foundation

struct BasicAnalyticsResult {
    let cravingsPerDay: [Date: Int]
    let cravingsByTimeSlot: [String: Int]
}
