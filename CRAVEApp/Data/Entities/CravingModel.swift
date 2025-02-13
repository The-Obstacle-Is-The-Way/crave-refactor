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
    @Attribute var isArchived: Bool = false  // ✅ Soft delete flag

    init(_ text: String) {
        self.text = text
        self.isArchived = false
    }
}
