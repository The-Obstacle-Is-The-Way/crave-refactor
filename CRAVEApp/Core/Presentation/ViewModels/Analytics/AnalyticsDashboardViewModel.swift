// Core/Presentation/ViewModels/Analytics/AnalyticsDashboardViewModel.swift
import Foundation
import SwiftData
import SwiftUI

@MainActor
public final class AnalyticsDashboardViewModel: ObservableObject { // ADDED public HERE.  THIS IS THE FIX.
    @Published var basicStats: BasicAnalyticsResult?
    @Published var isLoading = false
    private let manager: AnalyticsManager

    public init(manager: AnalyticsManager) { //This was already fixed
        self.manager = manager
    }

    func loadAnalytics() async {
        isLoading = true
        do {
            basicStats = try await manager.getBasicStats()
        } catch {
            print("Failed to load analytics: \(error)")
        }
        isLoading = false
    }
}

