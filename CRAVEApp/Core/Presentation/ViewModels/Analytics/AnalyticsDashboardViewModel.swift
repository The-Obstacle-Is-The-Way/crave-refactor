// Core/Presentation/ViewModels/Analytics/AnalyticsDashboardViewModel.swift

import Foundation
import SwiftData
import SwiftUI

// Corrected class declaration
@MainActor
public class AnalyticsDashboardViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    @Published var isLoading = false
    private var modelContext: ModelContext

     init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadAnalytics() async {
        isLoading = true
        // Assuming you have a method to fetch basic analytics
        do {
            let analyticsManager = AnalyticsManager(storage: AnalyticsStorage(modelContext: modelContext), aggregator: AnalyticsAggregator(storage: AnalyticsStorage(modelContext: modelContext)), patternDetection: PatternDetectionService(storage: AnalyticsStorage(modelContext: modelContext), configuration: AnalyticsConfiguration.shared))
            basicStats = try await analyticsManager.getBasicStats()
        } catch {
            // Handle errors, perhaps setting an error message in the view model
            print("Failed to load analytics: \(error)")
        }
        isLoading = false
    }
}

