//
//  CravingManager.swift
//  CRAVE
//

import SwiftData
import SwiftUI

@MainActor
class CravingManager: ObservableObject {
    private var modelContext: ModelContext

    // New initializer that takes a ModelContext
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func insert(_ craving: CravingModel) {
        modelContext.insert(craving)
        saveContext()
    }
    
    func delete(_ craving: CravingModel) {
        modelContext.delete(craving)
        saveContext()
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
    
    // Example soft delete method
    func softDeleteCraving(_ craving: CravingModel) -> Bool {
        craving.isArchived = true
        return true
    }
}
