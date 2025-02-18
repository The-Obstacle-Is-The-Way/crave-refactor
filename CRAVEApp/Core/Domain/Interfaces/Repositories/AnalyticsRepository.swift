// Core/Domain/Interfaces/Repositories/AnalyticsRepository.swift

import Foundation

public protocol AnalyticsRepository {
    // MARK: - Event Operations
    func storeEvent(_ event: AnalyticsEvent) async throws
    func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [AnalyticsEvent]
    func fetchEvents(ofType eventType: EventType) async throws -> [AnalyticsEvent]
    
    // MARK: - Metadata Operations
    func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata?
    func updateMetadata(_ metadata: AnalyticsMetadata) async throws
    
    // MARK: - Analytics Results
    func fetchAnalytics(from startDate: Date, to endDate: Date) async throws -> BasicAnalyticsResult
    func fetchPatterns() async throws -> [BasicAnalyticsResult.DetectedPattern]
    
    // MARK: - Batch Operations
    func storeBatch(_ events: [AnalyticsEvent]) async throws
    func cleanupOldData(before date: Date) async throws
}

public enum AnalyticsRepositoryError: Error {
    case storageError(String)
    case fetchError(String)
    case invalidData(String)
    case noDataAvailable
    case batchProcessingFailed
}

public extension AnalyticsRepository {
    struct QueryOptions {
        public let limit: Int?
        public let sortOrder: SortOrder
        public let includeMetadata: Bool
        
        public static let `default` = QueryOptions(limit: nil, sortOrder: .descending, includeMetadata: true)
        
        public init(limit: Int? = nil, sortOrder: SortOrder = .descending, includeMetadata: Bool = true) {
            self.limit = limit
            self.sortOrder = sortOrder
            self.includeMetadata = includeMetadata
        }
    }
    
    enum SortOrder {
        case ascending
        case descending
    }
    
    func fetchTodayAnalytics() async throws -> BasicAnalyticsResult {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        return try await fetchAnalytics(from: startOfDay, to: now)
    }
}

