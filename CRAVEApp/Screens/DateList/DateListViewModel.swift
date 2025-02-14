//
//  DateListViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@Observable
final class DateListViewModel {
    @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext

    @Published var cravings: [CravingModel] = [] // ✅ Stores cravings
    @Published var groupedCravings: [String: [CravingModel]] = [:] // ✅ Stores cravings grouped by date

    // MARK: - Load Cravings
    func loadCravings() {
        Task {
            let allCravings = await fetchCravings()
            await MainActor.run {
                cravings = allCravings
                groupedCravings = groupCravingsByDate(allCravings)
            }
        }
    }

    // MARK: - Fetch Only Active Cravings
    private func fetchCravings() async -> [CravingModel] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching cravings: \(error)")
            return []
        }
    }

    // MARK: - Group Cravings by Date
    private func groupCravingsByDate(_ cravings: [CravingModel]) -> [String: [CravingModel]] {
        var grouped = [String: [CravingModel]]()
        let formatter = DateFormatter()
        formatter.dateStyle = .long

        for craving in cravings {
            let dateKey = formatter.string(from: craving.timestamp)
            grouped[dateKey, default: []].append(craving)
        }

        return grouped
    }
}
