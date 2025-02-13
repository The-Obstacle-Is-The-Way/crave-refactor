// LogCravingViewModel.swift
// Simple view model for logging a new craving.

import SwiftUI
import SwiftData
import Foundation

@Observable
class LogCravingViewModel {
    var cravingText: String = ""

    func submitCraving(context: ModelContext) {
        guard !cravingText.isEmpty else {
            print("❌ submitCraving() aborted: empty text.")
            return
        }
        let newCraving = Craving(text: cravingText)
        context.insert(newCraving)

        do {
            try context.save()
            CRAVEDesignSystem.Haptics.success()
            cravingText = ""
        } catch {
            print("❌ Failed to save new craving: \(error)")
            CRAVEDesignSystem.Haptics.error()
        }
    }
}
