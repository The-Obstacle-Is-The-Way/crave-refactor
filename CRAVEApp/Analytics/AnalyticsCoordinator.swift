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
import SwiftData

@MainActor
final class AnalyticsCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isAnalyticsEnabled: Bool = false
    @Published private(set) var lastEvent: (any AnalyticsEvent)?
    @Published private(set) var detectionState: DetectionState = .idle
    @Published private(set) var detectedPatterns: [DetectedPattern] = []

    // MARK: - Dependencies
    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage
    private let aggregator: AnalyticsAggregator
    private let processor: AnalyticsProcessor
    private let reporter: AnalyticsReporter
    private let eventTrackingService: EventTrackingService
    private let patternDetectionService: PatternDetectionService
    private let analyticsService: AnalyticsService

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.configuration = .shared
        self.storage = AnalyticsStorage(modelContext: modelContext)
        self.aggregator = AnalyticsAggregator(storage: storage)
        self.processor = AnalyticsProcessor(configuration: .shared, storage: storage)
        self.reporter = AnalyticsReporter(analyticsStorage: storage)
        self.eventTrackingService = EventTrackingService(storage: storage, configuration: configuration)
        self.patternDetectionService = PatternDetectionService(storage: storage, configuration: configuration)
        self.analyticsService = AnalyticsService(configuration: configuration, modelContext: modelContext)

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
        eventTrackingService.eventPublisher
            .sink { completion in
                switch completion {
                case .finished:
                    print("Event Publisher finished")
                }
            } receiveValue: { [weak self] event in
                self?.lastEvent = event
                Task { [weak self] in
                    await self?.handleEvent(event)
                }
            }
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
    func trackEvent(_ event: CravingModel) async throws {
        try await analyticsService.trackEvent(event)
    }

    private func handleEvent(_ event: AnalyticsEvent) async {
        await aggregator.aggregateEvent(event)
        await processor.processEvent(event)
    }

    // MARK: - Pattern Detection
    func detectPatterns() async {
        do {
            detectedPatterns = try await patternDetectionService.detectPatterns()
        } catch {
            print("Pattern detection failed: \(error)")
            detectionState = .error(error)
        }
    }

    // MARK: - Reporting
    func generateReport(type: ReportType, timeRange: DateInterval) async throws -> Report {
        let report = try await analyticsService.generateReport(type: type, timeRange: timeRange)
        await reporter.processReport(report)
        return report
    }

    func fetchInsights() async throws -> [PatternInsight] {
        let insights = try await analyticsService.fetchInsights()
        await reporter.processInsights(insights)
        return insights
    }

    func fetchPredictions() async throws -> [any AnalyticsPrediction] {
        let predictions = try await analyticsService.fetchPredictions()
        await reporter.processPredictions(predictions)
        return predictions
    }
}

// MARK: - Supporting Types
enum DetectionState {
    case idle
    case detecting
    case completed
    case error(Error)
}

struct DetectedPattern: Identifiable {
    let id: UUID
    let type: String
    let confidence: Double
    let description: String
}

// MARK: - Preview and Testing Support
extension AnalyticsCoordinator {
    static func preview(modelContext: ModelContext) -> AnalyticsCoordinator {
        AnalyticsCoordinator(modelContext: modelContext)
    }
}

