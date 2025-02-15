//
//
// CRAVEApp/Data/CravingManager.swift
//
//

import Foundation
import SwiftData

@MainActor
final class CravingManager: ObservableObject { // Use @MainActor for UI updates
    private let modelContext: ModelContext // Inject ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func insert(_ craving: CravingModel) {
        modelContext.insert(craving)
        save() // Call save after insert
    }

    func archiveCraving(_ craving: CravingModel) {
        craving.isArchived = true // Use the soft-delete flag
        save() // Save after modifying
    }

    func fetchAllActiveCravings() async -> [CravingModel] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived }, // Filter out archived cravings
                sortBy: [SortDescriptor(\.timestamp)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)") // Log the error
            return [] // Return an empty array on failure
        }
    }
    
    func deleteCraving(_ craving: CravingModel) { //added delete function
        modelContext.delete(craving)
        save()
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            // Handle the error appropriately. Don't just print in a production app.
            print("Error saving context: \(error)")
            // Consider showing an error to the user or retrying.
        }
    }
}


