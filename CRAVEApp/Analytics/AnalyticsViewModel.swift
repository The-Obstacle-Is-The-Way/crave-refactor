//
//  AnalyticsViewModel.swift
//  CRAVE
//

import SwiftUI

final class AnalyticsViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    private let analyticsManager: AnalyticsManager

    // This initializer accepts a CravingManager.
    init(cravingManager: CravingManager) {
        // AnalyticsManager is initialized with a CravingManager.
        self.analyticsManager = AnalyticsManager(cravingManager: cravingManager)
    }

    func loadAnalytics() {
        Task {
            let stats = await analyticsManager.getBasicStats()
            await MainActor.run {
                self.basicStats = stats
            }
        }
    }
}
