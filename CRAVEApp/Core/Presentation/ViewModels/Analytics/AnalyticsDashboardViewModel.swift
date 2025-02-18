// Core/Presentation/ViewModels/Analytics/AnalyticsDashboardViewModel.swift
import Foundation
import SwiftData
import SwiftUI

@MainActor
public class AnalyticsDashboardViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    @Published var isLoading = false
    private let manager: AnalyticsManager // Correct: Takes the manager

    init(manager: AnalyticsManager) { // Correct: Initializes with the manager
        self.manager = manager
    }

    func loadAnalytics() async {
        isLoading = true
        do {
            basicStats = try await manager.getBasicStats() // Correct: Uses the manager
        } catch {
            print("Failed to load analytics: \(error)")
        }
        isLoading = false
    }
}

