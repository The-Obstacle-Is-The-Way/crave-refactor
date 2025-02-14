// File: AnalyticsEvent.swift
// Purpose: Defines the core analytics event system and event processing pipeline

import Foundation
import SwiftData

// MARK: - Core Analytics Event Protocol
protocol AnalyticsEvent: Codable, Identifiable {
    var id: UUID { get }
    var timestamp: Date { get }
    var eventType: AnalyticsEventType { get }
    var metadata: [String: AnyHashable] { get }
    var priority: EventPriority { get }
}

// MARK: - Base Analytics Event Implementation
struct BaseAnalyticsEvent: AnalyticsEvent {
    let id: UUID
    let timestamp: Date
    let eventType: AnalyticsEventType
    let metadata: [String: AnyHashable]
    let priority: EventPriority
    
    init(
        id: UUID = UUID(),
        eventType: AnalyticsEventType,
        metadata: [String: AnyHashable] = [:],
        priority: EventPriority = .normal,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.eventType = eventType
        self.metadata = metadata
        self.priority = priority
        self.timestamp = timestamp
    }
}

// MARK: - Event Types
enum AnalyticsEventType: String, Codable {
    // User Interaction Events
    case appLaunch
    case appBackground
    case appForeground
    case screenView
    case buttonTap
    case gestureRecognized
    
    // Craving Events
    case cravingCreated
    case cravingModified
    case cravingDeleted
    case cravingResisted
    case cravingTriggered
    
    // Analytics Events
    case analyticsStarted
    case analyticsCompleted
    case analyticsError
    case insightGenerated
    case predictionMade
    
    // System Events
    case syncStarted
    case syncCompleted
    case syncError
    case storageCleanup
    case configurationChanged
}

// MARK: - Event Priority
enum EventPriority: Int, Codable {
    case low = 0
    case normal = 1
    case high = 2
    case critical = 3
    
    var processingDelay: TimeInterval {
        switch self {
        case .low: return 300 // 5 minutes
        case .normal: return 60 // 1 minute
        case .high: return 10 // 10 seconds
        case .critical: return 0 // Immediate
        }
    }
}

// MARK: - Event Processing Pipeline
final class AnalyticsEventPipeline {
    private let eventQueue: AsyncEventQueue
    private let processors: [EventProcessor]
    private let errorHandler: EventErrorHandler
    
    init(
        processors: [EventProcessor] = [],
        errorHandler: EventErrorHandler = DefaultEventErrorHandler()
    ) {
        self.eventQueue = AsyncEventQueue()
        self.processors = processors
        self.errorHandler = errorHandler
        setupPipeline()
    }
    
    func process(_ event: AnalyticsEvent) async throws {
        await eventQueue.enqueue(event)
    }
    
    private func setupPipeline() {
        Task {
            await processEvents()
        }
    }
    
    private func processEvents() async {
        for await event in eventQueue {
            do {
                try await processEvent(event)
            } catch {
                await errorHandler.handle(error, for: event)
            }
        }
    }
    
    private func processEvent(_ event: AnalyticsEvent) async throws {
        for processor in processors {
            try await processor.process(event)
        }
    }
}

// MARK: - Event Queue
actor AsyncEventQueue: AsyncSequence {
    typealias Element = AnalyticsEvent
    
    private var events: [QueuedEvent] = []
    private var continuation: AsyncStream<Element>.Continuation?
    private let stream: AsyncStream<Element>
    
    init() {
        var continuation: AsyncStream<Element>.Continuation!
        self.stream = AsyncStream { continuation = $0 }
        self.continuation = continuation
    }
    
    func enqueue(_ event: AnalyticsEvent) {
        let queuedEvent = QueuedEvent(event: event, enqueuedAt: Date())
        events.append(queuedEvent)
        processNextEvent()
    }
    
    private func processNextEvent() {
        guard let event = events.first else { return }
        
        let processingDelay = event.event.priority.processingDelay
        let delayElapsed = Date().timeIntervalSince(event.enqueuedAt) >= processingDelay
        
        if delayElapsed {
            events.removeFirst()
            continuation?.yield(event.event)
        }
    }
    
    func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
        stream.makeAsyncIterator()
    }
    
    private struct QueuedEvent {
        let event: AnalyticsEvent
        let enqueuedAt: Date
    }
}

// MARK: - Event Processing Protocols
protocol EventProcessor {
    func process(_ event: AnalyticsEvent) async throws
}

protocol EventErrorHandler {
    func handle(_ error: Error, for event: AnalyticsEvent) async
}

// MARK: - Default Implementations
struct DefaultEventErrorHandler: EventErrorHandler {
    func handle(_ error: Error, for event: AnalyticsEvent) async {
        print("Error processing event \(event.id): \(error.localizedDescription)")
    }
}

// MARK: - Event Processing Error
enum EventProcessingError: Error {
    case processingFailed(Error)
    case invalidEventType
    case invalidMetadata
    case queueFull
    
    var localizedDescription: String {
        switch self {
        case .processingFailed(let error):
            return "Event processing failed: \(error.localizedDescription)"
        case .invalidEventType:
            return "Invalid event type"
        case .invalidMetadata:
            return "Invalid event metadata"
        case .queueFull:
            return "Event queue is full"
        }
    }
}

// MARK: - Testing Support
extension BaseAnalyticsEvent {
    static func mock(
        eventType: AnalyticsEventType = .cravingCreated,
        priority: EventPriority = .normal
    ) -> BaseAnalyticsEvent {
        BaseAnalyticsEvent(
            eventType: eventType,
            metadata: ["test": "data"],
            priority: priority
        )
    }
}

