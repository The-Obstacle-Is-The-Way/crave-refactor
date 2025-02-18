// File: AnalyticsStorage.swift
// Description:
// This internal class implements the analytics storage functionality using SwiftData.
// It conforms to AnalyticsStorageProtocol (defined in a separate file) so that public APIs depend only on the protocol.
// The internal details of AnalyticsStorage remain hidden.
import Foundation
import SwiftData

internal final class AnalyticsStorage: AnalyticsStorageProtocol {
    // The ModelContext used to perform data operations.
    private let modelContext: ModelContext

    // Internal initializer – we do not expose AnalyticsStorage publicly.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - AnalyticsStorageProtocol Implementation

    func store(_ event: AnalyticsDTO) async throws {
        // Inserts the event into the model context.
        modelContext.insert(event)
        try modelContext.save()
    }
    
    func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [AnalyticsDTO] {
        // Define a predicate for the date range.
        let predicate = #Predicate<AnalyticsDTO> {
            $0.timestamp >= startDate && $0.timestamp <= endDate
        }
        // Explicitly specify the key path's root type.
        let descriptor = FetchDescriptor<AnalyticsDTO>(predicate: predicate, sortBy: [SortDescriptor(\AnalyticsDTO.timestamp)])
        return try modelContext.fetch(descriptor)
    }
    
    func fetchEvents(ofType eventType: String) async throws -> [AnalyticsDTO] {
        // Define a predicate for the event type.
        let predicate = #Predicate<AnalyticsDTO> {
            $0.eventType == eventType
        }
        let descriptor = FetchDescriptor<AnalyticsDTO>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata? {
        // Define a predicate to find the metadata by id.
        let predicate = #Predicate<AnalyticsMetadata> {
            $0.id == cravingId
        }
        let descriptor = FetchDescriptor<AnalyticsMetadata>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    func update(metadata: AnalyticsMetadata) async throws {
        // For tracked metadata, saving the context is sufficient.
        try modelContext.save()
    }
    
    func storeBatch(_ events: [AnalyticsDTO]) async throws {
        // Insert each event in the array.
        events.forEach { modelContext.insert($0) }
        try modelContext.save()
    }
    
    func cleanupData(before date: Date) async throws {
        // Define a predicate to find events older than the specified date.
        let predicate = #Predicate<AnalyticsDTO> {
            $0.timestamp < date
        }
        // Delete matching models. Note that the method requires AnalyticsDTO to conform to PersistentModel.
        try modelContext.delete(model: AnalyticsDTO.self, where: predicate)
        try modelContext.save()
    }
}
