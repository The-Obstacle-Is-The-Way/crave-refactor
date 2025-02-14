//CRAVEApp/Data/CravingManager.swift
import Foundation
import SwiftData

@MainActor
final class CravingManager: ObservableObject {
    //@Published var cravings: [CravingModel] = [] // No longer needed here
    var modelContext: ModelContext? // ✅ Make modelContext non-private (public)

    /// Inserts a new craving into the data store.
    /// - Parameter craving: The craving to be inserted.
    func insert(_ craving: CravingModel) {
        modelContext?.insert(craving)
        save() // Call save here.
    }

    /// Archives a specific craving, marking it as no longer active. (soft delete)
    func archiveCraving(_ craving: CravingModel) {
        craving.isArchived = true
        save()
    }

    /// Retrieves all cravings that are not archived.
    func fetchAllActiveCravings() async -> [CravingModel] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp)]
            )
            return try modelContext?.fetch(descriptor) ?? [] // Handle optional context
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }

    /// Saves changes to the persistent store.
    private func save() {
        do {
            try modelContext?.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}


