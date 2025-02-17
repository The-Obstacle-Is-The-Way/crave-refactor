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

    func loadAnalytics() {
        Task {
            self.basicStats = await analyticsManager.getBasicStats()
        }
    }
}
