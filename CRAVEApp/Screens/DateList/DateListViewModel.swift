// DateListViewModel.swift
// Groups cravings by date, ignoring those with isDeleted == true.

import SwiftUI
import Foundation

@Observable
class DateListViewModel {
    var cravingsByDate: [Date: [Craving]] = [:]
    var dateSections: [Date] = []

    func groupCravings(_ cravings: [Craving]) {
        // Filter out soft-deleted items
        let activeCravings = cravings.filter { !$0.isDeleted }
        let calendar = Calendar.current
        var tempDict: [Date: [Craving]] = [:]

        for craving in activeCravings {
            // Group by YYYY-MM-DD
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
