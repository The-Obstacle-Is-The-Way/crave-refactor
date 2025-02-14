// CRAVE/Core/Services/AnalyticsManager.swift

import Foundation
import SwiftData
import Combine

@MainActor
final class AnalyticsManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentAnalytics: AnalyticsSnapshot?
    @Published private(set) var processingState: ProcessingState = .idle
    @Published private(set) var lastUpdateTime: Date?
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    private let analyticsStorage: AnalyticsStorage
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Analytics Processors
    private let frequencyAnalyzer: FrequencyAnalyzer
    private let patternAnalyzer: PatternAnalyzer
    private let insightGenerator: InsightGenerator
    private let predictionEngine: PredictionEngine
    
    // MARK: - Configuration
    private let config: AnalyticsConfiguration
    
    // MARK: - Initialization
    init(modelContext: ModelContext,
         analyticsStorage: AnalyticsStorage = AnalyticsStorage(),
         configuration: AnalyticsConfiguration = .default) {
        self.modelContext = modelContext
        self.analyticsStorage = analyticsStorage
        self.config = configuration
        
        // Initialize analyzers
        self.frequencyAnalyzer = FrequencyAnalyzer(configuration: configuration)
        self.patternAnalyzer = PatternAnalyzer(configuration: configuration)
        self.insightGenerator = InsightGenerator(configuration: configuration)
        self.predictionEngine = PredictionEngine(configuration: configuration)
        
        setupObservers()
    }
    
    // MARK: - Public Interface
    func processNewCraving(_ craving: CravingModel) async throws {
        guard processingState == .idle else {
            throw AnalyticsError.alreadyProcessing
        }
        
        processingState = .processing
        
        do {
            // Create analytics metadata
            let metadata = AnalyticsMetadata(cravingId: craving.id)
            
            // Process contextual data
            let contextualData = try await processContextualData(for: craving)
            
            // Process interaction data
            let interactionData = try await processInteractionData(for: craving)
            
            // Generate analytics
            let analytics = try await generateAnalytics(
                craving: craving,
                metadata: metadata,
                contextualData: contextualData,
                interactionData: interactionData
            )
            
            // Store results
            try await storeAnalytics(analytics)
            
            // Update current snapshot
            currentAnalytics = try await generateSnapshot()
            
            processingState = .idle
            lastUpdateTime = Date()
            
        } catch {
            processingState = .error
            throw AnalyticsError.processingFailed(error)
        }
    }
    
    func generateInsights() async throws -> [AnalyticsInsight] {
        guard let analytics = currentAnalytics else {
            throw AnalyticsError.noDataAvailable
        }
        
        return try await insightGenerator.generateInsights(from: analytics)
    }
    
    func predictNextCraving() async throws -> CravingPrediction {
        return try await predictionEngine.predictNextCraving(using: currentAnalytics)
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        // Setup SwiftData observation
        // Setup configuration changes observation
        // Setup real-time analytics updates
    }
    
    private func processContextualData(for craving: CravingModel) async throws -> ContextualData {
        // Process and analyze contextual data
        return ContextualData(cravingId: craving.id)
    }
    
    private func processInteractionData(for craving: CravingModel) async throws -> InteractionData {
        // Process and analyze interaction data
        return InteractionData(cravingId: craving.id)
    }
    
    private func generateAnalytics(
        craving: CravingModel,
        metadata: AnalyticsMetadata,
        contextualData: ContextualData,
        interactionData: InteractionData
    ) async throws -> CravingAnalytics {
        // Generate comprehensive analytics
        return CravingAnalytics(
            id: UUID(),
            cravingId: craving.id,
            metadata: metadata,
            contextualData: contextualData,
            interactionData: interactionData,
            timestamp: Date()
        )
    }
    
    private func storeAnalytics(_ analytics: CravingAnalytics) async throws {
        try await analyticsStorage.store(analytics)
    }
    
    private func generateSnapshot() async throws -> AnalyticsSnapshot {
        // Generate current analytics snapshot
        return AnalyticsSnapshot(
            timestamp: Date(),
            metrics: try await calculateMetrics(),
            patterns: try await identifyPatterns(),
            predictions: try await generatePredictions()
        )
    }
    
    private func calculateMetrics() async throws -> AnalyticsMetrics {
        return try await frequencyAnalyzer.calculateMetrics()
    }
    
    private func identifyPatterns() async throws -> [CravingPattern] {
        return try await patternAnalyzer.identifyPatterns()
    }
    
    private func generatePredictions() async throws -> [CravingPrediction] {
        return try await predictionEngine.generatePredictions()
    }
}

// MARK: - Supporting Types
extension AnalyticsManager {
    enum ProcessingState {
        case idle
        case processing
        case error
    }
    
    enum AnalyticsError: Error {
        case alreadyProcessing
        case noDataAvailable
        case processingFailed(Error)
        case invalidConfiguration
        case storageError
        
        var localizedDescription: String {
            switch self {
            case .alreadyProcessing:
                return "Analytics processing already in progress"
            case .noDataAvailable:
                return "No analytics data available"
            case .processingFailed(let error):
                return "Analytics processing failed: \(error.localizedDescription)"
            case .invalidConfiguration:
                return "Invalid analytics configuration"
            case .storageError:
                return "Analytics storage error"
            }
        }
    }
}

// MARK: - Testing Support
extension AnalyticsManager {
    static func preview() -> AnalyticsManager {
        let config = AnalyticsConfiguration.preview
        let context = try! ModelContainer(for: CravingModel.self).mainContext
        return AnalyticsManager(modelContext: context, configuration: config)
    }
}
