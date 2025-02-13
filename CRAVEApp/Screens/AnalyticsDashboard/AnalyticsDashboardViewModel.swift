//
//  AnalyticsDashboardViewModel.swift
//  CRAVE
//

import SwiftUI

@MainActor
public class AnalyticsDashboardViewModel: ObservableObject {
    @Published public var basicStats: BasicAnalyticsResult?
    
    private let analyticsManager: AnalyticsManager
    
    public init(analyticsManager: AnalyticsManager) {
        self.analyticsManager = analyticsManager
    }
    
    public func loadAnalytics() {
        Task {
            self.basicStats = await analyticsManager.getBasicStats()
        }
    }
}
