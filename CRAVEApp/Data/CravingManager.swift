//
//  CravingManager.swift
//  CRAVE
//

import SwiftData
import Foundation

@MainActor
final class CravingManager {
    static let shared = CravingManager()
    private init() {}

    /// 🚀 Add a new craving to SwiftData
    func addCraving(_ text: String, using context: ModelContext) -> Bool {
        let newCraving = Craving(text)
        context.insert(newCraving)
        return save(context, action: "adding craving")
    }

    /// 🚀 Soft-delete a craving by marking `isDeleted = true`
    func softDeleteCraving(_ craving: Craving, using context: ModelContext) -> Bool {
        craving.isDeleted = true
        return save(context, action: "soft deleting craving")
    }

    /// ✅ Save context changes with error handling
    private func save(_ context: ModelContext, action: String) -> Bool {
        do {
            try context.save()
            print("✅ Success: \(action)")
            return true
        } catch {
            print("❌ Failed: \(action) - Error: \(error.localizedDescription)")
            return false
        }
    }
}
