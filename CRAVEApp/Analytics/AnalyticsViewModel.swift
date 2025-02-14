//
//  AnalyticsViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@Observable
final class AnalyticsViewModel {
    @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext

    @Published var cravings: [CravingModel] = [] // ✅ Stores cravings
    @Published var cravingsByDate: [String: Int] = [:] // ✅ Stores data for bar chart
    @Published var cravingsByTimeOfDay: [String: Int] = [:] // ✅ Stores data for pie chart

    // MARK: - Load Analytics Data
    func loadAnalytics() {
        Task {
            let allCravings = await fetchCravings()
            await MainActor.run {
                cravings = allCravings
                cravingsByDate = groupCravingsByDate(allCravings)
                cravingsByTimeOfDay = groupCravingsByTime(allCravings)
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
    private func groupCravingsByDate(_ cravings: [CravingModel]) -> [String: Int] {
        var grouped = [String: Int]()
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        for craving in cravings {
            let dateKey = formatter.string(from: craving.timestamp)
            grouped[dateKey, default: 0] += 1
        }

        return grouped
    }

    // MARK: - Group Cravings by Time of Day
    private func groupCravingsByTime(_ cravings: [CravingModel]) -> [String: Int] {
        var grouped = ["Morning": 0, "Afternoon": 0, "Evening": 0, "Night": 0]

        for craving in cravings {
            let hour = Calendar.current.component(.hour, from: craving.timestamp)
            switch hour {
            case 6..<12: grouped["Morning", default: 0] += 1
            case 12..<18: grouped["Afternoon", default: 0] += 1
            case 18..<24: grouped["Evening", default: 0] += 1
            default: grouped["Night", default: 0] += 1
            }
        }

        return grouped
    }
}
