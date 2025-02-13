//
//  AnalyticsDashboardViewModel.swift
//  CRAVE
//

import SwiftUI

@MainActor
class AnalyticsDashboardViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    
    private let analyticsManager: AnalyticsManager
    
    init(analyticsManager: AnalyticsManager) {
        self.analyticsManager = analyticsManager
    }
    
    func loadAnalytics() {
        Task {
            let stats = await analyticsManager.getBasicStats()
            self.basicStats = stats
        }
    }
}
