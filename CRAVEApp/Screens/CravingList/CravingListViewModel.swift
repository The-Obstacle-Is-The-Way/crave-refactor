//
//  🍒
//  CRAVEApp/Screens/CravingList/CravingListViewModel.swift
//
//

import SwiftUI
import SwiftData

@MainActor
final class CravingListViewModel: ObservableObject {
    @Published private(set) var cravings: [CravingModel] = []
    //private var modelContext: ModelContext? // Removed.  We'll use dependency injection.

    init() {
       //We'll use a method to set the Model Context
    }

    func loadData(modelContext: ModelContext) async { // Added ModelContext
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate<CravingModel> { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)] // Correct order
            )
            cravings = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading cravings: \(error)")
            // TODO: Handle the error more gracefully (e.g., show an error message to the user)
        }
    }

    func archiveCraving(_ craving: CravingModel, modelContext: ModelContext) async { // Added ModelContext
        craving.isArchived = true
        do {
            try modelContext.save()
            await loadData(modelContext: modelContext) // Reload after archiving. Pass the context.
        } catch {
            print("Error archiving craving: \(error)")
            // TODO: Handle the error
        }
    }
    
    func deleteCraving(_ craving: CravingModel, modelContext: ModelContext) async { // Added delete function
        modelContext.delete(craving)
        do {
            try modelContext.save()
            await loadData(modelContext: modelContext) // Reload after archiving. Pass the context.
        } catch {
            print("Error deleting craving: \(error)")
            // TODO: Handle the error
        }
    }
}
