// AnalyticsStorage.swift

import Foundation
import SwiftData
import Combine

@MainActor
final class AnalyticsStorage {
    // MARK: - Properties
    private let modelContext: ModelContext
    private let cache: AnalyticsCache
    private let queue: OperationQueue
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Storage Configuration
    private let config: StorageConfiguration
    private let maxCacheSize: Int
    private let expirationInterval: TimeInterval
    
    // MARK: - Storage Metrics
    @Published private(set) var storageMetrics: StorageMetrics
    @Published private(set) var lastSyncTime: Date?
    
    // MARK: - Initialization
    init(modelContext: ModelContext,
         configuration: StorageConfiguration = .default) {
        self.modelContext = modelContext
        self.config = configuration
        self.maxCacheSize = configuration.maxCacheSize
        self.expirationInterval = configuration.expirationInterval
        self.cache = AnalyticsCache(capacity: maxCacheSize)
        self.queue = OperationQueue()
        self.storageMetrics = StorageMetrics()
        
        setupStorage()
    }
    
    // MARK: - Public Interface
    func store(_ analytics: CravingAnalytics) async throws {
        do {
            // Update cache
            cache.insert(analytics)
            
            // Persist to storage
            try await persistAnalytics(analytics)
            
            // Update metrics
            updateMetrics(for: .store)
            
            // Trigger cleanup if needed
            if shouldPerformCleanup {
                try await performCleanup()
            }
            
        } catch {
            throw StorageError.storeFailed(error)
        }
    }
    
    func fetch(id: UUID) async throws -> CravingAnalytics {
        // Check cache first
        if let cached = cache.get(id) {
            updateMetrics(for: .cacheHit)
            return cached
        }
        
        // Fetch from persistent storage
        do {
            let descriptor = FetchDescriptor<AnalyticsRecord>(
                predicate: #Predicate<AnalyticsRecord> { $0.id == id }
            )
            
            guard let record = try modelContext.fetch(descriptor).first else {
                throw StorageError.recordNotFound
            }
            
            let analytics = try record.toAnalytics()
            cache.insert(analytics)
            updateMetrics(for: .cacheMiss)
            
            return analytics
            
        } catch {
            throw StorageError.fetchFailed(error)
        }
    }
    
    func fetchRange(_ dateRange: DateInterval) async throws -> [CravingAnalytics] {
        let descriptor = FetchDescriptor<AnalyticsRecord>(
            predicate: #Predicate<AnalyticsRecord> {
                $0.timestamp >= dateRange.start && $0.timestamp <= dateRange.end
            }
        )
        
        do {
            let records = try modelContext.fetch(descriptor)
            return try records.map { try $0.toAnalytics() }
        } catch {
            throw StorageError.fetchFailed(error)
        }
    }
    
    // MARK: - Private Methods
    private func setupStorage() {
        setupPeriodicCleanup()
        setupCacheMonitoring()
    }
    
    private func persistAnalytics(_ analytics: CravingAnalytics) async throws {
        let record = AnalyticsRecord(from: analytics)
        modelContext.insert(record)
        
        do {
            try modelContext.save()
        } catch {
            throw StorageError.persistenceFailed(error)
        }
    }
    
    private func setupPeriodicCleanup() {
        Timer.publish(every: config.cleanupInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    try? await self.performCleanup()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupCacheMonitoring() {
        cache.metricsPublisher
            .sink { [weak self] metrics in
                self?.storageMetrics.cacheMetrics = metrics
            }
            .store(in: &cancellables)
    }
    
    private func performCleanup() async throws {
        // Clean expired cache entries
        cache.removeExpired(olderThan: expirationInterval)
        
        // Clean old persistent records
        let cleanupDate = Date().addingTimeInterval(-expirationInterval)
        let descriptor = FetchDescriptor<AnalyticsRecord>(
            predicate: #Predicate<AnalyticsRecord> {
                $0.timestamp < cleanupDate
            }
        )
        
        do {
            let oldRecords = try modelContext.fetch(descriptor)
            oldRecords.forEach { modelContext.delete($0) }
            try modelContext.save()
            
            updateMetrics(for: .cleanup(recordsRemoved: oldRecords.count))
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
        
        static let `default` = StorageConfiguration(
            maxCacheSize: 1000,
            expirationInterval: 30 * 24 * 60 * 60, // 30 days
            cleanupInterval: 24 * 60 * 60 // 1 day
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
}

// MARK: - Storage Metrics
struct StorageMetrics {
    var totalStored: Int = 0
    var cacheHits: Int = 0
    var cacheMisses: Int = 0
    var lastCleanupTime: Date?
    var cacheMetrics: CacheMetrics = CacheMetrics()
    
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

// MARK: - Testing Support
extension AnalyticsStorage {
    static func preview() -> AnalyticsStorage {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: AnalyticsRecord.self)
        return AnalyticsStorage(modelContext: container.mainContext)
    }
}
