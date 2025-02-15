//
//  🍒
//  CRAVEApp/Analytics/Services/AnalyticsStorage.swift
//  Purpose: Central service coordinating all analytics operations and providing a clean public API
//
//

import Foundation
import SwiftData

@MainActor
final class AnalyticsStorage {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Event Storage
    func store(_ event: any AnalyticsEvent) async throws {
        // This method now focuses SOLELY on storing the event.
        // The AnalyticsAggregator will handle the logic of *what* to store.
        if let cravingEvent = event as? CravingEvent {
            // This is an example.  You'd likely want a dedicated CravingEventEntity.
             modelContext.insert(CravingModel(cravingText: cravingEvent.cravingText, timestamp: cravingEvent.timestamp))
        } else if let systemEvent = event as? SystemEvent {
            print("Storing System Event: \(systemEvent.eventType)")
        } else if let userEvent = event as? UserEvent {
            print("Storing User Event: \(userEvent.eventType)")
        } else if let interactionEvent = event as? InteractionEvent {
             modelContext.insert(InteractionData(cravingId: interactionEvent.cravingId, timestamp: interactionEvent.timestamp, interactionType: .view))
        } else {
            print("Unknown event type: \(event.eventType)")
        }
        try saveContext()
    }

    // MARK: - Data Fetching
    func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata? {
        let descriptor = FetchDescriptor<AnalyticsMetadata>(
            predicate: #Predicate { $0.cravingId == cravingId }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchAllEvents() async throws -> [CravingModel] { // Example - adjust return type
        let descriptor = FetchDescriptor<CravingModel>(sortBy: [SortDescriptor(\.timestamp)])
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Data Aggregation (Example - Adapt as needed)
    func countEvents(ofType eventType: AnalyticsEventType, in dateInterval: DateInterval) async throws -> Int {
        // You'll need a way to filter events by type.  This is just an example.
        // Assuming you have a way to get the relevant entity for the event type:
        let descriptor = FetchDescriptor<CravingModel>( // Example
            predicate: #Predicate {
                $0.timestamp >= dateInterval.start && $0.timestamp <= dateInterval.end
                // && $0.eventType == eventType // You'd need a way to filter by event type
            }
        )
        return try modelContext.fetchCount(descriptor)
    }

    // MARK: - Utility Functions
    func saveContext() throws {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
            throw StorageError.contextSaveFailed(error)
        }
    }

    func clearAllData() throws {
        try modelContext.deleteAll() // Be *very* careful with this in production!
        try saveContext()
    }
}

// MARK: - Supporting Types
enum StorageError: Error {
    case contextSaveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)

    var localizedDescription: String {
        switch self {
        case .contextSaveFailed(let error):
            return "Failed to save ModelContext: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview and Testing Support

