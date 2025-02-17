//
//
//  🍒
//  CRAVEApp/Features/Craving/Presentation/ViewModels/CravingListViewModel.swift
//  Purpose: The "brain" behind our list view - manages all data and logic
//
//

import SwiftUI
import SwiftData

// @MainActor means "run this code on the main thread" (important for UI updates)
// A ViewModel is like a manager that handles all the behind-the-scenes work
@MainActor
final class CravingListViewModel: ObservableObject {
    // @Published means "tell the view when this changes"
    // Think of it like a notification system for our data
    @Published var cravings: [CravingModel] = []
    
    // Load all cravings from our database
    func loadData(modelContext: ModelContext) {
        Task {
            await fetchCravings(modelContext: modelContext)
        }
    }
    
    // Archive a craving (like putting it in storage but not deleting it)
    func archiveCraving(_ craving: CravingModel, modelContext: ModelContext) async {
        craving.isArchived = true  // Mark it as archived
        do {
            try modelContext.save()  // Save this change to our database
        } catch {
            print("Failed to archive craving: \(error)")
            // In a real app, we'd handle this error better
        }
        
        // Refresh our list of cravings
        await fetchCravings(modelContext: modelContext)
    }
    
    // Completely delete a craving
    func deleteCraving(_ craving: CravingModel, modelContext: ModelContext) async {
        modelContext.delete(craving)  // Remove it from our database
        do {
            try modelContext.save()  // Save this change
        } catch {
            print("Failed to delete craving: \(error)")
            // In a real app, we'd handle this error better
        }
        
        // Refresh our list
        await fetchCravings(modelContext: modelContext)
    }
    
    // Get all cravings from the database
    private func fetchCravings(modelContext: ModelContext) async {
        do {
            // Create a request for cravings
            // Only get cravings that aren't archived (isArchived = false)
            // Sort them by timestamp (newest first)
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            
            // Get the cravings and update our list
            let fetchedCravings = try modelContext.fetch(descriptor)
            self.cravings = fetchedCravings
            
        } catch {
            print("Error fetching cravings: \(error)")
            // In a real app, we'd handle this error better
        }
    }
}
