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
    private let eventTrackingService: EventTrackingService
    private let patternDetectionService: PatternDetectionService
    private let analyticsService: AnalyticsService
    
    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()

    init(modelContext: ModelContext) {
        self.configuration = .shared
        self.storage = AnalyticsStorage(modelContext: modelContext)
        self.aggregator = AnalyticsAggregator(storage: storage)
        self.processor = AnalyticsProcessor(configuration: configuration, storage: storage)
        self.eventTrackingService = EventTrackingService(storage: storage, configuration: configuration)
        self.patternDetectionService = PatternDetectionService(storage: storage, configuration: configuration)
        self.analyticsService = AnalyticsService(configuration: configuration, modelContext: modelContext)

        setupBindings()
        setupObservers()
    }

    private func setupBindings() {
        configuration.$featureFlags
            .map(\.isAnalyticsEnabled)
            .assign(to: &$isAnalyticsEnabled)
    }

    private func setupObservers() {
        eventTrackingService.eventPublisher
            .sink { [weak self] event in
                self?.lastEvent = event
                Task { [weak self] in
                    await self?.handleEvent(event)
                }
            }
            .store(in: &cancellables)
    }

    func trackEvent(_ event: CravingModel) async throws {
        try await analyticsService.trackEvent(event)
    }

    private func handleEvent(_ event: AnalyticsEvent) async {
        await aggregator.aggregateEvent(event)
        await processor.processEvent(event)
    }

    func detectPatterns() async {
        do {
            let patterns = try await patternDetectionService.detectPatterns()
            self.detectedPatterns = patterns
            self.detectionState = .completed
        } catch {
            print("Pattern detection failed: \(error)")
            self.detectionState = .error(error)
        }
    }
}

// MARK: - Supporting Types
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
