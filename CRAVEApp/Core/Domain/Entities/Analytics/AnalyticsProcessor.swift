// Core/Domain/Interactors/Analytics/AnalyticsProcessor.swift

import Foundation
import SwiftData

@MainActor
final class AnalyticsProcessor {
    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage
    private var processingQueue: [AnalyticsEvent] = []  // Initialize to empty array
    private var isProcessing: Bool = false

    init(configuration: AnalyticsConfiguration, storage: AnalyticsStorage) {
        self.configuration = configuration
        self.storage = storage
    }

    func processEvent(_ event: AnalyticsEvent) async {
        await queueEvent(event)
        await processQueueIfNeeded()
    }

    private func queueEvent(_ event: AnalyticsEvent) async {
        processingQueue.append(event)
    }

    private func processQueueIfNeeded() async {
        // Note the spaces between '!' and the identifiers.
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
                print("Unknown event type encountered")
            }
        }
    }

    private func processCravingEvent(_ event: AnalyticsEvent) async {
        guard let cravingEvent = event as? CravingEvent else {
            print("Incorrect event type passed to processCravingEvent")
            return
        }
        print("Processing craving event: \(cravingEvent.cravingText)")
        // … additional logic here …
    }

    private func processInteractionEvent(_ event: AnalyticsEvent) async {
        print("Processing interaction event")
    }

    private func processSystemEvent(_ event: AnalyticsEvent) async {
        print("Processing system event")
    }

    private func processUserEvent(_ event: AnalyticsEvent) async {
        print("Processing user event")
    }
}

