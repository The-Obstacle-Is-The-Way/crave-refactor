// App/Core/Presentation/ViewModels/Analytics/AnalyticsDashboardViewModel.swift
import Foundation
import SwiftUI
import SwiftData
import Combine


@MainActor // Ensure UI updates happen on the main thread
public final class AnalyticsDashboardViewModel: ObservableObject {
    @Published public var basicStats: BasicAnalyticsResult?
    @Published public var isLoading = false // Add loading state
    private let manager: AnalyticsManager // Dependency
    //private let modelContext: ModelContext // No need to pass this in.


    init(manager: AnalyticsManager) { // Take AnalyticsManager as a dependency
        self.manager = manager
        //self.modelContext = modelContext // No need to pass this in.
    }


    func loadAnalytics() async {
        isLoading = true // Set loading state
        do {
            self.basicStats = try await manager.getBasicStats() // Use the manager to fetch data
        } catch {
            // Handle errors
            print("Error loading analytics: \(error)")
            // Optionally set an error state
        }
        isLoading = false // Clear loading state
    }
}

