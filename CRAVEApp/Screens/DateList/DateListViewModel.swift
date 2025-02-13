//
//  DateListViewModel.swift
//  CRAVE
//

import Foundation

@Observable
class DateListViewModel {
    var cravingsByDate: [Date: [Craving]] = [:]
    var dateSections: [Date] = []

    func setData(_ cravings: [Craving]) {
        let calendar = Calendar.current
        var temp: [Date: [Craving]] = [:]

        // Filter out archived cravings
        for craving in cravings where craving.isActive {
            let comps = calendar.dateComponents([.year, .month, .day], from: craving.timestamp)
            if let dayDate = calendar.date(from: comps) {
                temp[dayDate, default: []].append(craving)
            }
        }

        dateSections = temp.keys.sorted(by: >)
        cravingsByDate = temp
    }
}
