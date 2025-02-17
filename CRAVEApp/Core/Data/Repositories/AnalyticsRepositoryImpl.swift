import Foundation
import SwiftData

public final class AnalyticsRepositoryImpl: AnalyticsRepository {
    private let storage: AnalyticsStorage
    private let mapper: AnalyticsMapper

    public init(storage: AnalyticsStorage, mapper: AnalyticsMapper) {
        self.storage = storage
        self.mapper = mapper
    }

    public func storeEvent(_ event: AnalyticsEvent) async throws {
        try await storage.store(event)
    }

    public func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [AnalyticsEvent] {
        return try await storage.fetchEvents(from: startDate, to: endDate)
    }

    public func fetchEvents(ofType eventType: EventType) async throws -> [AnalyticsEvent] {
        return try await storage.fetchEvents(ofType: eventType)
    }

    public func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata? {
        return try storage.fetchMetadata(forCravingId: cravingId)
    }

    public func updateMetadata(_ metadata: AnalyticsMetadata) async throws {
        try storage.update(metadata: metadata)
    }

    public func fetchAnalytics(from startDate: Date, to endDate: Date) async throws -> BasicAnalyticsResult {
        // Insert your aggregation logic here – returning an empty result for now.
        return BasicAnalyticsResult.empty
    }

    public func fetchPatterns() async throws -> [BasicAnalyticsResult.DetectedPattern] {
        return []
    }

    public func storeBatch(_ events: [AnalyticsEvent]) async throws {
        try await storage.storeBatch(events)
    }

    public func cleanupOldData(before date: Date) async throws {
        try await storage.cleanupData(before: date)
    }
}

