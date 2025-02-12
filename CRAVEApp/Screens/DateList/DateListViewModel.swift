//
//  DateListViewModel.swift
//  CRAVE
//
//  Created by [Your Name] on [Date]
//

import UIKit
import SwiftUI
import SwiftData
import Foundation

@Observable
class DateListViewModel {
    // Dictionary grouping cravings by date
    var cravingsByDate: [Date: [Craving]] = [:]
    var dateSections: [Date] = []

    func groupCravings(_ cravings: [Craving]) {
        let calendar = Calendar.current
        var tempDict: [Date: [Craving]] = [:]

        for craving in cravings {
            // Extract just YYYY-MM-DD to group by 'day'
            let comps = calendar.dateComponents([.year, .month, .day], from: craving.timestamp)
            if let dayDate = calendar.date(from: comps) {
                tempDict[dayDate, default: []].append(craving)
            }
        }

        // Sort days descending
        dateSections = tempDict.keys.sorted { $0 > $1 }
        cravingsByDate = tempDict
    }
}
