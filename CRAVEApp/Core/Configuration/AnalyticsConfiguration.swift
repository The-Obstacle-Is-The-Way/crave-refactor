//
//  🍒
//  AnalyticsConfiguration.swift
//  Purpose: Centralized configuration management for analytics system
//
//

import Foundation
import Combine

final class AnalyticsConfiguration: ObservableObject {
    nonisolated static let shared = AnalyticsConfiguration()
    
    @Published private(set) var currentEnvironment: AppEnvironment = .development
    @Published private(set) var featureFlags: FeatureFlags = .development
    @Published private(set) var processingRules: ProcessingRules = ProcessingRules()
    @Published private(set) var storagePolicy: StoragePolicy = StoragePolicy()
    @Published private(set) var privacySettings: PrivacySettings = PrivacySettings()
    
    let performanceConfig: PerformanceConfiguration = PerformanceConfiguration()
    let networkConfig: NetworkConfiguration = NetworkConfiguration()
    let mlConfig: MLConfiguration = MLConfiguration()
    
    private init() {}
    
    func updateEnvironment(_ environment: AppEnvironment) {
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
    var retentionPeriod: TimeInterval = 30 * 24 * 3600
    var maxStorageSize: Int64 = 100 * 1024 * 1024
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
    
    func validate() -> Bool { true }
}

struct PerformanceConfiguration {
    let maxConcurrentOperations: Int = 4
    let maxMemoryUsage: Int64 = 50 * 1024 * 1024
    let backgroundTaskTimeout: TimeInterval = 180
    let minimumBatteryLevel: Float = 0.2
}

struct NetworkConfiguration {
    let maxRetries: Int = 3
    let timeout: TimeInterval = 30
    let batchSize: Int = 50
    let compressionThreshold: Int = 1024 * 10
}

struct MLConfiguration {
    let modelUpdateInterval: TimeInterval = 24 * 3600
    let minimumConfidence: Double = 0.7
    let maxPredictionWindow: TimeInterval = 7 * 24 * 3600
    let trainingDataLimit: Int = 1000
}

enum AppEnvironment: String, Codable {
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
