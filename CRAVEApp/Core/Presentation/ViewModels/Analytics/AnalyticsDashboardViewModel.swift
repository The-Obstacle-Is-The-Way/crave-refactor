// Core/Presentation/ViewModels/Analytics/AnalyticsDashboardViewModel.swift


import SwiftUI
import SwiftData

@MainActor
public final class AnalyticsDashboardViewModel: ObservableObject {
    @Published public var basicStats: BasicAnalyticsResult?
    @Published public var isLoading: Bool = false
    private let manager: AnalyticsManager

    // Public initializer so that this view model can be constructed externally.
    public init(manager: AnalyticsManager) {
        self.manager = manager
    }
    
    // Public method to load analytics.
    public func loadAnalytics() async {
        isLoading = true
        do {
            basicStats = try await manager.getBasicStats()
        } catch {
            print("Failed to load analytics: \(error)")
        }
        isLoading = false
    }
}
