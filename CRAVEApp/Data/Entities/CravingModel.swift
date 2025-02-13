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
    @Attribute var isDeleted: Bool = false  // ✅ Soft delete flag

    /// 🚀 Initialize a new craving
    init(_ text: String) {
        self.text = text
        self.isDeleted = false  // ✅ Ensure new cravings are not deleted by default
    }

    /// ✅ Computed property to check if craving is active
    var isActive: Bool {
        return !isDeleted
    }
}
