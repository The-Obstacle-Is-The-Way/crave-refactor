//
//  CalendarViewQuery.swift
//  CRAVE
//

import Foundation

public struct CalendarViewQuery {
    public init() { }
    
    public func dailyCravingData(using cravings: [CravingModel]) -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let groups: [Date: [CravingModel]] = Dictionary(grouping: cravings) { craving -> Date in
            let components = calendar.dateComponents([.year, .month, .day], from: craving.timestamp)
            return calendar.date(from: components)!
        }
        let data = groups.map { (date, cravings) in
            (date: date, count: cravings.count)
        }
        return data.sorted { $0.date < $1.date }
    }
}
