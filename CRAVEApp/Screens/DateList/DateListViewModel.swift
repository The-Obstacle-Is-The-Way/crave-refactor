// CRAVEApp/Screens/DateList/DateListViewModel.swift
import Foundation
import SwiftData

@MainActor
final class DateListViewModel: ObservableObject {
    @Published var cravings: [CravingModel] = []
    private var modelContext: ModelContext?

    init() {
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

      func loadCravings() {
        guard let context = modelContext else {
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
        guard let modelContext = self.modelContext else {  // Directly use self.modelContext
            print("ModelContext not available.")
            return []
        }
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)]) //sort desc
            return try modelContext.fetch(descriptor) // Directly use self.modelContext
        } catch {
            print("Error fetching cravings: \(error)")
            return []
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        // Only set and load if context is not already set
        guard self.modelContext == nil else { return }
        self.modelContext = context
        loadCravings() // Load cravings when context is set
    }
}

