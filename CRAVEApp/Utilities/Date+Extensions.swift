//
//  Date+Extensions.swift
//  CRAVE
//

import Foundation

public extension Date {
    /// Returns a new Date representing only the year, month, and day components.
    var onlyDate: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
