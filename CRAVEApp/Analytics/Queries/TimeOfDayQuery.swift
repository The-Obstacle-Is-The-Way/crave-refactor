//
//  TimeOfDayQuery.swift
//  CRAVE
//

import Foundation
import SwiftData

struct TimeOfDayQuery {
    func cravingsByTimeSlot(using cravings: [CravingModel]) -> [String: Int] {
        var morning = 0, afternoon = 0, evening = 0, night = 0
        for craving in cravings {
            let hour = Calendar.current.component(.hour, from: craving.timestamp)
            switch hour {
            case 6..<12: morning += 1
            case 12..<17: afternoon += 1
            case 17..<22: evening += 1
            default: night += 1
            }
        }
        return ["Morning": morning, "Afternoon": afternoon, "Evening": evening, "Night": night]
    }
}
