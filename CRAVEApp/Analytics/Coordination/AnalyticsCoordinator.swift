//
//  🍒
//  CRAVEApp/Analytics/Coordination/AnalyticsCoordinator.swift
//  Purpose: Generates and manages analytics reports with customizable formats and delivery mechanisms
//
//

import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
class AnalyticsCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isAnalyticsEnabled: Bool = false
    @Published private(set) var lastEvent: (any AnalyticsEvent)?
    @Published private(set) var detectionState: DetectionState = .idle // Changed to local enum
    @Published private(set) var detectedPatterns: [DetectedPattern] = [] // Use DetectedPattern

    // MARK: - Dependencies
    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage // Corrected type
    private let aggregator: AnalyticsAggregator
    private let processor: AnalyticsProcessor
    private let reporter: AnalyticsReporter
    private let eventTrackingService: EventTrackingService
    private let patternDetectionService: PatternDetectionService

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(modelContext: ModelContext) { //Simplified init
        self.configuration = .shared
        self.storage = AnalyticsStorage(modelContext: modelContext)
        self.aggregator = AnalyticsAggregator(storage: storage)
        self.processor = AnalyticsProcessor(configuration: .shared, storage: storage)
        self.reporter = AnalyticsReporter(analyticsStorage: storage)
        self.eventTrackingService = EventTrackingService(storage: storage, configuration: configuration)
        self.patternDetectionService = PatternDetectionService(storage: storage, configuration: configuration)
        
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
        // Store the cancellable returned by sink
        let eventSubscription = eventTrackingService.eventPublisher
            .sink { completion in
                switch completion {
                case .finished:
                    print("Event Publisher finished")
                case .failure(let error): // Handle potential errors from eventPublisher
                    print("Event Publisher error: \(error)")
                }
            } receiveValue: { [weak self] event in
                self?.lastEvent = event
                Task { [weak self] in
                    await self?.handleEvent(event)
                }
            }
        cancellables.insert(eventSubscription) // Store the cancellable

        let detectionStateSubscription = patternDetectionService.$detectionState
            .sink { [weak self] (state: DetectionState) in // Add type annotation here
                switch state {
                case .idle:
                    self?.detectionState = .idle
                case .processing:
                    self?.detectionState = .processing
                case .completed:
                    self?.detectionState = .completed
                case .error(let error):
                    self?.detectionState = .error(error)
                }
            }
        cancellables.insert(detectionStateSubscription) // Store the cancellable

       let patternSubscription = patternDetectionService.$detectedPatterns
            .assign(to: &$detectedPatterns) // Directly assign, type is now correct
        cancellables.insert(patternSubscription) //Store the cancellable
    }

    private func loadInitialState() {
        isAnalyticsEnabled = configuration.featureFlags.isAnalyticsEnabled
    }

    // MARK: - Event Processing
    func trackEvent(_ event: CravingModel) async throws {
        try await eventTrackingService.trackCravingEvent(CravingEvent(cravingId: event.id, cravingText: event.cravingText)) // Simplified tracking
    }

    private func handleEvent(_ event: AnalyticsEvent) async {
        await aggregator.aggregateEvent(event)
        await processor.processEvent(event)
    }

    // MARK: - Pattern Detection
    func detectPatterns() async {
        detectionState = .processing // Indicate that detection is in progress
        do {
            try await patternDetectionService.detectPatterns()  // No need to return, it updates the @Published property
            detectionState = .completed
        } catch {
            print("Pattern detection failed: \(error)")
            detectionState = .error(error) // Use the associated value for the error
        }
    }
    
    //Enum for the detectionState
    enum DetectionState { // Added enum for state
        case idle
        case processing
        case completed
        case error(Error)
    }
}

