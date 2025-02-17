import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
public final class AnalyticsCoordinator: ObservableObject {
    @Published public private(set) var isAnalyticsEnabled: Bool = false
    @Published public private(set) var lastEvent: (any AnalyticsEvent)?
    @Published public private(set) var detectionState: DetectionState = .idle
    @Published public private(set) var detectedPatterns: [BasicAnalyticsResult.DetectedPattern] = []

    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage
    private let aggregator: AnalyticsAggregator
    private let processor: AnalyticsProcessor
    private let reporter: AnalyticsReporter
    private let eventTrackingService: EventTrackingService
    private let patternDetectionService: PatternDetectionService

    private var cancellables = Set<AnyCancellable>()

    public enum DetectionState {
        case idle, processing, completed, error(Error)
    }

    public init(
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
                if case let .failure(error) = completion {
                    self?.detectionState = .error(error)
                }
            } receiveValue: { [weak self] event in
                self?.lastEvent = event
                Task { await self?.handleEvent(event) }
            }
            .store(in: &cancellables)

        patternDetectionService.$detectionState
            .sink { [weak self] state in
                self?.detectionState = state
            }
            .store(in: &cancellables)

        patternDetectionService.$detectedPatterns
            .assign(to: &$detectedPatterns)
    }

    private func loadInitialState() {
        isAnalyticsEnabled = configuration.featureFlags.isAnalyticsEnabled
    }

    public func trackEvent(_ event: CravingEntity) async throws {
        try await eventTrackingService.trackCravingEvent(
            CravingEvent(cravingId: event.id, cravingText: event.text)
        )
    }

    private func handleEvent(_ event: AnalyticsEvent) async {
        await aggregator.aggregateEvent(event)
        await processor.processEvent(event)
    }

    public func detectPatterns() async {
        detectionState = .processing
        do {
            _ = try await patternDetectionService.detectPatterns()
            detectionState = .completed
        } catch {
            print("Pattern detection failed: \(error)")
            detectionState = .error(error)
        }
    }
}

