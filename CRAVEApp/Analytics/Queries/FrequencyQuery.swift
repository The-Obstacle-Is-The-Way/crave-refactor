//
//  FrequencyQuery.swift
//  CRAVE
//

import Foundation

struct FrequencyQuery {
    func cravingsPerDay(using cravings: [CravingModel]) -> [Date: Int] {
        let groupedCravings = Dictionary(grouping: cravings) { $0.timestamp.onlyDate }
        return groupedCravings.mapValues { $0.count }
    }
}
