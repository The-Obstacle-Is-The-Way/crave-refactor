// Core/Presentation/ViewModels/Analytics/AnalyticsViewModel.swift
import SwiftUI
import SwiftData

@MainActor
public final class AnalyticsViewModel: ObservableObject {
    @Published public var isLoading = false
    private let manager: AnalyticsManager
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.manager = AnalyticsManager(
            storage: AnalyticsStorage(modelContext: modelContext),
            aggregator: AnalyticsAggregator(storage: AnalyticsStorage(modelContext: modelContext)),
            patternDetection: PatternDetectionService(
                storage: AnalyticsStorage(modelContext: modelContext),
                configuration: AnalyticsConfiguration.shared
            )
        )
    }
    
    // Add your analytics methods here
}
