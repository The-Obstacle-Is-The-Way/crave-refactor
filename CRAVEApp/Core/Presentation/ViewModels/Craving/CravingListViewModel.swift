// Core/Presentation/ViewModels/Craving/CravingListViewModel.swift
import Foundation
import SwiftData

@MainActor
final class CravingListViewModel: ObservableObject {
    @Published var cravings: [CravingEntity] = []
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    func loadCravings() async {
        do {
            cravings = try await cravingRepository.fetchAllActiveCravings()
        } catch {
            print("Error fetching cravings: \(error)")
        }
    }
}
 
