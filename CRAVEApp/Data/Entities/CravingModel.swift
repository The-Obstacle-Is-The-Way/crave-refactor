//
//  CravingModel.swift
//  CRAVE
//

import SwiftData

@Model // ✅ Enables SwiftData Persistence
final class CravingModel: Identifiable {
    var id: UUID // ✅ Ensures stable identity for UI updates
    var cravingText: String
    var timestamp: Date
    var isArchived: Bool  // ✅ Soft delete flag

    // MARK: - Initializer
    init(cravingText: String, timestamp: Date, isArchived: Bool = false) {
        self.id = UUID()
        self.cravingText = cravingText
        self.timestamp = timestamp
        self.isArchived = isArchived
    }
}
