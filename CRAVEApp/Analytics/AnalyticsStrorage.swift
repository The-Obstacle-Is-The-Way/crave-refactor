//
// AnalyticsStorage.swift
//

import Foundation
import SwiftData
import Combine

// MARK: - Analytics Storage
final class AnalyticsStorage {
    // MARK: - Properties
    private let modelContext: ModelContext
    private let config: StorageConfiguration
    private var cancellables = Set<AnyCancellable>()
    private var cache: AnalyticsCache  // Use the defined type

    @Published private(set) var storageMetrics: StorageMetrics = StorageMetrics()

    // Constants (can be part of StorageConfiguration if you prefer)
    private let expirationInterval: TimeInterval = 30 * 24 * 60 * 60 // 30 days

    // Combine Publisher for cache metrics
    let metricsPublisher = PassthroughSubject<CacheMetrics, Never>()

    init(modelContext: ModelContext, config: StorageConfiguration = .default) {
        self.modelContext = modelContext
        self.config = config
        self.cache = AnalyticsCache() // Initialize
        setupStorage()
    }

    // MARK: - Public Interface

    func store(_ event: any AnalyticsEvent) async throws {
        guard let analyticsEvent = event as? CravingAnalytics else { return } // Ensure its of type CravingAnalytics
        do {
            // No need for AnalyticsRecord, persist CravingAnalytics directly
            modelContext.insert(analyticsEvent)
            try modelContext.save() // Save immediately
            updateMetrics(for: .store)
            cache.cachedData = nil // Invalidate cache
            cache.lastUpdated = nil
            metricsPublisher.send(cache.metrics) // Publish updated metrics
        } catch {
            throw StorageError.storeFailed(error)
        }
    }

    func fetchRange(_ dateRange: DateInterval) async throws -> [CravingAnalytics] {
        // Check if we have cached data and it's not too old
        if let cachedData = cache.cachedData,
           let lastUpdated = cache.lastUpdated,
           Date().timeIntervalSince(lastUpdated) < config.cacheTTL { // Use cacheTTL from config
            updateMetrics(for: .cacheHit)
            return cachedData
        }

        // Fetch from SwiftData
        let startDate = dateRange.start
        let endDate = dateRange.end
        let predicate = #Predicate<CravingAnalytics> {
            $0.timestamp >= startDate && $0.timestamp < endDate
        }
        let fetchDescriptor = FetchDescriptor<CravingAnalytics>(predicate: predicate, sortBy: [SortDescriptor(\.timestamp)])

        do {
            let records = try modelContext.fetch(fetchDescriptor)
            updateMetrics(for: .cacheMiss)

            // Update the cache
            cache.cachedData = records
            cache.lastUpdated = Date()
            metricsPublisher.send(cache.metrics)

            return records
        } catch {
            throw StorageError.fetchFailed(error)
        }
    }

    //Added for use in AnalyticsService
    func fetchAll() async throws -> [CravingAnalytics] {
        let fetchDescriptor = FetchDescriptor<CravingAnalytics>()
        return try await modelContext.fetch(fetchDescriptor)
    }
    //Added for use in AnalyticsService
    func clear() async throws {
        try modelContext.delete(model: CravingAnalytics.self)
    }

    // MARK: - Private Methods

    private func setupStorage() {
        setupPeriodicCleanup()
        //setupCacheMonitoring() // Removed, as we're simplifying the cache
    }

    private func persistAnalytics(_ analytics: CravingAnalytics) async throws {
        // Removed, as we're persisting CravingAnalytics directly
    }

    private func setupPeriodicCleanup() {
        Timer.publish(every: config.cleanupInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { // Keep this Task
                    try? await self.performCleanup() // Keep await
                }
            }
            .store(in: &cancellables)
    }

    @MainActor // Add this!
    private func performCleanup() async throws {
        let cleanupDate = Date().addingTimeInterval(-expirationInterval)
        let predicate = #Predicate<CravingAnalytics> {
            $0.timestamp < cleanupDate
        }
        let descriptor = FetchDescriptor<CravingAnalytics>(predicate: predicate)

        do {
            // Fetch and delete in one go.  This is safer than fetching and *then* deleting.
            let oldRecords = try modelContext.fetch(descriptor) // No 'await' needed here now
            for record in oldRecords { //then delete
                modelContext.delete(record) // No 'await'
            }
            try modelContext.save() // No 'await'.  We're already on the MainActor.
            updateMetrics(for: .cleanup(recordsRemoved: oldRecords.count))
             cache.cachedData = nil // Invalidate cache
             cache.lastUpdated = nil
             metricsPublisher.send(cache.metrics) //update metrics
        } catch {
            throw StorageError.cleanupFailed(error)
        }
    }

    private var shouldPerformCleanup: Bool {
        guard let lastCleanup = storageMetrics.lastCleanupTime else { return true }
        return Date().timeIntervalSince(lastCleanup) >= config.cleanupInterval
    }

    private func updateMetrics(for operation: StorageOperation) {
        storageMetrics.update(for: operation)
    }
}

