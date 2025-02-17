// Core/Presentation/ViewModels/Analytics/AnalyticsViewModel.swift

import Foundation
import SwiftData
import Combine

@MainActor
class AnalyticsViewModel: ObservableObject {
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
