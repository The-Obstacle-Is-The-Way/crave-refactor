//
//  CravingManager.swift
//  CRAVE
//

import SwiftData
import SwiftUI

@MainActor
class CravingManager: ObservableObject {
    private var modelContext: ModelContext
    
    // Instead of using a shared container, we require a ModelContext to be passed in.
    init(context: ModelContext) {
        self.modelContext = context
    }
    
    func insert(_ craving: CravingModel) {
        modelContext.insert(craving)
        saveContext()
    }
    
    func delete(_ craving: CravingModel) {
        modelContext.delete(craving)
        saveContext()
    }
    
    // New method for soft deletion
    func softDeleteCraving(_ craving: CravingModel, using context: ModelContext) -> Bool {
        // Optionally, you can check that the passed context is the same as the manager's context.
        // For now, we simply mark the craving as archived.
        craving.isArchived = true
        return true
    }
    
    func fetchAllCravings() async -> [CravingModel] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching cravings: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