// MARK: - Supporting Types

extension AnalyticsStorage {
    struct StorageConfiguration {
        let maxCacheSize: Int
        let expirationInterval: TimeInterval
        let cleanupInterval: TimeInterval
        let cacheTTL: TimeInterval // Time-to-live for cache entries

        static let `default` = StorageConfiguration(
            maxCacheSize: 1000,
            expirationInterval: 30 * 24 * 60 * 60, // 30 days
            cleanupInterval: 24 * 60 * 60, // 1 day
            cacheTTL: 60 * 5 // 5 minutes
        )
    }

    enum StorageOperation {
        case store
        case cacheHit
        case cacheMiss
        case cleanup(recordsRemoved: Int)
    }

    enum StorageError: Error {
        case storeFailed(Error)
        case fetchFailed(Error)
        case persistenceFailed(Error)
        case cleanupFailed(Error)
        case recordNotFound

        var localizedDescription: String {
            switch self {
            case .storeFailed(let error):
                return "Failed to store analytics: \(error.localizedDescription)"
            case .fetchFailed(let error):
                return "Failed to fetch analytics: \(error.localizedDescription)"
            case .persistenceFailed(let error):
                return "Failed to persist analytics: \(error.localizedDescription)"
            case .cleanupFailed(let error):
                return "Failed to cleanup storage: \(error.localizedDescription)"
            case .recordNotFound:
                return "Analytics record not found"
            }
        }
    }

    // Simple in-memory cache
    struct AnalyticsCache {
        var cachedData: [CravingAnalytics]?
        var lastUpdated: Date?

        var metrics: CacheMetrics {
            // Basic metrics.  Expand as needed.
            CacheMetrics(
                hitRate: 0,  // Calculate hit rate based on usage
                missRate: 0, // Calculate miss rate
                entryCount: cachedData?.count ?? 0
            )
        }
    }
}


// MARK: - Storage Metrics

struct StorageMetrics {
    var totalStored: Int = 0
    var cacheHits: Int = 0
    var cacheMisses: Int = 0
    var lastCleanupTime: Date?
    var cacheMetrics: CacheMetrics = CacheMetrics() // Initialize

    mutating func update(for operation: AnalyticsStorage.StorageOperation) {
        switch operation {
        case .store:
            totalStored += 1
        case .cacheHit:
            cacheHits += 1
        case .cacheMiss:
            cacheMisses += 1
        case .cleanup:
            lastCleanupTime = Date()
        }
    }
}

struct CacheMetrics {
    var hitRate: Double = 0 // Add properties
    var missRate: Double = 0
    var entryCount: Int = 0
}


// MARK: - Testing Support

extension AnalyticsStorage {
    static func preview() -> AnalyticsStorage {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: CravingAnalytics.self, configurations: config) // Use CravingAnalytics
        return AnalyticsStorage(modelContext: container.mainContext)
    }
}

