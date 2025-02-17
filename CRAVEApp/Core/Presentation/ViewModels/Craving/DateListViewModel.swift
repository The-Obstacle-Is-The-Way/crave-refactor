//  CRAVEApp/Core/Presentation/ViewModels/Craving/DateListViewModel.swift

import Foundation
import SwiftData

@MainActor
final class DateListViewModel: ObservableObject {
    @Published var cravings: [CravingEntity] =
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    /// Groups cravings by the day they occurred.
    var groupedCravings: [String: [CravingEntity]] {
        Dictionary(grouping: cravings) { craving in
            craving.timestamp.formattedDate()
        }
    }

    func loadCravings() {
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
            // TODO: Handle the error (e.g., show an error message)
        }
    }
}
