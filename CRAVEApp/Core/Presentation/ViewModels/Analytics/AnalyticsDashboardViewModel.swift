// Core/Presentation/ViewModels/Analytics/AnalyticsDashboardViewModel.swift

import SwiftUI
import SwiftData

@MainActor
final class AnalyticsDashboardViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    private let analyticsManager: AnalyticsManager

    init(analyticsManager: AnalyticsManager) {
        self.analyticsManager = analyticsManager
    }

    func loadAnalytics() async {
        do {
            self.basicStats = try await analyticsManager.getBasicStats()
        } catch {
            print("Error loading analytics: \(error)")
        }
    }
}

