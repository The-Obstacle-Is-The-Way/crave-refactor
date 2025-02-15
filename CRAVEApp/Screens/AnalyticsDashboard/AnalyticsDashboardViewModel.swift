//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/AnalyticsDashboardViewModel.swift
//
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class AnalyticsDashboardViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    private var analyticsManager: AnalyticsManager? // Optional, as it depends on modelContext

    func loadAnalytics(modelContext: ModelContext) {
        // Initialize AnalyticsManager here, when modelContext is available
        self.analyticsManager = AnalyticsManager(modelContext: modelContext)

        Task {
            // Use 'if let' to safely unwrap analyticsManager
            if let manager = analyticsManager {
                self.basicStats = await manager.getBasicStats()
            } else {
                // Handle the case where analyticsManager is nil (shouldn't happen, but good practice)
                print("Error: AnalyticsManager not 
                      initialized.")
                // Consider setting an error state here, which you could display in the UI.
            }
        }
    }
}
