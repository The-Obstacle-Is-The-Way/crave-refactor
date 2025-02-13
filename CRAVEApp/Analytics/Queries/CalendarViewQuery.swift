//
//  CalendarViewQuery.swift
//  CRAVE
//

import Foundation
import SwiftData

struct CalendarViewQuery {
    func cravingsPerDay(using cravings: [CravingModel]) -> [Date: Int] {
        let grouped = Dictionary(grouping: cravings) { $0.timestamp.onlyDate }
        return grouped.mapValues { $0.count }
    }
}
