//
// File: EventTrackingService.swift
// Purpose: Dedicated service for tracking and managing user and system events
//

import Foundation
import SwiftData
import Combine

// MARK: - Event Tracking Protocol
protocol EventTrackingServiceProtocol {
    func trackUserEvent(_ event: UserEvent) async throws
    func trackSystemEvent(_ event: SystemEvent) async throws
    func trackCravingEvent(_ event: CravingEvent) async throws
    func trackInteractionEvent(_ event: InteractionEvent) async throws
    func getEvents(ofType type: EventType, in timeRange: DateInterval) async throws -> [TrackedEvent] // Assuming TrackedEvent is still needed, though we might remove it later
}

// MARK: - Event Tracking Service
@MainActor
final class EventTrackingService: EventTrackingServiceProtocol, ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var trackingEnabled: Bool
    @Published private(set) var lastTrackedEvent: (any AnalyticsEvent)? // Use the protocol
    @Published private(set) var trackingMetrics: TrackingMetrics

    // MARK: - Dependencies
    private let storage: AnalyticsStorage
    private let configuration: AnalyticsConfiguration

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        storage: AnalyticsStorage,
        configuration: AnalyticsConfiguration = .shared
    ) {
        self.storage = storage
        self.configuration = configuration
        self.trackingEnabled = configuration.featureFlags.isAnalyticsEnabled
        self.trackingMetrics = TrackingMetrics()
        setupService()
    }

    // MARK: - Public Methods
    func trackUserEvent(_ event: UserEvent) async throws {
        guard trackingEnabled else { return }
        try await trackEvent(event)
    }

    func trackSystemEvent(_ event: SystemEvent) async throws {
        guard trackingEnabled else { return }
        try await trackEvent(event)
    }

    func trackCravingEvent(_ event: CravingEvent) async throws {
        guard trackingEnabled else { return }
        try await trackEvent(event)
    }

    func trackInteractionEvent(_ event: InteractionEvent) async throws {
        guard trackingEnabled else { return }
        try await trackEvent(event)
    }
    
    func getEvents(ofType type: EventType, in timeRange: DateInterval) async throws -> [TrackedEvent] {
        return []  // Placeholder: No events being tracked
    }


    // MARK: - Private Methods
    private func setupService() {
        setupConfigurationObserver()
    }

    private func setupConfigurationObserver() {
        NotificationCenter.default
            .publisher(for: .analyticsConfigurationUpdated)
            .sink { [weak self] _ in
                self?.handleConfigurationUpdate()
            }
            .store(in: &cancellables)
    }


    private func trackEvent(_ event: any AnalyticsEvent) async throws { // Use the protocol
        do {
            try await storage.store(event)
            lastTrackedEvent = event
            updateMetrics(for: event) // Pass the event

        } catch {
            trackingMetrics.incrementErrors()
            throw EventTrackingError.trackingFailed(error)
        }
    }

    private func handleConfigurationUpdate() {
        trackingEnabled = configuration.featureFlags.isAnalyticsEnabled
    }

    private func updateMetrics(for event: any AnalyticsEvent) { // Use the protocol
        trackingMetrics.incrementTracked(eventType: event.eventType) // Use the eventType property
    }
}


// MARK: - Supporting Types

struct TrackingMetrics {
    private(set) var totalTracked: Int = 0
    private(set) var errorCount: Int = 0
    private(set) var eventCounts: [AnalyticsEventType: Int] = [:] // Use the enum

    mutating func incrementTracked(eventType: AnalyticsEventType) { // Use the enum
        totalTracked += 1
        eventCounts[eventType, default: 0] += 1
    }

    mutating func incrementErrors() {
        errorCount += 1
    }
}

enum EventTrackingError: Error {
    case trackingFailed(Error)
    case validationFailed(String) // Not used now, but kept for potential future use
    case storageError(Error)

    var localizedDescription: String {
        switch self {
        case .trackingFailed(let error):
            return "Event tracking failed: \(error.localizedDescription)"
        case .validationFailed(let reason):
            return "Event validation failed: \(reason)"
        case .storageError(let error):
            return "Event storage error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Testing Support (Placeholder)
extension EventTrackingService {
    static func preview() -> EventTrackingService {
        EventTrackingService(
            storage: .preview(),
            configuration: .preview
        )
    }
}

