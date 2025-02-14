// CRAVEApp/Screens/DateList/DateListViewModel.swift
import Foundation
import SwiftData

@MainActor
final class DateListViewModel: ObservableObject {
    @Published var cravings: [CravingModel] = []
    private var modelContext: ModelContext? // Keep this as an optional

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

    /// Loads cravings from the persistent store asynchronously.
      func loadCravings() {
        // No guard needed here, we handle the optional context in fetchCravings
        Task {
            let fetchedCravings = await fetchCravings()
            await MainActor.run {
                cravings = fetchedCravings
            }
        }
    }

    private func fetchCravings() async -> [CravingModel] {
        guard let modelContext = self.modelContext else { // Correct unwrapping
            print("ModelContext not available.")
            return []
        }
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            return try modelContext.fetch(descriptor) // Correctly use the LOCAL 'modelContext'
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

