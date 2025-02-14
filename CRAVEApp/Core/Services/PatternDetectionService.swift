//
//  PatternDetectionService.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
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
}
