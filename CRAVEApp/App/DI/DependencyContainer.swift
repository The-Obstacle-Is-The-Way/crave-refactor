// App/DI/DependencyContainer.swift
import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
public final class DependencyContainer: ObservableObject {
    @Published private(set) var modelContainer: ModelContainer
    @Published private(set) var isLoading = false
    
    public init() async {
        let schema = Schema([
            AnalyticsMetadata.self
        ])
        do {
            self.modelContainer = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - View Factories
    @ViewBuilder
    public func makeAnalyticsDashboardView() -> some View {
        let viewModel = AnalyticsDashboardViewModel(modelContext: modelContainer.mainContext)
        AnalyticsDashboardView(viewModel: viewModel)
    }
    
    // MARK: - Dependencies
    private func makeAnalyticsStorage() -> AnalyticsStorage {
        AnalyticsStorage(modelContext: modelContainer.mainContext)
    }
    
    private func makeAnalyticsManager() -> AnalyticsManager {
        let storage = makeAnalyticsStorage()
        let aggregator = AnalyticsAggregator(storage: storage)
        let patternDetection = PatternDetectionService(
            storage: storage,
            configuration: AnalyticsConfiguration.shared
        )
        
        return AnalyticsManager(
            storage: storage,
            aggregator: aggregator,
            patternDetection: patternDetection
        )
    }
}
