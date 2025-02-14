// File: EventTrackingService.swift
// Purpose: Dedicated service for tracking and managing user and system events

import Foundation
import SwiftData
import Combine

// MARK: - Event Tracking Protocol
protocol EventTrackingServiceProtocol {
    func trackUserEvent(_ event: UserEvent) async throws
    func trackSystemEvent(_ event: SystemEvent) async throws
    func trackCravingEvent(_ event: CravingEvent) async throws
    func trackInteractionEvent(_ event: InteractionEvent) async throws
    func getEvents(ofType type: EventType, in timeRange: DateInterval) async throws -> [TrackedEvent]
}

// MARK: - Event Tracking Service
@MainActor
final class EventTrackingService: EventTrackingServiceProtocol, ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var trackingEnabled: Bool
    @Published private(set) var lastTrackedEvent: TrackedEvent?
    @Published private(set) var trackingMetrics: TrackingMetrics
    
    // MARK: - Dependencies
    private let storage: AnalyticsStorage
    private let configuration: AnalyticsConfiguration
    private let validator: EventValidator
    
    // MARK: - Internal State
    private let eventQueue: AsyncQueue<TrackedEvent>
    private var batchProcessor: BatchEventProcessor
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
        self.validator = EventValidator()
        self.eventQueue = AsyncQueue()
        self.batchProcessor = BatchEventProcessor(
            batchSize: configuration.processingRules.batchSize,
            processInterval: configuration.processingRules.processingInterval
        )
        
        setupService()
    }
    
    // MARK: - Public Methods
    func trackUserEvent(_ event: UserEvent) async throws {
        guard trackingEnabled else { return }
        
        let trackedEvent = TrackedEvent(
            type: .user,
            payload: event,
            metadata: generateEventMetadata()
        )
        
        try await trackEvent(trackedEvent)
    }
    
    func trackSystemEvent(_ event: SystemEvent) async throws {
        guard trackingEnabled else { return }
        
        let trackedEvent = TrackedEvent(
            type: .system,
            payload: event,
            metadata: generateEventMetadata()
        )
        
        try await trackEvent(trackedEvent)
    }
    
    func trackCravingEvent(_ event: CravingEvent) async throws {
        guard trackingEnabled else { return }
        
        let trackedEvent = TrackedEvent(
            type: .craving,
            payload: event,
            metadata: generateEventMetadata()
        )
        
        try await trackEvent(trackedEvent)
    }
    
    func trackInteractionEvent(_ event: InteractionEvent) async throws {
        guard trackingEnabled else { return }
        
        let trackedEvent = TrackedEvent(
            type: .interaction,
            payload: event,
            metadata: generateEventMetadata()
        )
        
        try await trackEvent(trackedEvent)
    }
    
    func getEvents(ofType type: EventType, in timeRange: DateInterval) async throws -> [TrackedEvent] {
        return try await storage.fetchEvents(ofType: type, in: timeRange)
    }
    
    // MARK: - Private Methods
    private func setupService() {
        setupConfigurationObserver()
        setupBatchProcessing()
    }
    
    private func setupConfigurationObserver() {
        NotificationCenter.default
            .publisher(for: .analyticsConfigurationUpdated)
            .sink { [weak self] _ in
                self?.handleConfigurationUpdate()
            }
            .store(in: &cancellables)
    }
    
    private func setupBatchProcessing() {
        batchProcessor.onBatchReady = { [weak self] events in
            guard let self = self else { return }
            Task {
                try await self.processBatch(events)
            }
        }
    }
    
    private func trackEvent(_ event: TrackedEvent) async throws {
        do {
            // Validate event
            try validator.validate(event)
            
            // Process based on priority
            if event.priority == .critical {
                try await processImmediately(event)
            } else {
                await eventQueue.enqueue(event)
                batchProcessor.addEvent(event)
            }
            
            // Update state
            lastTrackedEvent = event
            updateMetrics(for: event)
            
        } catch {
            trackingMetrics.incrementErrors()
            throw EventTrackingError.trackingFailed(error)
        }
    }
    
    private func processImmediately(_ event: TrackedEvent) async throws {
        try await storage.store(event)
    }
    
    private func processBatch(_ events: [TrackedEvent]) async throws {
        try await storage.storeBatch(events)
    }
    
    private func generateEventMetadata() -> EventMetadata {
        return EventMetadata(
            timestamp: Date(),
            sessionId: UUID(), // Should be managed by a session service
            deviceInfo: DeviceInfo.current,
            appInfo: AppInfo.current
        )
    }
    
    private func handleConfigurationUpdate() {
        trackingEnabled = configuration.featureFlags.isAnalyticsEnabled
        batchProcessor.updateConfiguration(
            batchSize: configuration.processingRules.batchSize,
            processInterval: configuration.processingRules.processingInterval
        )
    }
    
    private func updateMetrics(for event: TrackedEvent) {
        trackingMetrics.incrementTracked(eventType: event.type)
    }
}

