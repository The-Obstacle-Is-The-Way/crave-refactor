//
//  CravingManager.swift
//  CRAVE
//

import SwiftData
import SwiftUI

@MainActor
class CravingManager: ObservableObject {
    @Environment(\.modelContext) private var modelContext // ✅ Injected automatically

    // MARK: - Insert New Craving
    func insert(_ craving: CravingModel) {
        modelContext.insert(craving)
        saveContext() // ✅ Ensure data is persisted
    }

    // MARK: - Soft Delete Craving
    func archiveCraving(_ craving: CravingModel) {
        craving.isArchived = true
        saveContext() // ✅ Soft deletion
    }

    // MARK: - Fetch All Active Cravings
    func fetchAllActiveCravings() async -> [CravingModel] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
            return try modelContext.fetch(descriptor) // ✅ Fetch only non-archived cravings
        } catch {
            print("Error fetching cravings: \(error)")
            return []
        }
    }

    // MARK: - Save Context
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
