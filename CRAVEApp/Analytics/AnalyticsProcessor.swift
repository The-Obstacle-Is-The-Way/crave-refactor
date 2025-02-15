//
//  🍒
//  CRAVEApp/Analytics/AnalyticsCoordinator.swift
//  Purpose: Coordinates and orchestrates all analytics operations across the app
//
//

import Foundation
import SwiftData

@MainActor
final class AnalyticsProcessor {
    // MARK: - Properties
    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage
    private var processingQueue: [AnalyticsEvent] = []
    private var isProcessing: Bool = false

    // MARK: - Initialization
    init(configuration: AnalyticsConfiguration, storage: AnalyticsStorage) {
        self.configuration = configuration
        self.storage = storage
    }

    // MARK: - Public Methods
    func processEvent(_ event: AnalyticsEvent) async {
        await queueEvent(event)
        await processQueueIfNeeded()
    }

    func processEventBatch(_ events: [AnalyticsEvent]) async {
        for event in events {
            await queueEvent(event)
        }
        await processQueueIfNeeded()
    }

    // MARK: - Private Methods
    private func queueEvent(_ event: AnalyticsEvent) async {
        processingQueue.append(event)
    }

    private func processQueueIfNeeded() async {
        guard !isProcessing && !processingQueue.isEmpty else { return }
        
        isProcessing = true
        
        do {
            let batchSize = configuration.processingRules.batchSize
            while !processingQueue.isEmpty {
                let batch = Array(processingQueue.prefix(batchSize))
                try await processBatch(batch)
                processingQueue.removeFirst(min(batchSize, processingQueue.count))
            }
        } catch {
            print("Error processing events: \(error)")
        }
        
        isProcessing = false
    }

    private func processBatch(_ batch: [AnalyticsEvent]) async throws {
        for event in batch {
            switch event.eventType {
            case .cravingLogged:
                await processCravingEvent(event)
            case .interaction:
                await processInteractionEvent(event)
            case .system:
                await processSystemEvent(event)
            case .user:
                await processUserEvent(event)
            case .unknown:
                print("Unknown event type received")
            }
        }
    }

    private func processCravingEvent(_ event: AnalyticsEvent) async {
        guard let cravingEvent = event as? CravingEvent else { return }
        print("Processing craving event: \(cravingEvent.cravingText)")
        
        // Add processing logic here
        if let cravingId = cravingEvent.cravingId {
            do {
                let metadata = try await storage.fetchMetadata(forCravingId: cravingId)
                await updateMetadata(metadata, for: cravingEvent)
            } catch {
                print("Error processing craving event: \(error)")
            }
        }
    }

    private func processInteractionEvent(_ event: AnalyticsEvent) async {
        print("Processing interaction event")
        // Add interaction processing logic
    }

    private func processSystemEvent(_ event: AnalyticsEvent) async {
        print("Processing system event")
        // Add system event processing logic
    }

    private func processUserEvent(_ event: AnalyticsEvent) async {
        print("Processing user event")
        // Add user event processing logic
    }

    private func updateMetadata(_ metadata: AnalyticsMetadata?, for event: CravingEvent) async {
        guard let metadata = metadata else { return }
        
        // Update metadata based on the event
        metadata.interactionCount += 1
        metadata.lastProcessed = Date()
        
        // Add any additional metadata updates
        
        do {
            try storage.modelContext.save()
        } catch {
            print("Error saving metadata updates: \(error)")
        }
    }
}

// MARK: - Testing Support
extension AnalyticsProcessor {
    static func preview(storage: AnalyticsStorage) -> AnalyticsProcessor {
        AnalyticsProcessor(
            configuration: .preview,
            storage: storage
        )
    }
}
