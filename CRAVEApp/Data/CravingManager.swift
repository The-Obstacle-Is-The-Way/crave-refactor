//
//  CravingManager.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

/* A lightweight singleton for handling Craving insertions/deletions outside of Views.
Use it when you need consistent data operations from multiple screens or background tasks. */


import SwiftData
import Foundation

@MainActor
final class CravingManager {
    static let shared = CravingManager()
    private init() {}

    /// Adds a new Craving object with the given text, then saves the context.
    func addCraving(_ text: String, using context: ModelContext) {
        let newCraving = Craving(text: text)
        context.insert(newCraving)
        do {
            try context.save()
        } catch {
            print("SwiftData save error while adding craving: \(error)")
        }
    }

    /// Marks a Craving as deleted (soft delete) but keeps the record in the database.
    func softDeleteCraving(_ craving: Craving, using context: ModelContext) {
        craving.isDeleted = true
        do {
            try context.save()
        } catch {
            print("SwiftData save error while soft-deleting craving: \(error)")
        }
    }

    /// (Optional) Fully remove a Craving from the persistent store if you need true deletion.
    func permanentlyDeleteCraving(_ craving: Craving, using context: ModelContext) {
        context.delete(craving)
        do {
            try context.save()
        } catch {
            print("SwiftData save error while permanently deleting craving: \(error)")
        }
    }

    /// (Optional) A simple fetch method if you want to retrieve cravings outside of a View’s @Query.
    func fetchCravings(using context: ModelContext, includingDeleted: Bool = false) -> [Craving] {
        let descriptor = FetchDescriptor<Craving>()
        do {
            let allCravings = try context.fetch(descriptor)
            return includingDeleted
                ? allCravings
                : allCravings.filter { $0.isDeleted == false }
        } catch {
            print("SwiftData fetch error: \(error)")
            return []
        }
    }
}
