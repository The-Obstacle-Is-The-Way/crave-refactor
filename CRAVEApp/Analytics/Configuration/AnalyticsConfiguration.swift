//
//  🍒
//  AnalyticsConfiguration.swift
//  Purpose: Centralized configuration management for analytics system
//
//


import Foundation
import Combine

@MainActor
final class AnalyticsConfiguration: ObservableObject {
    // MARK: - Shared Instance
    static let shared = AnalyticsConfiguration()

    // MARK: - Published Settings
    @Published private(set) var currentEnvironment: Environment = .development
    @Published private(set) var featureFlags: FeatureFlags = .development // Initialize with default
    @Published private(set) var processingRules: ProcessingRules = ProcessingRules() // Initialize
    @Published private(set) var storagePolicy: StoragePolicy = StoragePolicy() // Initialize
    @Published private(set) var privacySettings: PrivacySettings = PrivacySettings() // Initialize

    // MARK: - Performance Settings
    let performanceConfig: PerformanceConfiguration = PerformanceConfiguration() // Initialize
    let networkConfig: NetworkConfiguration = NetworkConfiguration() // Initialize
    let mlConfig: MLConfiguration = MLConfiguration() // Initialize

    private init() {} // Private initializer for singleton

    func updateEnvironment(_ environment: Environment) {
        currentEnvironment = environment
        featureFlags = environment == .production ? .production : .development
        NotificationCenter.default.post(name: .analyticsConfigurationUpdated, object: nil)
    }

    func updateFeatureFlags(_ flags: FeatureFlags) {
        featureFlags = flags
        NotificationCenter.default.post(name: .analyticsConfigurationUpdated, object: nil)
    }

    func updatePrivacySettings(_ settings: PrivacySettings) async throws {
        guard settings.validate() else {
            throw ConfigurationError.invalidPrivacySettings
        }
        privacySettings = settings
    }
}

// MARK: - Configuration Types
struct FeatureFlags: Codable {
    var isMLEnabled: Bool
    var isRealtimeProcessingEnabled: Bool
    var isBackgroundProcessingEnabled: Bool
    var isCloudSyncEnabled: Bool
    var isDebugLoggingEnabled: Bool
    var isAnalyticsEnabled: Bool
    var isAutoProcessingEnabled: Bool

    static let development = FeatureFlags(
        isMLEnabled: true,
        isRealtimeProcessingEnabled: true,
        isBackgroundProcessingEnabled: true,
        isCloudSyncEnabled: false,
        isDebugLoggingEnabled: true,
        isAnalyticsEnabled: true,
        isAutoProcessingEnabled: true
    )

    static let production = FeatureFlags(
        isMLEnabled: true,
        isRealtimeProcessingEnabled: true,
        isBackgroundProcessingEnabled: true,
        isCloudSyncEnabled: true,
        isDebugLoggingEnabled: false,
        isAnalyticsEnabled: true,
        isAutoProcessingEnabled: true
    )
}

struct ProcessingRules: Codable {
    var batchSize: Int = 100
    var processingInterval: TimeInterval = 300
    var maxRetryAttempts: Int = 3
    var timeoutInterval: TimeInterval = 30
    var priorityThreshold: Double = 0.7
}

struct StoragePolicy: Codable {
    var retentionPeriod: TimeInterval = 30 * 24 * 3600 // 30 days
    var maxStorageSize: Int64 = 100 * 1024 * 1024 // 100 MB
    var compressionEnabled: Bool = true
    var encryptionEnabled: Bool = true
    var autoCleanupEnabled: Bool = true
}

struct PrivacySettings: Codable {
    var dataCollectionEnabled: Bool = true
    var locationTrackingEnabled: Bool = false
    var healthKitEnabled: Bool = false
    var analyticsEnabled: Bool = true
    var dataSharingEnabled: Bool = false

    func validate() -> Bool { return true }
}

struct PerformanceConfiguration: Codable { // Made Codable
    let maxConcurrentOperations: Int = 4
    let maxMemoryUsage: Int64 = 50 * 1024 * 1024 // 50 MB
    let backgroundTaskTimeout: TimeInterval = 180
    let minimumBatteryLevel: Float = 0.2
}

struct NetworkConfiguration: Codable { // Made Codable
    let maxRetries: Int = 3
    let timeout: TimeInterval = 30
    let batchSize: Int = 50
    let compressionThreshold: Int = 1024 * 10 // 10 KB
}

struct MLConfiguration: Codable { // Made Codable
    let modelUpdateInterval: TimeInterval = 24 * 3600 // 24 hours
    let minimumConfidence: Double = 0.7
    let maxPredictionWindow: TimeInterval = 7 * 24 * 3600 // 7 days
    let trainingDataLimit: Int = 1000
}

// MARK: - Supporting Types
enum Environment: String, Codable {
    case development
    case staging
    case production
}

enum ConfigurationError: Error {
    case invalidConfiguration
    case invalidPrivacySettings
    case invalidProcessingRules
    case invalidStoragePolicy
}

extension Notification.Name {
    static let analyticsConfigurationUpdated = Notification.Name("analyticsConfigurationUpdated")
}

// MARK: - Preview Support
extension AnalyticsConfiguration {
    static var preview: AnalyticsConfiguration {
        let config = AnalyticsConfiguration()
        config.updateFeatureFlags(.development)
        return config
    }
}
