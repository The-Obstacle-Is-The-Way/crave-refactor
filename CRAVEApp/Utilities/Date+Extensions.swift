//
//  Date+Extensions.swift
//  CRAVE
//

import Foundation

extension Date {
    /// Returns the date representing only the day (year, month, day)
    var onlyDate: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Returns a medium–style formatted date string
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}


