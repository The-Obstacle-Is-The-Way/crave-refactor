//
//  CravingManager.swift
//  CRAVE
//

import SwiftData
import SwiftUI

@MainActor
class CravingManager: ObservableObject {
    private var modelContext: ModelContext
    
    // This initializer MUST exist.
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
