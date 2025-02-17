//  CRAVEApp/Core/Data/Repositories/CravingManager.swift

import Foundation
import SwiftData

@MainActor
final class CravingManager: ObservableObject { // Use @MainActor for UI updates
    private let modelContext: ModelContext // Inject ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func insert(_ craving: CravingEntity) {
        let cravingModel = CravingModel(cravingText: craving.text, timestamp: craving.timestamp)
        modelContext.insert(cravingModel)
        save() // Call save after insert
    }

    func archiveCraving(_ craving: CravingEntity) {
        // Use the soft-delete flag
        if let cravingModel = modelContext.resolve(craving) {
            cravingModel.isArchived = true
            save() // Save after modifying
        }
    }

    func fetchAllActiveCravings() async -> [CravingDTO] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate {!$0.isArchived }, // Filter out archived cravings
                sortBy: [SortDescriptor(\.timestamp)]
            )
            let fetchedCravings = try modelContext.fetch(descriptor)
            return fetchedCravings.map {
                CravingDTO(id: $0.id, text: $0.cravingText, timestamp: $0.timestamp, isArchived: $0.isArchived)
            }
        } catch {
            print("Fetch failed: \(error)") // Log the error
            return // Return an empty array on failure
        }
    }
    
    func deleteCraving(_ craving: CravingEntity) {
        if let cravingModel = modelContext.resolve(craving) {
            modelContext.delete(cravingModel)
            save()
        }
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
