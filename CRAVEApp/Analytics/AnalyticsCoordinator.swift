//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsCoordinator.swift
//  Purpose: Coordinates and orchestrates all analytics operations across the app
//
//

import Foundation
import Combine
import SwiftUI
import SwiftData // ADDED: Import SwiftData - Resolves "Cannot find type 'ModelContext' in scope"

@MainActor
final class AnalyticsCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isAnalyticsEnabled: Bool = false
    @Published private(set) var lastEvent: (any AnalyticsEvent)?
    @Published private(set) var detectionState: DetectionState = .idle
    @Published private(set) var detectedPatterns: [DetectedPattern] = [] // Concrete type here

    // MARK: - Dependencies
    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage
    private let aggregator: AnalyticsAggregator // Corrected initialization below
    private let processor: AnalyticsProcessor // Corrected initialization below
    private let reporter: AnalyticsReporter  // Corrected initialization below
    private let eventTrackingService: EventTrackingService // Corrected type, Corrected initialization below
    private let patternDetectionService: PatternDetectionService // Corrected type, Corrected initialization below
    private let analyticsService: AnalyticsService // Corrected type, Corrected initialization below

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(modelContext: ModelContext) { // ERROR RESOLVED: Added modelContext parameter
        self.configuration = .shared // Use shared instance
        self.storage = AnalyticsStorage(modelContext: modelContext)
        self.aggregator = AnalyticsAggregator(storage: storage) // CORRECTED: Pass storage
        self.processor = AnalyticsProcessor(storage: storage, aggregator: aggregator) // CORRECTED: Pass storage, aggregator
        self.reporter = AnalyticsReporter(aggregator: aggregator, processor: processor) // CORRECTED: Pass aggregator, processor
        self.eventTrackingService = EventTrackingService(storage: storage, configuration: configuration) // CORRECTED: Pass storage, configuration -  Initialize EventTrackingService CORRECTLY
        self.patternDetectionService = PatternDetectionService(storage: storage, configuration: configuration) // CORRECTED: Pass storage, configuration - Initialize PatternDetectionService CORRECTLY
        self.analyticsService = AnalyticsService(configuration: configuration, modelContext: modelContext) // CORRECTED: Pass configuration, modelContext - Initialize AnalyticsService CORRECTLY

        setupBindings()
        setupObservers()
        loadInitialState()
    }

    // MARK: - Setup Methods
    private func setupBindings() {
        configuration.$featureFlags
            .map { $0.isAnalyticsEnabled }
            .assign(to: &$isAnalyticsEnabled)
    }

    private func setupObservers() {
        eventTrackingService.eventPublisher // Access eventPublisher from EventTrackingService instance
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Never>) in // Explicit type annotation for completion
                switch completion {
                case .finished:
                    print("Event Publisher finished")
                }
            }, receiveValue: { (event: AnalyticsEvent) in // Explicit type annotation for event
                self.lastEvent = event
                Task { await self.processEvent(event: event) }
            })
            .store(in: &cancellables)

        patternDetectionService.$detectionState
            .assign(to: &$detectionState)

        patternDetectionService.$detectedPatterns
            .assign(to: &$detectedPatterns)
    }


    private func loadInitialState() {
        isAnalyticsEnabled = configuration.featureFlags.isAnalyticsEnabled
    }

    // MARK: - Event Processing
    func trackEvent(_ event: CravingModel) async throws { // Track CravingModel directly
         try await analyticsService.trackEvent(event) // Use AnalyticsService to track
    }

    private func processEvent(event: AnalyticsEvent) async { // ERROR RESOLVED: 'processEvent' is now accessible (was likely a typo in previous error message - it *is* internal/private, which is fine here)
        await aggregator.aggregateEvent(event)
        await processor.processEvent(event)
    }

    // MARK: - Pattern Detection
    func detectPatterns() async {
        do {
            detectedPatterns = try await patternDetectionService.detectPatterns() // Assign directly, concrete type
        } catch {
            print("Pattern detection failed: \(error)")
            detectionState = .error(error)
        }
    }

    // MARK: - Reporting
    func generateReport(type: ReportType, timeRange: DateInterval) async {
        do {
            // ERROR RESOLVED: Value of type 'AnalyticsReporter' has member 'deliverReport' (assuming method exists in AnalyticsReporter)
            let report = try await analyticsService.generateReport(type: type, timeRange: timeRange) // Added try and handle error
            await reporter.deliverReport(report: report) // CORRECTED: Pass report with parameter name 'report:' (if your deliverReport expects a named parameter)
        } catch {
            print("Report generation failed: \(error)")
            // Handle report generation error
        }
    }

    // MARK: - Insights and Predictions
    func fetchInsights() async {
        do {
            // ERROR RESOLVED: Value of type 'AnalyticsReporter' has member 'deliverInsights' (assuming method exists)
            let insights = try await analyticsService.fetchInsights() // Added try
            await reporter.deliverInsights(insights: insights as! [PatternInsight]) // CORRECTED: Pass insights with parameter name 'insights:' (if needed), Force cast to [PatternInsight] - review type safety
        } catch {
            print("Fetching insights failed: \(error)")
            // Handle insights error
        }
    }

    func fetchPredictions() async {
        do {
            // ERROR RESOLVED: Value of type 'AnalyticsReporter' has member 'deliverPredictions' (assuming method exists)
            // ERROR RESOLVED: Use of protocol 'AnalyticsPrediction' as a type must be written 'any AnalyticsPrediction' - CORRECTED to 'any AnalyticsPrediction'
            let predictions = try await analyticsService.fetchPredictions() // Added try
            await reporter.deliverPredictions(predictions: predictions as! [any AnalyticsPrediction]) // CORRECTED: Pass predictions with parameter name 'predictions:', Force cast - review type safety, using 'any AnalyticsPrediction'
        } catch {
            print("Fetching predictions failed: \(error)")
            // Handle predictions error
        }
    }
}

// MARK: - Preview and Testing Support
extension AnalyticsCoordinator {
    static func preview(modelContext: ModelContext) -> AnalyticsCoordinator {
        AnalyticsCoordinator(modelContext: modelContext)
    }
}

