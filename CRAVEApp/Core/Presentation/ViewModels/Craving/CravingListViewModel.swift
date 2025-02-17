// Core/Presentation/ViewModels/Craving/CravingListViewModel.swift

import SwiftUI
import SwiftData

@MainActor
final class CravingListViewModel: ObservableObject {
    @Published var cravings: [CravingEntity] =
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    func loadData() async {
        await fetchCravings()
    }

    func archiveCraving(_ craving: CravingEntity) async {
        do {
            try await cravingRepository.archiveCraving(craving)
        } catch {
            print("Error archiving craving: \(error)")
            // Handle error appropriately in production
        }
        await fetchCravings()
    }

    func deleteCraving(_ craving: CravingEntity) async {
        do {
            try await cravingRepository.deleteCraving(craving)
        } catch {
            print("Error deleting craving: \(error)")
            // Handle error appropriately in production
        }
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
