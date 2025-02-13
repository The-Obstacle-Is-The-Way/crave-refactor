//
//  FrequencyQuery.swift
//  CRAVE
//

import Foundation

struct FrequencyQuery {
    func cravingsPerDay(using cravings: [CravingModel]) -> [Date: Int] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: cravings) { craving -> Date in
            // Extract only year, month, and day components.
            let components = calendar.dateComponents([.year, .month, .day], from: craving.timestamp)
            return calendar.date(from: components)!
        }
        var result: [Date: Int] = [:]
        for (day, cravings) in groups {
            result[day] = cravings.count
        }
        return result
    }
}
