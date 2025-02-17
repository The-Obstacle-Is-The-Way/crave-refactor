// Core/Domain/Interactors/Analytics/AnalyticsAggregator.swift

import Foundation
import SwiftData

@MainActor
final class AnalyticsAggregator {
    private let storage: AnalyticsStorage

    init(storage: AnalyticsStorage) {
        self.storage = storage
    }

    func aggregateEvent(_ event: AnalyticsEvent) async {
        switch event.eventType {
        case.cravingLogged:
            await aggregateCravingEvent(event)
        case.interaction:
            if let interactionEvent = event as? InteractionEvent {
                await aggregateInteractionEvent(interactionEvent)
            }
        case.system:
            if let systemEvent = event as? SystemEvent {
                await aggregateSystemEvent(systemEvent)
            }
        case.user:
            if let userEvent = event as? UserEvent {
                await aggregateUserEvent(userEvent)
            }
        case.unknown:
            print("Unknown event type received")
        }

        if let cravingEvent = event as? CravingEvent {
            await updateCravingAnalytics(cravingEvent)
        }
    }

    private func aggregateCravingEvent(_ event: AnalyticsEvent) async {
        guard let cravingEvent = event as? CravingEvent else {
            print("Incorrect event type passed to aggregateCravingEvent")
            return
        }
        print("Aggregating craving event: \(cravingEvent.eventType)")
    }

    private func aggregateInteractionEvent(_ event: InteractionEvent) async {
        // Implementation for aggregating interaction events
        print("Aggregating interaction event: \(event.eventType)")
    }

    private func aggregateSystemEvent(_ event: SystemEvent) async {
        // Implementation for aggregating system events
        print("Aggregating system event: \(event.eventType)")
    }

    private func aggregateUserEvent(_ event: UserEvent) async {
        // Implementation for aggregating user events
        print("Aggregating user event: \(event.eventType)")
    }

    private func updateCravingAnalytics(_ cravingEvent: CravingEvent) async {
        let cravingId = cravingEvent.cravingId

        do {
            // Fetch or create metadata for the craving
            var metadata = try storage.fetchMetadata(forCravingId: cravingId)?? createNewMetadata(for: cravingId)

            // Update metadata
            metadata.interactionCount += 1
            metadata.lastProcessed = Date()
            
            // Add user action
            let action = AnalyticsMetadata.UserAction(
                timestamp: Date(),
                actionType: "craving_logged",
                metadata: ["text": cravingEvent.cravingText]
            )
            metadata.userActions.append(action)

            // Save changes
            try storage.modelContext.save()

        } catch {
            print("Error updating AnalyticsMetadata: \(error)")
        }
    }

    private func createNewMetadata(for cravingId: UUID) -> AnalyticsMetadata {
        let metadata = AnalyticsMetadata(cravingId: cravingId)
        storage.modelContext.insert(metadata)
        return metadata
    }
}

// MARK: - Analytics Event Processing Extensions
extension AnalyticsAggregator {
    func processEventBatch(_ events: [AnalyticsEvent]) async {
        for event in events {
            await aggregateEvent(event)
        }
    }
    
    func processHistoricalData(_ startDate: Date, _ endDate: Date) async {
        // Implementation for processing historical data
        print("Processing historical data from \(startDate) to \(endDate)")
    }
}

// MARK: - Testing Support
extension AnalyticsAggregator {
    static func preview(storage: AnalyticsStorage) -> AnalyticsAggregator {
        AnalyticsAggregator(storage: storage)
    }
}
