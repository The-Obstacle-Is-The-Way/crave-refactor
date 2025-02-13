//
//  LogCravingViewModel.swift
//  CRAVE
//

import UIKit
import SwiftUI
import SwiftData
import Foundation

@Observable
class LogCravingViewModel {
    var cravingText: String = ""

    // Extra validation or business logic can go here as needed.
    func submitCraving(context: ModelContext) {
        guard !cravingText.isEmpty else {
            print("❌ submitCraving() aborted: Empty craving text")
            return
        }

        print("✅ submitCraving() called with text: \(cravingText)")

        let newCraving = Craving(cravingText)
        context.insert(newCraving)

        do {
            print("🟡 Attempting to save craving...")
            try context.save()
            print("✅ Craving saved successfully!")

            // 🚨 Log all cravings after saving
            let cravings = try context.fetch(FetchDescriptor<Craving>())
            print("🔍 All Cravings in Database:")
            cravings.forEach { print("📝 \(String(describing: $0.text)) | Deleted: \($0.isDeleted) | Timestamp: \($0.timestamp)") }

            CRAVEDesignSystem.Haptics.success()
            cravingText = ""
        } catch {
            print("❌ Failed to save new craving: \(error)")
            CRAVEDesignSystem.Haptics.error()
        }
    }
}
