//
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

    init() {
       //We'll use a method to set the Model Context
    }

    func loadData(modelContext: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate<CravingModel> { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            cravings = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading cravings: \(error)")
            // TODO: Handle the error more gracefully
        }
    }

    func archiveCraving(_ craving: CravingModel, modelContext: ModelContext) async {
        craving.isArchived = true
        do {
            try modelContext.save()
            await loadData(modelContext: modelContext)
        } catch {
            print("Error archiving craving: \(error)")
            // TODO: Handle the error
        }
    }
    
    func deleteCraving(_ craving: CravingModel, modelContext: ModelContext) async {
        modelContext.delete(craving)
        do {
            try modelContext.save()
            await loadData(modelContext: modelContext)
        } catch {
            print("Error deleting craving: \(error)")
            // TODO: Handle the error
        }
    }
}
