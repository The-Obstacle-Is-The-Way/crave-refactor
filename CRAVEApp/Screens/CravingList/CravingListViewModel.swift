//
//  CravingListViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
final class CravingListViewModel: ObservableObject {
    @Published private(set) var cravings: [CravingModel] = []
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        guard let context = modelContext else { return }
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate<CravingModel> { !$0.isArchived }
            )
            cravings = try context.fetch(descriptor)
        } catch {
            print("Error loading cravings: \(error)")
        }
    }
    
    func refreshData() async {
        await loadInitialData()
    }
    
    func archiveCraving(_ craving: CravingModel) async {
        guard let context = modelContext else { return }
        do {
            craving.isArchived = true
            try context.save()
            await loadInitialData()
        } catch {
            print("Error archiving craving: \(error)")
        }
    }
}
