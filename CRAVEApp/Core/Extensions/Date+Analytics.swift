//
//  Date+Analytics.swift
//  CRAVE
//

import Foundation

extension Date {
    /// Returns a string of the date formatted with the given format, e.g. "MMM d, yyyy" -> "Feb 12, 2025".
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

     // Helper functions to get the start of day, week, and month
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

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

