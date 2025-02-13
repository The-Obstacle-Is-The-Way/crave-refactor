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

    func addCraving(_ text: String, using context: ModelContext) -> Bool {
        let newCraving = Craving(text)
        context.insert(newCraving)
        return save(context, action: "adding craving")
    }

    func softDeleteCraving(_ craving: Craving, using context: ModelContext) -> Bool {
        craving.isArchived = true

        // ✅ Force SwiftData to recognize the change
        context.insert(craving)
        context.processPendingChanges()

        return save(context, action: "soft deleting craving")
    }

    private func save(_ context: ModelContext, action: String) -> Bool {
        do {
            if context.hasChanges {
                try context.save()
                print("✅ Success: \(action)")
                return true
            } else {
                print("⚠️ No changes detected: \(action)")
                return false
            }
        } catch {
            print("❌ Failed: \(action) - Error: \(error.localizedDescription)")
            return false
        }
    }
}
