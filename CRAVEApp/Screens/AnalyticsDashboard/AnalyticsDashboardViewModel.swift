//
//  AnalyticsDashboardViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
final class AnalyticsDashboardViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    private var analyticsManager: AnalyticsManager?

    // Function to set the ModelContext
    func setModelContext(_ modelContext: ModelContext) {
        self.analyticsManager = AnalyticsManager(modelContext: modelContext)
    }

    // Load analytics data
    func loadAnalytics() {
        guard let analyticsManager = analyticsManager else {
            print("ModelContext is not set.")
            return
        }
        Task {
            self.basicStats = await analyticsManager.getBasicStats()
        }
    }
}

