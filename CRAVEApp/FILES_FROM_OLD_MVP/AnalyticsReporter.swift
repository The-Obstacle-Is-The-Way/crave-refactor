// Core/Domain/Interactors/Analytics/AnalyticsCoordinator.swift

import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
class AnalyticsCoordinator: ObservableObject {
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

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        eventTrackingService: EventTrackingService,
        patternDetectionService: PatternDetectionService,
        configuration: AnalyticsConfiguration,
        storage: AnalyticsStorage,
        aggregator: AnalyticsAggregator,
        processor: AnalyticsProcessor,
        reporter: AnalyticsReporter
    ) {
        self.configuration = configuration
        self.storage = storage
        self.aggregator = aggregator
        self.processor = processor
        self.reporter = reporter
        self.eventTrackingService = eventTrackingService
        self.patternDetectionService = patternDetectionService

        setupObservers()
        loadInitialState()
    }

    private func setupObservers() {
        eventTrackingService.eventPublisher
          .sink { [weak self] completion in
                if case let.failure(error) = completion {
                    self?.detectionState = .error(error)
                }
            } receiveValue: { [weak self] event in
                self?.lastEvent = event
                Task {
                    await self?.handleEvent(event)
                }
            }
          .store(in: &cancellables)

        patternDetectionService.$detectionState
          .sink { [weak self] state in
                switch state {
                case.idle:
                    self?.detectionState = .idle
                case.processing:
                    self?.detectionState = .processing
                case.completed:
                    self?.detectionState = .completed
                case.error(let error):
                    self?.detectionState = .error(error)
                }
            }
          .store(in: &cancellables)

        patternDetectionService.$detectedPatterns
          .assign(to: &$detectedPatterns)
    }


    private func loadInitialState() {
        isAnalyticsEnabled = configuration.featureFlags.isAnalyticsEnabled
    }

    // MARK: - Event Processing
    func trackEvent(_ event: CravingEntity) async throws {
        try await eventTrackingService.trackCravingEvent(CravingEvent(cravingId: event.id, cravingText: event.text))
    }

    private func handleEvent(_ event: AnalyticsEvent) async {
        await aggregator.aggregateEvent(event)
        await processor.processEvent(event)
    }

    // MARK: - Pattern Detection
    func detectPatterns() async {
        detectionState = .processing
        do {
            _ = try await patternDetectionService.detectPatterns()
            detectionState = .completed
        } catch {
            print("Pattern detection failed: \(error)")
            detectionState = .error(error)
        }
    }

    // Enum for the detectionState
    enum DetectionState {
        case idle
        case processing
        case completed
        case error(Error)
    }
}
