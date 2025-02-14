// File: AnalyticsCoordinator.swift
// Purpose: Coordinates and orchestrates all analytics operations across the app

import Foundation
import SwiftData
import Combine

// This class acts as a central point for coordinating analytics operations.
// It's responsible for:
// - Receiving analytics events
// - Processing events (using AnalyticsProcessor)
// - Generating insights (using AnalyticsInsightGenerator)
// - Making predictions (using PredictionEngine)
// - Storing and retrieving analytics data (using AnalyticsStorage)
// - Generating reports (using AnalyticsReporter)

final class AnalyticsCoordinator: ObservableObject {

    // MARK: - Dependencies
    private let analyticsService: AnalyticsService
    private let eventTrackingService: EventTrackingService
    private let patternDetectionService: PatternDetectionService
    private let configuration: AnalyticsConfiguration

    // MARK: - Published Properties (for UI updates)
    @Published private(set) var currentInsights: [AnalyticsInsight] = []
    @Published private(set) var currentPredictions: [AnalyticsPrediction] = []
    @Published private(set) var processingState: ProcessingState = .idle // Define this enum

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(analyticsService: AnalyticsService,
         eventTrackingService: EventTrackingService,
         patternDetectionService: PatternDetectionService,
         configuration: AnalyticsConfiguration = .shared) {

        self.analyticsService = analyticsService
        self.eventTrackingService = eventTrackingService
        self.patternDetectionService = patternDetectionService
        self.configuration = configuration

        setupObservers()
    }

    // MARK: - Setup
    private func setupObservers() {
        // Observe changes to analytics events
        eventTrackingService.eventPublisher
            .receive(on: DispatchQueue.main) // Ensure updates on main thread
            .sink { [weak self] event in
                Task {
                    try? await self?.processEvent(event)
                }
            }
            .store(in: &cancellables)

        // Observe changes to detected patterns
        patternDetectionService.patternsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] patterns in
                self?.updateInsights(with: patterns)
            }
            .store(in: &cancellables)

        // Observe changes to configuration (optional)
         configuration.$currentEnvironment
             .sink { [weak self] _ in
                 self?.refreshAnalytics()
             }
             .store(in: &cancellables)
    }


    // MARK: - Event Processing
    private func processEvent(_ event: any AnalyticsEvent) async throws {
        processingState = .processing
        do {
            try await analyticsService.processEvent(event)
            try await analyticsService.analyzeData() // Aggregate and analyze
            processingState = .idle
        } catch {
            processingState = .error
            // Handle the error appropriately (log, display message, etc.)
            print("Error processing event: \(error)")
        }
    }


    // MARK: - Insight and Prediction Updates
    private func updateInsights(with patterns: [DetectedPattern]) {
        // This is a *very* simplified example.  You would likely use the
        // AnalyticsInsightGenerator and PredictionEngine here.
        let newInsights = patterns.map { pattern -> BaseInsight in
            BaseInsight(type: .triggerPattern, title: pattern.name, description: pattern.description, confidence: pattern.strength) // Example
        }

        currentInsights = newInsights
        // Generate predictions based on patterns (simplified example)
        //  let newPredictions = ...
        //  currentPredictions = newPredictions
    }



    // MARK: - Public Interface (for UI interaction)

    func refreshAnalytics() {
        Task {
            do {
                try await analyticsService.analyzeData()
            } catch {
                // Handle error
                print("Error refreshing analytics: \(error)")
            }
        }
    }

    func generateReport(type: AnalyticsService.ReportType, timeRange: DateInterval) async throws -> AnalyticsService.Report {
         try await analyticsService.generateReport(type: type, timeRange: timeRange)
    }
}


// MARK: - Preview (Simplified for compilation)
extension AnalyticsCoordinator {
    static func preview() -> AnalyticsCoordinator {
        // Use in-memory store for previews
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: CravingModel.self, configurations: config) //, configurations: config
        let context = container.mainContext

        let analyticsService = AnalyticsService(modelContext: context)
        let eventTrackingService = EventTrackingService.preview() // You'll need a preview version
        let patternDetectionService = PatternDetectionService() // Use a basic instance

        return AnalyticsCoordinator(
            analyticsService: analyticsService,
            eventTrackingService: eventTrackingService,
            patternDetectionService: patternDetectionService,
            configuration: .preview
        )
    }
}

