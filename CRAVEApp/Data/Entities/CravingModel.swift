//
//  CravingModel.swift
//  CRAVE
//

import SwiftData
import Foundation

@Model
class Craving {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var text: String
    @Attribute var timestamp: Date = Date()

    // ✅ Renamed from isDeleted to isArchived
    @Attribute var isArchived: Bool = false

    // Initialize a new craving
    init(_ text: String) {
        self.text = text
        self.isArchived = false  // Ensure new cravings are active by default
    }

    // Computed property to check if craving is active
    var isActive: Bool {
        return !isArchived
    }
}
