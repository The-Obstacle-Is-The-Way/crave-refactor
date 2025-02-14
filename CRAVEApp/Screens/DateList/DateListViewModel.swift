//
//  DateListViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
final class DateListViewModel: ObservableObject { // ✅ Fixed `@ObservableObject`
    @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext

    @Published var cravings: [CravingModel] = [] // ✅ Stores cravings

    // ✅ Removed `@Published` from computed property
    var groupedCravings: [String: [CravingModel]] {
        Dictionary(grouping: cravings) { $0.timestamp.formatted(date: .abbreviated, time: .omitted) }
    }

    // MARK: - Load Cravings
    func loadCravings() {
        Task {
            let allCravings = await fetchCravings()
            await MainActor.run {
                cravings = allCravings
            }
        }
    }

    private func fetchCravings(//
    //  DateListViewModel.swift
    //  CRAVE
    //

    import SwiftUI
    import SwiftData

    @MainActor
    final class DateListViewModel: ObservableObject { // ✅ Fixed `@ObservableObject`
        @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext

        @Published var cravings: [CravingModel] = [] // ✅ Stores cravings

        // ✅ Removed `@Published` from computed property
        var groupedCravings: [String: [CravingModel]] {
            Dictionary(grouping: cravings) { $0.timestamp.formatted(date: .abbreviated, time: .omitted) }
        }

        // MARK: - Load Cravings
        func loadCravings() {
            Task {
                let allCravings = await fetchCravings()
                await MainActor.run {
                    cravings = allCravings
                }
            }
        }

        private func fetchCravings() async -> [CravingModel] {
            do {
                let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
                return try modelContext.fetch(descriptor)
            } catch {
                print("Error fetching cravings: \(error)")
                return []
            }
        }
    }) async -> [CravingModel] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching cravings: \(error)")
            return []
        }
    }
}
