//
//  🍒
//  CRAVEApp/Core/Services/EventTrackingService.swift
//  Purpose: Dedicated service for tracking and managing user and system events
//
//
//

import Foundation
import SwiftData
import Combine

@MainActor
final class EventTrackingService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var trackingEnabled: Bool
    @Published private(set) var lastTrackedEvent: (any AnalyticsEvent)?
    @Published private(set) var trackingMetrics: TrackingMetrics

    // MARK: - Dependencies
    private let storage: AnalyticsStorage
    private let configuration: AnalyticsConfiguration

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()
    var eventPublisher = PassthroughSubject<AnalyticsEvent, Never>()

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

    func getEvents(ofType type: TrackingEventType, in timeRange: DateInterval) async throws -> [TrackedEvent] {
        guard trackingEnabled else { return [] }
        // Placeholder implementation
        return []
    }

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

    private func trackEvent(_ event: any AnalyticsEvent) async throws {
        do {
            try await storage.store(event)
            lastTrackedEvent = event
            updateMetrics(for: event)
            eventPublisher.send(event)
        } catch {
            trackingMetrics.incrementErrors()
            throw EventTrackingError.trackingFailed(error)
        }
    }

    private func handleConfigurationUpdate() {
        trackingEnabled = configuration.featureFlags.isAnalyticsEnabled
    }

    private func updateMetrics(for event: any AnalyticsEvent) {
        trackingMetrics.incrementTracked(eventType: event.eventType)
    }
}

// MARK: - Supporting Types
enum TrackingEventType: String, Codable {
    case user
    case system
    case craving
    case interaction
}

struct TrackedEvent: Identifiable, Codable {
    let id: UUID
    let type: TrackingEventType
    let timestamp: Date
    
    init(type: TrackingEventType) {
        self.id = UUID()
        self.type = type
        self.timestamp = Date()
    }
}

struct TrackingMetrics {
    private(set) var totalTracked: Int = 0
    private(set) var errorCount: Int = 0
    private(set) var eventCounts: [AnalyticsEventType: Int] = [:]

    mutating func incrementTracked(eventType: AnalyticsEventType) {
        totalTracked += 1
        eventCounts[eventType, default: 0] += 1
    }

    mutating func incrementErrors() {
        errorCount += 1
    }
}

enum EventTrackingError: Error, LocalizedError {
    case trackingFailed(Error)
    case validationFailed(String)
    case storageError(Error)

    var errorDescription: String? {
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

// MARK: - Testing Support and Dependency Injection
extension EventTrackingService {
    static func preview() -> EventTrackingService {
        // Use a preview context here.
      let container = try! ModelContainer(for: CravingModel.self, AnalyticsMetadata.self, InteractionData.self, ContextualData.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return EventTrackingService(
            storage: AnalyticsStorage(modelContext: container.mainContext), // Pass in the context here
            configuration: .preview
        )
    }
}

