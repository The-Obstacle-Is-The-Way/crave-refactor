//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsAggregator.swift
//  Purpose: 
//
//

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
        case .cravingLogged:
            await aggregateCravingEvent(event)
        case .interaction:
            if let interactionEvent = event as? InteractionEvent {
                await aggregateInteractionEvent(interactionEvent)
            }
        case .system:
            if let systemEvent = event as? SystemEvent {
                await aggregateSystemEvent(systemEvent)
            }
        case .user:
            if let userEvent = event as? UserEvent {
                await aggregateUserEvent(userEvent)
            }
        case .unknown:
            print("Unknown event type received")
        }

        if let cravingEvent = event as? CravingEvent {
            await updateCravingAnalytics(cravingEvent)
        }
    }

    private func aggregateCravingEvent(_ event: AnalyticsEvent) async {
        guard let cravingEvent = event as? CravingEvent else { return }
        print("Aggregating craving event: \(cravingEvent.eventType)")
    }

    private func aggregateInteractionEvent(_ event: InteractionEvent) async {
        print("Aggregating interaction event: \(event.eventType)")
    }

    private func aggregateSystemEvent(_ event: SystemEvent) async {
        print("Aggregating system event: \(event.eventType)")
    }

    private func aggregateUserEvent(_ event: UserEvent) async {
        print("Aggregating user event: \(event.eventType)")
    }

    private func updateCravingAnalytics(_ cravingEvent: CravingEvent) async {
        guard let cravingId = cravingEvent.cravingId else { return }

        do {
            let metadata = try await storage.fetchMetadata(forCravingId: cravingId) ?? createNewMetadata(for: cravingId)
            metadata.interactionCount += 1
            metadata.lastProcessed = Date()
            
            let action = AnalyticsMetadata.UserAction(
                timestamp: Date(),
                actionType: "craving_logged",
                metadata: ["text": cravingEvent.cravingText]
            )
            metadata.userActions.append(action)

            try await storage.saveContext()
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

