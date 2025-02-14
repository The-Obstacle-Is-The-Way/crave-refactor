//
//  LogCravingViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@Observable
final class LogCravingViewModel {
    @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext
    @Published var cravingText: String = "" // ✅ Stores user input

    // MARK: - Add New Craving
    func addCraving(completion: @escaping (Bool) -> Void) {
        guard !cravingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(false) // ✅ Prevents empty input
            return
        }

        Task {
            let newCraving = CravingModel(cravingText: cravingText, timestamp: Date())
            modelContext.insert(newCraving)

            do {
                try modelContext.save()
                await MainActor.run {
                    cravingText = "" // ✅ Clears input after saving
                    completion(true) // ✅ Confirm successful save
                }
            } catch {
                print("Error saving craving: \(error)")
                completion(false)
            }
        }
    }
}
