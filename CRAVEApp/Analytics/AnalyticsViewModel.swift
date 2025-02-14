//
//  AnalyticsViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?

    // Remove the initializer that requires `modelContext`
    // and use a method to load analytics data with `modelContext`

    func loadAnalytics(modelContext: ModelContext) {
        Task {
            let analyticsManager = AnalyticsManager(modelContext: modelContext)
            self.basicStats = await analyticsManager.getBasicStats()
        }
    }
}
