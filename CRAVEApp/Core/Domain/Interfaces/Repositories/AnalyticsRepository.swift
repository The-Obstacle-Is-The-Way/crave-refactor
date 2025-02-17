// Core/Domain/Interfaces/Repositories/AnalyticsRepository.swift

import Foundation

/// Protocol defining the analytics data access contract
protocol AnalyticsRepository {
    // MARK: - Event Operations
    /// Store a new analytics event
    func storeEvent(_ event: AnalyticsEvent) async throws
    
    /// Fetch events for a given time period
    func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [AnalyticsEvent]
    
    /// Fetch events of a specific type
    func fetchEvents(ofType eventType: EventType) async throws -> [AnalyticsEvent]
    
    // MARK: - Metadata Operations
    /// Fetch metadata for a specific craving
    func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata?
    
    /// Update metadata for a specific craving
    func updateMetadata(_ metadata: AnalyticsMetadata) async throws
    
    // MARK: - Analytics Results
    /// Fetch aggregated analytics results for a time period
    func fetchAnalytics(from startDate: Date, to endDate: Date) async throws -> BasicAnalyticsResult
    
    /// Fetch detected patterns
    func fetchPatterns() async throws -> [BasicAnalyticsResult.DetectedPattern]
    
    // MARK: - Batch Operations
    /// Store multiple events in a batch
    func storeBatch(_ events: [AnalyticsEvent]) async throws
    
    /// Clean up old analytics data
    func cleanupOldData(before date: Date) async throws
}

// MARK: - Repository Errors
enum AnalyticsRepositoryError: Error {
    case storageError(String)
    case fetchError(String)
    case invalidData(String)
    case noDataAvailable
    case batchProcessingFailed
}

// MARK: - Query Options
extension AnalyticsRepository {
    struct QueryOptions {
        let limit: Int?
        let sortOrder: SortOrder
        let includeMetadata: Bool
        
        static let `default` = QueryOptions(
            limit: nil,
            sortOrder: .descending,
            includeMetadata: true
        )
    }
    
    enum SortOrder {
        case ascending
        case descending
    }
}

// MARK: - Convenience Methods
extension AnalyticsRepository {
    /// Fetch analytics for today
    func fetchTodayAnalytics() async throws -> BasicAnalyticsResult {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        return try await fetchAnalytics(from: startOfDay, to: now)
    }
    
    /// Fetch analytics for the last n days
    func fetchAnalytics(forLastDays days: Int) async throws -> BasicAnalyticsResult {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: now) ?? now
        return try await fetchAnalytics(from: startDate, to: now)
    }
    
    /// Check if a pattern exists
    func patternExists(ofType type: BasicAnalyticsResult.PatternType) async throws -> Bool {
        let patterns = try await fetchPatterns()
        return patterns.contains { $0.type == type }
    }
}

// MARK: - Validation
extension AnalyticsRepository {
    func validateTimeRange(from startDate: Date, to endDate: Date) -> Bool {
        guard startDate <= endDate else { return false }
        guard startDate <= Date() else { return false }
        return true
    }
    
    func validateEvent(_ event: AnalyticsEvent) -> Bool {
        guard event.validate() else { return false }
        guard event.timestamp <= Date() else { return false }
        return true
    }
}
