//
//  LogCravingViewModel.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25
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
        guard !cravingText.isEmpty else { return }
        // Call the initializer without a label.
        let newCraving = Craving(cravingText)
        context.insert(newCraving)
        do {
            try context.save()
            CRAVEDesignSystem.Haptics.success()
            cravingText = ""
        } catch {
            print("Failed to save new craving: \(error)")
            CRAVEDesignSystem.Haptics.error()
        }
    }
}
