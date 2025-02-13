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

    // Add a new craving
    func addCraving(_ text: String, using context: ModelContext) -> Bool {
        let newCraving = Craving(text)
        context.insert(newCraving)
        return save(context, action: "adding craving")
    }

    // Soft-delete a craving by marking 'isArchived = true'
    func softDeleteCraving(_ craving: Craving, using context: ModelContext) -> Bool {
        craving.isArchived = true  // Updated property name
        return save(context, action: "soft deleting craving")
    }

    private func save(_ context: ModelContext, action: String) -> Bool {
        do {
            try context.save()
            print("Success: \(action)")
            return true
        } catch {
            print("Failed: \(action) - Error: \(error.localizedDescription)")
            return false
        }
    }
}
