// CRAVEApp/Screens/CravingList/CravingListViewModel.swift
import SwiftUI
import SwiftData

@MainActor
final class CravingListViewModel: ObservableObject {
    @Published private(set) var cravings: [CravingModel] = []
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
         // Only set the context and load if it hasn't been set before.
        guard self.modelContext == nil else { return }
        self.modelContext = context
        Task { // Use Task to load on context setting
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        guard let modelContext = self.modelContext else { return } // Correct unwrapping
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate<CravingModel> { !$0.isArchived }
            )
            cravings = try modelContext.fetch(descriptor) // Correctly use the LOCAL 'modelContext'
        } catch {
            print("Error loading cravings: \(error)")
        }
    }
    
    func refreshData() async {
        await loadInitialData()
    }
    
    func archiveCraving(_ craving: CravingModel) async {
       guard let modelContext = self.modelContext else { return } // Correct unwrapping
        do {
            craving.isArchived = true
            try modelContext.save()  // Correctly use the LOCAL 'modelContext'
            await loadInitialData() // Reload after archiving
        } catch {
            print("Error archiving craving: \(error)")
        }
    }
}

