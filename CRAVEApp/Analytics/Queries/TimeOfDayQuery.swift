//
//  TimeOfDayQuery.swift
//  CRAVE
//

import Foundation
import SwiftData

struct TimeOfDayQuery {
    func cravingsByTimeSlot(using cravings: [CravingModel]) -> [String: Int] {
        var timeSlots: [String: Int] = [
            "Morning": 0,
            "Afternoon": 0,
            "Evening": 0,
            "Night": 0
        ]
        
        for craving in cravings {
            let hour = Calendar.current.component(.hour, from: craving.timestamp)
            let timeSlot = timeSlotString(for: hour)
            timeSlots[timeSlot, default: 0] += 1
        }
        
        return timeSlots
    }
    
    private func timeSlotString(for hour: Int) -> String {
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<22: return "Evening"
        default: return "Night"
        }
    }
}

struct FrequencyQuery {
    func cravingsPerDay(using cravings: [CravingModel]) -> [Date: Int] {
        Dictionary(grouping: cravings) { craving in
            Calendar.current.startOfDay(for: craving.timestamp)
        }
        .mapValues { $0.count }
    }
}

struct CalendarViewQuery {
    func cravingsPerDay(using cravings: [CravingModel]) -> [Date: Int] {
        Dictionary(grouping: cravings) { craving in
            Calendar.current.startOfDay(for: craving.timestamp)
        }
        .mapValues { $0.count }
    }
}

// MARK: - Date Extensions
extension Date {
    var onlyDate: Date {
        Calendar.current.startOfDay(for: self)
    }
}
