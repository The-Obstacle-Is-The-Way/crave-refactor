// CRAVEApp/Data/CravingManager.swift


import Foundation
import SwiftData

@MainActor
final class CravingManager: ObservableObject {
    var modelContext: ModelContext?

    func insert(_ craving: CravingModel) {
        modelContext?.insert(craving)
        save() // Call save here.
    }

    func archiveCraving(_ craving: CravingModel) {
        craving.isArchived = true
        save()
    }

    func fetchAllActiveCravings() async -> [CravingModel] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp)]
            )
            return try modelContext?.fetch(descriptor) ?? []
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }

    private func save() {
        do {
            try modelContext?.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

