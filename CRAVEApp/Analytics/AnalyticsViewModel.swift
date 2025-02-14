//
//  AnalyticsViewModel.swift
//  CRAVE
//

import SwiftUI

final class AnalyticsViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    private let analyticsManager: AnalyticsManager

    // This initializer expects a CravingManager.
    init(cravingManager: CravingManager) {
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
