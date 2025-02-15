//
//  AnalyticsViewModel.swift
//  CRAVE
//
//

import Foundation
import SwiftData
import Combine

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    private var analyticsManager: AnalyticsManager? // Use the manager

    func loadAnalytics(modelContext: ModelContext) {
        // Initialize the AnalyticsManager here, when the context is available
        analyticsManager = AnalyticsManager(modelContext: modelContext)

        Task {
            // Safely unwrap the optional manager
            if let manager = analyticsManager {
                self.basicStats = await manager.getBasicStats()
            } else {
                print("Error: AnalyticsManager not initialized.")
                // Consider setting an error state here that you can display in the UI.
            }
        }
    }
}
