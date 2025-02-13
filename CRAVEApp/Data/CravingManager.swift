// CravingManager.swift
// Lightweight manager for adding/deleting cravings.

import SwiftData
import Foundation

@MainActor
final class CravingManager {
    static let shared = CravingManager()
    private init() {}

    /// Adds a new Craving with the given text, then saves the context.
    func addCraving(_ text: String, using context: ModelContext) {
        let newCraving = Craving(text: text)
        context.insert(newCraving)
        do {
            try context.save()
        } catch {
            print("SwiftData save error while adding craving: \(error)")
        }
    }

    /// Soft-deletes a Craving. Record remains in the store, but is hidden in the UI.
    func softDeleteCraving(_ craving: Craving, using context: ModelContext) {
        craving.isDeleted = true
        do {
            try context.save()
        } catch {
            print("SwiftData save error while soft-deleting craving: \(error)")
        }
    }

    /// Permanently removes a Craving from the store. Not used if you only do soft-deletes.
    func permanentlyDeleteCraving(_ craving: Craving, using context: ModelContext) {
        context.delete(craving)
        do {
            try context.save()
        } catch {
            print("SwiftData save error while permanently deleting craving: \(error)")
        }
    }

    /// Fetch cravings if needed outside a View’s @Query. Excludes soft-deleted by default.
    func fetchCravings(using context: ModelContext, includingDeleted: Bool = false) -> [Craving] {
        let descriptor = FetchDescriptor<Craving>()
        do {
            let allCravings = try context.fetch(descriptor)
            return includingDeleted ? allCravings : allCravings.filter { !$0.isDeleted }
        } catch {
            print("SwiftData fetch error: \(error)")
            return []
        }
    }
}
