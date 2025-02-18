// Core/Data/DataSources/Local/AnalyticsStorage.swift
import Foundation
import SwiftData

// Changed to internal.  This class is an implementation detail.
internal final class AnalyticsStorage {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // You'll need to update these methods to work with AnalyticsDTO,
    // NOT AnalyticsEvent directly.

    func store(_ event: AnalyticsDTO) async throws {
        modelContext.insert(event)
       try modelContext.save()
    }
    
    func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [AnalyticsDTO] {
        let predicate = #Predicate<AnalyticsDTO> {
            $0.timestamp >= startDate && $0.timestamp <= endDate
        }
        let descriptor = FetchDescriptor<AnalyticsDTO>(predicate: predicate, sortBy: [SortDescriptor(\.timestamp)])
           return try modelContext.fetch(descriptor)
       }
    
    func fetchEvents(ofType eventType: String) async throws -> [AnalyticsDTO] { // Changed to String
        let predicate = #Predicate<AnalyticsDTO> {
            $0.eventType == eventType
        }
        let descriptor = FetchDescriptor<AnalyticsDTO>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata? {
           let predicate = #Predicate<AnalyticsMetadata> {
              $0.id == cravingId // Assuming your AnalyticsMetadata has an id that links to the craving
           }
           let descriptor = FetchDescriptor<AnalyticsMetadata>(predicate: predicate)
           return try modelContext.fetch(descriptor).first
       }

       func update(metadata: AnalyticsMetadata) async throws {
           //Since metadata is not a new object, it is already in the context.
           //SwiftData tracks it and saves automatically, so we only need to save.
           try modelContext.save()
       }

    func storeBatch(_ events: [AnalyticsDTO]) async throws { // Changed to AnalyticsDTO
        events.forEach { modelContext.insert($0) }
        try modelContext.save()
    }

    func cleanupData(before date: Date) async throws {
        let predicate = #Predicate<AnalyticsDTO> {
            $0.timestamp < date
        }
        try modelContext.delete(model: AnalyticsDTO.self, where: predicate)
        try modelContext.save() // Added to persist immediately
    }
}

