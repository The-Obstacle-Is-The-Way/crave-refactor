import SwiftUI
import SwiftData

@MainActor
final class DateListViewModel: ObservableObject {
    @Environment(\.modelContext) private var modelContext
    @Published var cravings: [CravingModel] = []
    
    /// Groups cravings by the day they occurred.
    var groupedCravings: [String: [CravingModel]] {
        Dictionary(grouping: cravings) { craving in
            // Use the date style appropriate for your UI needs
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: craving.timestamp)
        }
    }
    
    /// Loads cravings from the persistent store asynchronously.
    func loadCravings() {
        Task {
            let fetchedCravings = await fetchCravings()
            await MainActor.run {
                cravings = fetchedCravings
            }
        }
    }
    
    /// Asynchronously fetches only active (non-archived) cravings.
    private func fetchCravings() async -> [CravingModel] {
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching cravings: \(error)")
            return []
        }
    }
}
