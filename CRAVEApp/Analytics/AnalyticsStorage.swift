//
//
//AnalyticsStorage.swift
//
//

import Foundation
import SwiftData
import Combine

final class AnalyticsStorage {

    private let modelContext: ModelContext
    var eventPublisher = PassthroughSubject<any AnalyticsEvent, Error>() // Added for event handling


    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func store(_ craving: CravingModel) async throws {
        modelContext.insert(craving)
        try modelContext.save() // Save after inserting
    }
    
    func store(_ metadata: AnalyticsMetadata) async throws {
        modelContext.insert(metadata)
        try modelContext.save() // Save after inserting
    }
    
    func store(_ event: any AnalyticsEvent) async throws { // Added to store events
        if let cravingEvent = event as? CravingEvent{
            let cravingModel = CravingModel(cravingText: "")
            cravingModel.timestamp = cravingEvent.timestamp
            cravingModel.id = cravingEvent.cravingId
            
            try await store(cravingModel)
        }
    }

    func storeBatch(_ events: [any AnalyticsEvent]) async throws { // Added to store events
        for event in events {
               try await store(event) // Reuse the single event store method
        }
    }


    func fetchRange(_ dateRange: DateInterval) async throws -> [CravingModel] {
        let startDate = dateRange.start
        let endDate = dateRange.end
        let predicate = #Predicate<CravingModel> {
            $0.timestamp >= startDate && $0.timestamp <= endDate && !$0.isArchived
        }
        let descriptor = FetchDescriptor<CravingModel>(predicate: predicate, sortBy: [SortDescriptor(\.timestamp)])
        return try modelContext.fetch(descriptor)
    }

    func fetchAll() async throws -> [CravingModel] { // Added for completeness
        let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived },
                                                     sortBy: [SortDescriptor(\.timestamp)])
        return try modelContext.fetch(descriptor)
    }

    func clear() async throws {
        try modelContext.delete(model: CravingModel.self)
        try modelContext.delete(model: AnalyticsMetadata.self)
        try modelContext.save()
    }
    
    func fetchEvents(ofType type: EventType, in timeRange: DateInterval) async throws -> [TrackedEvent] {
            // Placeholder - Assuming no other event types for now
            return []
    }
}

// MARK: - Preview Support (for testing/previews)
extension AnalyticsStorage {
    static func preview() -> AnalyticsStorage {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: CravingModel.self, AnalyticsMetadata.self, configurations: config) // Added AnalyticsMetadata
        return AnalyticsStorage(modelContext: container.mainContext)
    }
}
