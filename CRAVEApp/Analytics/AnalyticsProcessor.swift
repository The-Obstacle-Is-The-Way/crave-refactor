//
// File: AnalyticsProcessor.swift
// Purpose: Core processing engine for analytics data with real-time and batch processing capabilities
//

import Foundation
import SwiftData
import Combine
import CRAVEApp.Analytics // ✅ Added import for AnalyticsEvent
import CRAVEApp.AnalyticsModel // ✅ Added import for AnalyticsStorage


// MARK: - Analytics Processor
@MainActor
final class AnalyticsProcessor {
    // MARK: - Properties
    private let configuration: AnalyticsConfiguration
    private let processingQueue: OperationQueue
    private let storage: AnalyticsStorage // ✅ No longer ambiguous with proper imports
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Processing State
    @Published private(set) var processingState: ProcessingState = .idle
    @Published private(set) var lastProcessingTime: Date?
    @Published private(set) var processingMetrics: ProcessingMetrics

    // MARK: - Batch Processing
    private var batchQueue: [AnalyticsEvent] = [] // ✅ No longer ambiguous with proper imports
    private var processingTimer: Timer?

    // MARK: - Initialization
    init(
        configuration: AnalyticsConfiguration = .shared,
        storage: AnalyticsStorage
    ) {
        self.configuration = configuration
        self.storage = storage
        self.processingQueue = OperationQueue()
        self.processingMetrics = ProcessingMetrics()

        setupProcessor()
    }

    // MARK: - Public Interface
    func process(_ event: AnalyticsEvent) async throws { // ✅ No longer ambiguous with proper imports
        guard validateEvent(event) else {
            throw ProcessingError.invalidEvent
        }

        if shouldProcessImmediately(event) {
            try await processImmediately(event)
        } else {
            addToBatch(event)
        }
    }

    func processBatch(_ events: [AnalyticsEvent]) async throws { // ✅ No longer ambiguous with proper imports
        guard !events.isEmpty else { return }

        processingState = .processing

        do {
            let startTime = Date()

            // Pre-process events
            let preprocessedEvents = try preprocess(events)

            // Process in batches
            try await processBatchedEvents(preprocessedEvents)

            // Update metrics
            updateMetrics(processedCount: events.count, startTime: startTime)

            processingState = .idle
            lastProcessingTime = Date()

        } catch {
            processingState = .error
            throw ProcessingError.batchProcessingFailed(error)
        }
    }

    func flushQueue() async throws {
        guard !batchQueue.isEmpty else { return }

        let events = batchQueue
        batchQueue.removeAll()

        try await processBatch(events)
    }

    // MARK: - Private Processing Methods
    private func processImmediately(_ event: AnalyticsEvent) async throws { // ✅ No longer ambiguous with proper imports
        processingState = .processing

        do {
            let startTime = Date()

            // Preprocess
            let preprocessed = try preprocess([event]).first!

            // Process
            try await processEvent(preprocessed)

            // Store
            try await storage.store(preprocessed)

            // Update metrics
            updateMetrics(processedCount: 1, startTime: startTime)

            processingState = .idle
            lastProcessingTime = Date()

        } catch {
            processingState = .error
            throw ProcessingError.processingFailed(error)
        }
    }

