// Core/Presentation/ViewModels/Analytics/AnalyticsDashboardViewModel.swift
import SwiftUI
import SwiftData

@MainActor
public final class AnalyticsDashboardViewModel: ObservableObject {
    @Published public var basicStats: BasicAnalyticsResult?
    private let analyticsManager: AnalyticsManager
    
    public init(modelContext: ModelContext) {
        let storage = AnalyticsStorage(modelContext: modelContext)
        let aggregator = AnalyticsAggregator(storage: storage)
        let configuration = AnalyticsConfiguration()
        let patternDetection = PatternDetectionService(storage: storage, configuration: configuration)
        
        self.analyticsManager = AnalyticsManager(
            storage: storage,
            aggregator: aggregator,
            patternDetection: patternDetection
        )
    }
    
    public func loadAnalytics() async {
        do {
            self.basicStats = try await analyticsManager.getBasicStats()
        } catch {
            print("Error loading analytics: \(error)")
            self.basicStats = BasicAnalyticsResult.empty
        }
    }
}
