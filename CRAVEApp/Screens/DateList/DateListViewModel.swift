//
// 🍒
// CRAVEApp/Screens/DateList/DateListViewModel.swift
//
//

import Foundation
import SwiftData

@MainActor
final class DateListViewModel: ObservableObject {
    @Published var cravings: [CravingModel] = []

    init() {
        // Initialization, if needed
    }

    /// Groups cravings by the day they occurred.
    var groupedCravings: [String: [CravingModel]] {
        Dictionary(grouping: cravings) { craving in
            craving.timestamp.formattedDate() // Use the extension method
        }
    }

    func loadCravings(modelContext: ModelContext) { // Pass modelContext
        Task {
            await fetchCravings(modelContext: modelContext) // Await the fetch
        }
    }

    private func fetchCravings(modelContext: ModelContext) async { // Separate async method
        do {
            let descriptor = FetchDescriptor<CravingModel>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let fetchedCravings = try modelContext.fetch(descriptor)
            // Update on the main thread
            self.cravings = fetchedCravings // No need for MainActor.run, we're already on @MainActor

        } catch {
            print("Error fetching cravings: \(error)")
            // TODO: Handle the error (e.g., show an error message)
        }
    }
}

// Extension for date formatting (Keep this for now)
extension Date {
    /// Returns a formatted date string (e.g., "Jan 1, 2023").
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
