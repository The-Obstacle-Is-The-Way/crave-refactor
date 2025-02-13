//
//  CalendarViewQuery.swift
//  CRAVE
//

import Foundation

struct CalendarViewQuery {
    func dailyCravingData(using cravings: [CravingModel]) -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: cravings) { craving -> Date in
            let components = calendar.dateComponents([.year, .month, .day], from: craving.timestamp)
            return calendar.date(from: components)!
        }
        let data = groups.map { (date, cravings) in
            (date: date, count: cravings.count)
        }
        return data.sorted { $0.date < $1.date }
    }
}
