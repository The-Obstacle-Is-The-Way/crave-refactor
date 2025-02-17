//
//
//  🍒
//  CRAVEApp/Features/Craving/Presentation/ViewModels/CravingListViewModel.swift
//  Purpose: The "brain" behind our list view - manages all data and logic
//
//

import SwiftUI
import SwiftData

@MainActor
final class CravingListViewModel: ObservableObject {
    @Published var cravings: [CravingModel] = []
    
    // Load all cravings from our database asynchronously
    func loadData(modelContext: ModelContext) async {
        await fetchCravings(modelContext: modelContext)
    }
    
    // Archive a craving asynchronously
    func archiveCraving(_ craving: CravingModel, modelContext: ModelContext) async {
        craving.isArchived = true
        do {
            try modelContext.save()
        } catch {
            print("Failed to archive craving: \(error)")
            // Handle error appropriately in production
        }
        await fetchCravings(modelContext: modelContext)
    }
    
    // Delete a craving asynchronously
    func deleteCraving(_ craving: CravingModel, modelContext: ModelContext) async {
        modelContext.delete(craving)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete craving: \(error)")
            // Handle error appropriately in production
        }
        await fetchCravings(modelContext: modelContext)
    }
    
    // Fetch all non-archived cravings asynchronously
    private func fetchCravings(modelContext: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let fetchedCravings = try modelContext.fetch(descriptor)
            self.cravings = fetchedCravings
        } catch {
            print("Error fetching cravings: \(error)")
            // Handle error appropriately in production
        }
    }
}
