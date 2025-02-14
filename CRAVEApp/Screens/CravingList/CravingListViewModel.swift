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
        Task { // Load data asynchronously
            await loadInitialData()
        }
    }


    func loadInitialData() async {
       guard let modelContext = self.modelContext else { return } // Directly use self.modelContext
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)] // Sort descending
            )
            cravings = try modelContext.fetch(descriptor)  // Directly use self.modelContext
        } catch {
            print("Error loading cravings: \(error)")
        }
    }

    func refreshData() async {
        await loadInitialData() // Simple refresh
    }

    func archiveCraving(_ craving: CravingModel) async {
        guard let modelContext = self.modelContext else {return} //Directly use self.modelContext
        do {
            craving.isArchived = true
            try modelContext.save() // Directly use self.modelContext
            await loadInitialData() // Reload data after archiving
        } catch {
            print("Error archiving craving: \(error)")
        }
    }
}

