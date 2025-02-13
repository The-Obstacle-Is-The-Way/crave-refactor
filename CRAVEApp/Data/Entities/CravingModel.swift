// CravingModel.swift
// SwiftData model for CRAVE.

import SwiftData
import Foundation

@Model
class Craving {
    @Attribute(.unique) var id: UUID
    var text: String
    var timestamp: Date
    var isDeleted: Bool  // Soft-delete flag

    init(
        id: UUID = UUID(),
        text: String,
        timestamp: Date = Date(),
        isDeleted: Bool = false
    ) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.isDeleted = isDeleted
    }
}
