// Core/Presentation/ViewModels/Craving/CravingListViewModel.swift

import SwiftUI
import SwiftData

@MainActor
final class CravingListViewModel: ObservableObject {
    @Published var cravings: [CravingEntity] = // Initialize as empty array
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    func loadData() async {
        await fetchCravings()
    }

    func archiveCraving(_ craving: CravingEntity) async {
        // TODO: Implement archive logic using the repository
        await fetchCravings()
    }

    func deleteCraving(_ craving: CravingEntity) async {
        // TODO: Implement delete logic using the repository
        await fetchCravings()
    }

    private func fetchCravings() async {
        do {
            let fetchedCravings = try await cravingRepository.fetchAllActiveCravings()
            self.cravings = fetchedCravings
        } catch {
            print("Error fetching cravings: \(error)")
            // Handle error appropriately in production
        }
    }
}
