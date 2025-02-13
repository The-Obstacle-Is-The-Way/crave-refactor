//
//  AnalyticsDashboardViewModel.swift
//  CRAVE
//

import SwiftUI
import Foundation

@MainActor
class AnalyticsDashboardViewModel: ObservableObject {
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
