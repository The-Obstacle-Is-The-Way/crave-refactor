//
//  Date+Formatting.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//
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
    
    //Added for Analytics Formatter
    func toString(format: String = "MMM d, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Returns a string of the date in a relative style if desired, e.g. "Today," "Tomorrow," "Yesterday."
    func toRelativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
