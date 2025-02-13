//
//  CravingModel.swift
//  CRAVE
//

import SwiftData
import Foundation

@Model
class CravingModel {
    var timestamp: Date
    var intensity: Int
    var note: String?
    // Use a custom soft-delete flag (do not name it isDeleted)
    var isArchived: Bool = false

    init(timestamp: Date = Date(), intensity: Int, note: String? = nil) {
        self.timestamp = timestamp
        self.intensity = intensity
        self.note = note
    }
}