// MARK: - Supporting Types
struct TrackedEvent: Identifiable, Codable {
    let id: UUID
    let type: EventType
    let payload: Any
    let metadata: EventMetadata
    let priority: EventPriority
    let timestamp: Date
    
    init(
        type: EventType,
        payload: Any,
        metadata: EventMetadata,
        priority: EventPriority = .normal
    ) {
        self.id = UUID()
        self.type = type
        self.payload = payload
        self.metadata = metadata
        self.priority = priority
        self.timestamp = Date()
    }
}

enum EventType: String, Codable {
    case user
    case system
    case craving
    case interaction
}

struct EventMetadata: Codable {
    let timestamp: Date
    let sessionId: UUID
    let deviceInfo: DeviceInfo
    let appInfo: AppInfo
}

struct DeviceInfo: Codable {
    let model: String
    let systemVersion: String
    let isSimulator: Bool
    
    static var current: DeviceInfo {
        return DeviceInfo(
            model: "iPhone",
            systemVersion: "17.0",
            isSimulator: false
        )
    }
}

struct AppInfo: Codable {
    let version: String
    let build: String
    
    static var current: AppInfo {
        return AppInfo(
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0",
            build: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        )
    }
}

class BatchEventProcessor {
    var onBatchReady: (([TrackedEvent]) -> Void)?
    private var batchSize: Int
    private var processInterval: TimeInterval
    private var events: [TrackedEvent] = []
    private var timer: Timer?
    
    init(batchSize: Int, processInterval: TimeInterval) {
        self.batchSize = batchSize
        self.processInterval = processInterval
        setupTimer()
    }
    
    func addEvent(_ event: TrackedEvent) {
        events.append(event)
        checkBatchSize()
    }
    
    func updateConfiguration(batchSize: Int, processInterval: TimeInterval) {
        self.batchSize = batchSize
        self.processInterval = processInterval
        setupTimer()
    }
    
    private func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: processInterval,
            repeats: true
        ) { [weak self] _ in
            self?.processBatch()
        }
    }
    
    private func checkBatchSize() {
        if events.count >= batchSize {
            processBatch()
        }
    }
    
    private func processBatch() {
        guard !events.isEmpty else { return }
        onBatchReady?(events)
        events.removeAll()
    }
}

struct TrackingMetrics {
    private(set) var totalTracked: Int = 0
    private(set) var errorCount: Int = 0
    private(set) var eventCounts: [EventType: Int] = [:]
    
    mutating func incrementTracked(eventType: EventType) {
        totalTracked += 1
        eventCounts[eventType, default: 0] += 1
    }
    
    mutating func incrementErrors() {
        errorCount += 1
    }
}

enum EventTrackingError: Error {
    case trackingFailed(Error)
    case validationFailed(String)
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

// MARK: - Testing Support
extension EventTrackingService {
    static func preview() -> EventTrackingService {
        EventTrackingService(
            storage: .preview(),
            configuration: .preview
        )
    }
}
