//
// DateListViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
final class DateListViewModel: ObservableObject {
    @Published var cravings: [CravingModel] = []
    private var modelContext: ModelContext?

    init(modelContext: ModelContext) { // ✅ ViewModel now REQUIRES ModelContext in initializer
        self.modelContext = modelContext
        loadCravings()
    }

    /// Groups cravings by the day they occurred.
    var groupedCravings: [String: [CravingModel]] {
        Dictionary(grouping: cravings) { craving in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: craving.timestamp)
        }
    }

    /// Loads cravings from the persistent store asynchronously.
    func loadCravings() {
        guard modelContext != nil else {
            print("ModelContext is nil. Cannot load cravings.")
            return
        }
        Task {
            let fetchedCravings = await fetchCravings()
            await MainActor.run {
                cravings = fetchedCravings
            }
        }
    }

    private func fetchCravings() async -> [CravingModel] {
        guard let context = modelContext else {
            print("ModelContext not available.")
            return []
        }
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching cravings: \(error)")
            return []
        }
    }

    func setModelContext(_ context: ModelContext) { // Still keep setModelContext for other views
        self.modelContext = context
    }
}


