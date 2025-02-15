//
//  🍒
//  CRAVEApp/Screens/LogCraving/LogCravingViewModel.swift
//
//

import Foundation
import SwiftData
import SwiftUI // Import SwiftUI

@MainActor
final class LogCravingViewModel: ObservableObject { // Use @MainActor
    @Published var cravingText: String = ""
    // @Environment is for View related properties, not to be used in ViewModels
    // Removed: @Environment(\.modelContext) private var modelContext

    // MARK: - Add New Craving
    func addCraving(modelContext: ModelContext, completion: @escaping (Bool) -> Void) { // Added ModelContext
        let trimmedText = cravingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            completion(false) // Indicate failure
            return
        }

        guard trimmedText.count >= 3 else { //added validation for string length
            completion(false)
            return
        }

        let newCraving = CravingModel(cravingText: trimmedText)
        
        // Insert and save using the provided context
        modelContext.insert(newCraving)
        
        do {
             try modelContext.save()
             completion(true) // Indicate success
             cravingText = ""  //reset
        } catch {
            print("Error saving craving: \(error)")
            completion(false) // Indicate failure
        }
    }
}
