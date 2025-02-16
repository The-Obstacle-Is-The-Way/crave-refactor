//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/AnalyticsDashboardViewModel.swift
//  Purpose: ViewModel for the Analytics Dashboard View.
//

import SwiftUI
import SwiftData

@MainActor
final class AnalyticsDashboardViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    
    func loadAnalytics(modelContext: ModelContext) {
        Task {
            let manager = AnalyticsManager(modelContext: modelContext)
            self.basicStats = await manager.getBasicStats()
        }
    }
}