    private func processBatchedEvents(_ events: [AnalyticsEvent]) async throws { // ✅ No longer ambiguous with proper imports
        let batchSize = configuration.processingRules.batchSize

        for batch in events.chunked(into: batchSize) {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for event in batch {
                    group.addTask {
                        try await self.processEvent(event)
                    }
                }
                try await group.waitForAll()
            }

            // Store processed batch
            try await storage.storeBatch(batch)
        }
    }

    private func processEvent(_ event: AnalyticsEvent) async throws { // ✅ No longer ambiguous with proper imports
        // Apply processing rules
        let processedEvent = try applyProcessingRules(to: event)

        // Enrich event
        let enrichedEvent = try await enrichEvent(processedEvent)

        // Validate processed event
        guard validateProcessedEvent(enrichedEvent) else {
            throw ProcessingError.processingValidationFailed
        }

        // Return processed event
        return enrichedEvent
    }

    // MARK: - Helper Methods
    private func setupProcessor() {
        setupProcessingTimer()
        setupConfigurationObservers()
    }

    private func setupProcessingTimer() {
        processingTimer = Timer.scheduledTimer(
            withTimeInterval: configuration.processingRules.processingInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            Task {
                try? await self.flushQueue()
            }
        }
    }

    private func setupConfigurationObservers() {
        NotificationCenter.default
            .publisher(for: .analyticsConfigurationUpdated)
            .sink { [weak self] _ in
                self?.updateConfiguration()
            }
            .store(in: &cancellables)
    }

    private func updateConfiguration() {
        processingQueue.maxConcurrentOperationCount = configuration.performanceConfig.maxConcurrentOperations
    }

    private func shouldProcessImmediately(_ event: AnalyticsEvent) -> Bool { // ✅ No longer ambiguous with proper imports
        return event.priority == .critical ||
               configuration.featureFlags.isRealtimeProcessingEnabled
    }

    private func addToBatch(_ event: AnalyticsEvent) { // ✅ No longer ambiguous with proper imports
        batchQueue.append(event)

        if batchQueue.count >= configuration.processingRules.batchSize {
            Task {
                try? await flushQueue()
            }
        }
    }

    private func validateEvent(_ event: AnalyticsEvent) -> Bool { // ✅ No longer ambiguous with proper imports
        // Implement event validation
        return true
    }

    private func validateProcessedEvent(_ event: AnalyticsEvent) -> Bool { // ✅ No longer ambiguous with proper imports
        // Implement processed event validation
        return true
    }

    private func preprocess(_ events: [AnalyticsEvent]) throws -> [AnalyticsEvent] { // ✅ No longer ambiguous with proper imports
        // Implement preprocessing logic
        return events
    }

    private func applyProcessingRules(to event: AnalyticsEvent) throws -> AnalyticsEvent { // ✅ No longer ambiguous with proper imports
        // Implement processing rules
        return event
    }

    private func enrichEvent(_ event: AnalyticsEvent) async throws -> AnalyticsEvent { // ✅ No longer ambiguous with proper imports
        // Implement event enrichment
        return event
    }

    private func updateMetrics(processedCount: Int, startTime: Date) {
        let processingTime = Date().timeIntervalSince(startTime)
        processingMetrics.update(
            processedCount: processedCount,
            processingTime: processingTime
        )
    }
}

// MARK: - Supporting Types
enum ProcessingState {
    case idle
    case processing
    case error
}

struct ProcessingMetrics {
    var totalProcessed: Int = 0
    var averageProcessingTime: TimeInterval = 0
    var errorCount: Int = 0
    var lastBatchSize: Int = 0

    mutating func update(processedCount: Int, processingTime: TimeInterval) {
        totalProcessed += processedCount
        lastBatchSize = processedCount

        // Update average processing time
        let oldTotal = averageProcessingTime * Double(totalProcessed - processedCount)
        let newTotal = oldTotal + (processingTime * Double(processedCount))
        averageProcessingTime = newTotal / Double(totalProcessed)
    }
}

enum ProcessingError: Error {
    case invalidEvent
    case processingFailed(Error)
    case batchProcessingFailed(Error)
    case processingValidationFailed
    case configurationError

    var localizedDescription: String {
        switch self {
        case .invalidEvent:
            return "Invalid analytics event"
        case .processingFailed(let error):
            return "Processing failed: \(error.localizedDescription)"
        case .batchProcessingFailed:
            return "Batch processing failed: \(error.localizedDescription)"
        case .processingValidationFailed:
            return "Processed event validation failed"
        case .configurationError:
            return "Invalid processor configuration"
        }
    }
}

// MARK: - Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Testing Support
extension AnalyticsProcessor {
    static func preview() -> AnalyticsProcessor {
        AnalyticsProcessor(
            configuration: .preview,
            storage: .preview()
        )
    }
}


