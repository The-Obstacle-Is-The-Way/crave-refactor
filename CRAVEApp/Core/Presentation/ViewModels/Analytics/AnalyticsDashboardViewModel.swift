// Core/Presentation/ViewModels/Analytics/AnalyticsDashboardViewModel.swift
import Foundation
import SwiftData
import SwiftUI

@MainActor
public class AnalyticsDashboardViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    @Published var isLoading = false
    private let manager: AnalyticsManager // Receives the fully constructed manager

     init(manager: AnalyticsManager) { // Takes the manager, not the context
         self.manager = manager
    }

    func loadAnalytics() async {
        isLoading = true
        // Assuming you have a method to fetch basic analytics
        do {
            //Now uses manager
            basicStats = try await manager.getBasicStats()
        } catch {
            // Handle errors, perhaps setting an error message in the view model
            print("Failed to load analytics: \(error)")
        }
        isLoading = false
    }
}

