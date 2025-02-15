//
//  AnalyticsStorage.swift
//  CRAVE
//
//  Created by John H Jung on 2/11/25.
//


import Foundation
import SwiftData

@MainActor
final class AnalyticsStorage {
    let modelContext: ModelContext // Changed to let

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Event Storage
    func store(_ event: any AnalyticsEvent) async throws { // Use protocol type 'any AnalyticsEvent'
        if let cravingEvent = event as? CravingEvent {
             modelContext.insert(CravingModel(cravingText: cravingEvent.cravingText, timestamp: cravingEvent.timestamp)) //Example, adjust as needed
        } else if let systemEvent = event as? SystemEvent {
            print("Storing System Event: \(systemEvent.eventType)") // Example action
            // TODO: Store SystemEvent data if needed
        } else if let userEvent = event as? UserEvent {
            print("Storing User Event: \(userEvent.eventType)") //Example action
            // TODO: Store UserEvent data if needed
        } else if let interactionEvent = event as? InteractionEvent {
             modelContext.insert(InteractionData(cravingId: interactionEvent.cravingId, timestamp: interactionEvent.timestamp, interactionType: .view)) //Example, adjust as needed
        } else {
            print("Unknown event type: \(event.eventType)") // Fallback for unknown types
        }
        try saveContext()
    }


    // MARK: - Data Fetching (Examples - Adapt as needed)
    func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata? {
        let descriptor = FetchDescriptor<AnalyticsMetadata>(
            predicate: #Predicate { $0.cravingId == cravingId }
        )
        return try modelContext.fetch(descriptor).first // Returns first or nil
    }

    func fetchAllEvents() async throws -> [CravingModel] { // Example - adjust return type as needed
        let descriptor = FetchDescriptor<CravingModel>(sortBy: [SortDescriptor(\.timestamp)])
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Data Aggregation (Example - Adapt as needed)
    func countEvents(ofType eventType: AnalyticsEventType, in dateInterval: DateInterval) async throws -> Int {
        let descriptor = FetchDescriptor<CravingModel>( //Example - adjust entity type if needed
            predicate: #Predicate {
                $0.timestamp >= dateInterval.start && $0.timestamp <= dateInterval.end
                //&& $0.eventType == eventType  // Assuming CravingModel doesn't have eventType directly
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
        try modelContext.deleteAll() // Use with caution in production!
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
extension AnalyticsStorage {
    static func preview() -> AnalyticsStorage {
        let container = try! ModelContainer(for: CravingModel.self, AnalyticsMetadata.self, InteractionData.self, ContextualData.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return AnalyticsStorage(modelContext: container.mainContext)
    }
}
