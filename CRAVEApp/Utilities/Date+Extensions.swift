//
//  Date+Extensions.swift
//  CRAVE
//

import Foundation

extension Date {
    /// Returns the date representing only the year, month, and day components.
    var onlyDate: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns a formatted date string (e.g., "Jan 1, 2023").
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
