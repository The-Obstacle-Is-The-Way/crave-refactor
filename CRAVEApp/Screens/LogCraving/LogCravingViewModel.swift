//
//  LogCravingViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
final class LogCravingViewModel: ObservableObject { // ✅ Fixed `@ObservableObject`
    @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext

    @Published var cravingText: String = "" // ✅ Ensured it's a stored property

    // MARK: - Add New Craving
    func addCraving(completion: @escaping (Bool) -> Void) {
        guard !cravingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(false) // ✅ Prevent empty cravings
            return
        }

        let newCraving = CravingModel(cravingText: cravingText, timestamp: Date())
        modelContext.insert(newCraving)

        do {
            try modelContext.save()
            completion(true)
        } catch {
            print("Error saving craving: \(error)")
            completion(false)
        }
    }
}
