//  CRAVEApp/Core/Presentation/ViewModels/Craving/LogCravingViewModel.swift

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

        // TODO: Implement addCraving logic using the repository
        completion(true)
        cravingText = ""
    }
}
