// Core/Presentation/ViewModels/Craving/LogCravingViewModel.swift

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class LogCravingViewModel: ObservableObject {
    @Published var cravingText: String = ""
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    // MARK: - Add New Craving
    func addCraving(completion: @escaping (Bool) -> Void) {
        let trimmedText = cravingText.trimmingCharacters(in:.whitespacesAndNewlines)
        guard!trimmedText.isEmpty else {
            completion(false)
            return
        }

        guard trimmedText.count >= 3 else {
            completion(false)
            return
        }

        let newCraving = CravingEntity(
            id: UUID(),
            text: trimmedText,
            timestamp: Date(),
            isArchived: false
        )

        cravingRepository.addCraving(newCraving)
        completion(true)
        cravingText = ""
    }
}
