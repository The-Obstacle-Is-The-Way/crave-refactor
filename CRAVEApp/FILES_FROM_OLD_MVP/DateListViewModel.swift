import Foundation
import SwiftData

@MainActor
public final class DateListViewModel: ObservableObject {
    @Published public var cravings: [CravingEntity] = []
    private let cravingRepository: CravingRepository

    public init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    public var groupedCravings: [String: [CravingEntity]] {
        Dictionary(grouping: cravings) { craving in
            craving.timestamp.formattedDate()
        }
    }

    public func loadCravings() {
        Task {
            await fetchCravings()
        }
    }

    private func fetchCravings() async {
        do {
            let fetchedCravings = try await cravingRepository.fetchAllActiveCravings()
            self.cravings = fetchedCravings
        } catch {
            print("Error fetching cravings: \(error)")
        }
    }
}

