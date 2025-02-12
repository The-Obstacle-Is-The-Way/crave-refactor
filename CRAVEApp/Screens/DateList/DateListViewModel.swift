//
//  DateListViewModel.swift
//  CRAVE
//

import SwiftUI
import Foundation

@Observable
class DateListViewModel {
    var cravingsByDate: [Date: [Craving]] = [:]
    var dateSections: [Date] = []

    func setData(_ cravings: [Craving]) {
        let calendar = Calendar.current
        var tempDict: [Date: [Craving]] = [:]

        for craving in cravings {
            let comps = calendar.dateComponents([.year, .month, .day], from: craving.timestamp)
            if let dayDate = calendar.date(from: comps) {
                tempDict[dayDate, default: []].append(craving)
            }
        }

        dateSections = tempDict.keys.sorted { $0 > $1 }
        cravingsByDate = tempDict
    }
}
