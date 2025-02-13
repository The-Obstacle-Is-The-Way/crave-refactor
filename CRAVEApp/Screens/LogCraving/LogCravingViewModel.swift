//
//  LogCravingViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData
import Foundation

@Observable
class LogCravingViewModel {
    var cravingText: String = ""

    // Extra validation or business logic can go here as needed.
    func submitCraving(context: ModelContext) {
        guard !cravingText.isEmpty else {
            print("🚫 submitCraving() aborted: Empty craving text")
            return
        }

        print("📝 submitCraving() called with text: \(cravingText)")

        let newCraving = Craving(cravingText)
        context.insert(newCraving)

        do {
            print("💾 Attempting to save craving...")
            try context.save()
            print("✅ Craving saved successfully!")

            CRAVEDesignSystem.Haptics.success()
            cravingText = ""
        } catch {
            print("❌ Failed to save new craving: \(error)")
            CRAVEDesignSystem.Haptics.error()
        }
    }
}
