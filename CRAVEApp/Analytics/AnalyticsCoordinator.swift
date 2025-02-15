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
    @Published private(set) var detectedPatterns: [AnalyticsPattern] = []

    // MARK: - Dependencies
    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage
    private let aggregator: AnalyticsAggregator
    private let reporter: AnalyticsReporter
    private let eventTrackingService: EventTrackingService
    private let patternDetectionService: PatternDetectionService
    private let analyticsService: AnalyticsService

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()

    init(modelContext: ModelContext) {
        self.configuration = .shared
        self.storage = AnalyticsStorage(modelContext: modelContext)
        self.aggregator = AnalyticsAggregator(storage: storage)
        self.reporter = AnalyticsReporter(analyticsStorage: storage)
        self.eventTrackingService = EventTrackingService(storage: storage, configuration: configuration)
        self.patternDetectionService = PatternDetectionService(storage: storage, configuration: configuration)
        self.analyticsService = AnalyticsService(configuration: configuration, modelContext: modelContext)

        setupBindings()
        setupObservers()
    }

    private func setupBindings() {
        configuration.$featureFlags
            .map { $0.isAnalyticsEnabled }
            .assign(to: &$isAnalyticsEnabled)
    }

    private func setupObservers() {
        eventTrackingService.eventPublisher
            .sink { completion in
                if case .finished = completion {
                    print("Event Publisher finished")
                }
            } receiveValue: { [weak self] event in
                self?.lastEvent = event
                Task { [weak self] in
                    await self?.handleEvent(event)
                }
            }
            .store(in: &cancellables)
    }

    private func handleEvent(_ event: AnalyticsEvent) async {
        await aggregator.aggregateEvent(event)
    }

    func trackEvent(_ event: CravingModel) async throws {
        try await analyticsService.trackEvent(event)
    }

    func detectPatterns() async {
        do {
            let patterns = try await patternDetectionService.detectPatterns()
            self.detectedPatterns = patterns.map { pattern in
                AnalyticsPattern(
                    id: UUID(),
                    type: pattern.type.rawValue,
                    confidence: pattern.confidence,
                    description: pattern.description
                )
            }
            self.detectionState = .completed
        } catch {
            print("Pattern detection failed: \(error)")
            self.detectionState = .error(error)
        }
    }

    func generateReport(type: ReportType, timeRange: DateInterval) async throws -> Report {
        let report = try await analyticsService.generateReport(type: type, timeRange: timeRange)
        await reporter.handleReport(report)
        return report
    }

    func fetchInsights() async throws -> [any AnalyticsInsight] {
        let insights = try await analyticsService.fetchInsights()
        await reporter.handleInsights(insights)
        return insights
    }

    func fetchPredictions() async throws -> [any AnalyticsPrediction] {
        let predictions = try await analyticsService.fetchPredictions()
        await reporter.handlePredictions(predictions)
        return predictions
    }
}

// MARK: - Supporting Types
struct AnalyticsPattern: Identifiable {
    let id: UUID
    let type: String
    let confidence: Double
    let description: String
}

enum DetectionState: Equatable {
    case idle
    case detecting
    case completed
    case error(Error)
    
    static func == (lhs: DetectionState, rhs: DetectionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.detecting, .detecting),
             (.completed, .completed):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
