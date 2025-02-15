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
            await aggregateInteractionEvent(event as! InteractionEvent)
        case .system:
            await aggregateSystemEvent(event as! SystemEvent)
        case .user:
            await aggregateUserEvent(event as! UserEvent)
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
        print("Aggregating interaction event: \(event.eventType)")
    }

    private func aggregateSystemEvent(_ event: SystemEvent) async {
        print("Aggregating system event: \(event.eventType)")
    }

    private func aggregateUserEvent(_ event: UserEvent) async {
        print("Aggregating user event: \(event.eventType)")
    }

    private func updateCravingAnalytics(_ cravingEvent: CravingEvent) async {
        // Only proceed if we have a valid cravingId
        guard let cravingId = cravingEvent.cravingId else {
            print("No craving ID available for analytics update")
            return
        }

        do {
            // Fetch existing metadata or create new if none exists
            let metadata = try await storage.fetchMetadata(forCravingId: cravingId) ?? createNewMetadata(for: cravingId)

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

// MARK: - Testing Support
extension AnalyticsAggregator {
    static func preview(storage: AnalyticsStorage) -> AnalyticsAggregator {
        AnalyticsAggregator(storage: storage)
    }
}
