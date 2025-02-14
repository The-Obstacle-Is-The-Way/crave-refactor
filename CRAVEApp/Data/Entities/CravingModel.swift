//
//  CravingModel.swift
//  CRAVE
//

import SwiftData
import Foundation // ✅ Ensure Foundation is imported

@Model // ✅ Enables SwiftData Persistence
final class CravingModel: Identifiable {
    @Attribute(.unique) var id: UUID  // ✅ SwiftData auto-generates a unique UUID
    var cravingText: String
    var timestamp: Date
    var isArchived: Bool  // ✅ Soft delete flag

    // MARK: - Initializer
    init(cravingText: String, timestamp: Date, isArchived: Bool = false) {
        self.id = UUID() // ✅ Explicitly initializing ID
        self.cravingText = cravingText
        self.timestamp = timestamp
        self.isArchived = isArchived
    }
}
