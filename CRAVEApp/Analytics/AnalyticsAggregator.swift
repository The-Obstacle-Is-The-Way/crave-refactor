//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsAggregator.swift
//  Purpose: 
//


import Foundation
import SwiftData

// ADDED: Ensure AnalyticsEventType is defined and accessible.
// If AnalyticsEventType.swift exists, ensure it's correctly imported.
// If not, define it directly here (for now, to isolate the issue).
enum AnalyticsEventType: String, Codable, CaseIterable {
    case cravingLogged
    case interaction
    case system
    case user
    // Add other event types as needed, ensuring they have String raw values
}


@MainActor
final class AnalyticsAggregator {
    private let storage: AnalyticsStorage

    init(storage: AnalyticsStorage) {
        self.storage = storage
    }

    func aggregateEvent(_ event: AnalyticsEvent) async { // Explicitly use AnalyticsEvent protocol
        switch event.eventType {
        case .cravingLogged: // ERROR RESOLVED: Using .cravingLogged (now that enum is defined/accessible)
            await aggregateCravingEvent(event)
        case .interaction:  // ERROR RESOLVED: Using .interaction
            await aggregateInteractionEvent(event as! InteractionEvent) // Force cast - review type safety if issues arise
        case .system:       // ERROR RESOLVED: Using .system
            await aggregateSystemEvent(event as! SystemEvent) // Force cast - review type safety if issues arise
        case .user:         // ERROR RESOLVED: Using .user
            await aggregateUserEvent(event as! UserEvent) // Force cast - review type safety if issues arise
        }
        // Persist aggregated data (example - adjust based on what you need to store)
        if let cravingEvent = event as? CravingEvent {
            await updateCravingAnalytics(cravingEvent)
        }
    }

    private func aggregateCravingEvent(_ event: AnalyticsEvent) async { // Explicitly use AnalyticsEvent protocol
        guard let cravingEvent = event as? CravingEvent else {
            print("Incorrect event type passed to aggregateCravingEvent")
            return
        }
        // Aggregate craving-specific data (example)
        print("Aggregating craving event: \(cravingEvent.eventType)")
        // TODO: Implement actual aggregation logic for craving events
    }

    private func aggregateInteractionEvent(_ event: InteractionEvent) async {
        // Aggregate interaction event data
        print("Aggregating interaction event: \(event.eventType)")
        // TODO: Implement actual aggregation logic for interaction events
    }

    private func aggregateSystemEvent(_ event: SystemEvent) async {
        // Aggregate system event data
        print("Aggregating system event: \(event.eventType)")
        // TODO: Implement actual aggregation logic for system events
    }

    private func aggregateUserEvent(_ event: UserEvent) async {
        // Aggregate user event data
        print("Aggregating user event: \(event.eventType)")
        // TODO: Implement actual aggregation logic for user events
    }

    private func updateCravingAnalytics(_ cravingEvent: CravingEvent) async {
        // Example: Update AnalyticsMetadata for a CravingModel
        guard let cravingId = cravingEvent.cravingId else { return }

        do {
            // ERROR RESOLVED (Potentially): Changed to optional binding to handle potential nil UUID.
            guard let metadata = try await storage.fetchMetadata(forCravingId: cravingId) else {
                print("No metadata found for craving ID: \(cravingId)")
                return // Or handle the case where metadata is not found
            }

            // Update existing metadata (example - increment interaction count)
            metadata.interactionCount += 1
            metadata.lastProcessed = Date()
            try await storage.saveContext() // Assuming you have a saveContext in storage

        } catch {
            print("Error updating AnalyticsMetadata: \(error)")
            // Handle metadata update error
        }
    }

    // Add more specific aggregation functions as needed for different aspects of analytics
}




