// File: AnalyticsConfiguration.swift
// Purpose: Centralized configuration management for analytics system

import Foundation
import SwiftData

// MARK: - Main Configuration
@MainActor
final class AnalyticsConfiguration: ObservableObject {
    // MARK: - Shared Instance
    static let shared = AnalyticsConfiguration()
    
    // MARK: - Published Settings
    @Published private(set) var currentEnvironment: Environment
    @Published private(set) var featureFlags: FeatureFlags
    @Published private(set) var processingRules: ProcessingRules
    @Published private(set) var storagePolicy: StoragePolicy
    @Published private(set) var privacySettings: PrivacySettings
    
    // MARK: - Performance Settings
    let performanceConfig: PerformanceConfiguration
    let networkConfig: NetworkConfiguration
    let mlConfig: MLConfiguration
    
    // MARK: - Initialization
    private init() {
        self.currentEnvironment = .development
        self.featureFlags = FeatureFlags()
        self.processingRules = ProcessingRules()
        self.storagePolicy = StoragePolicy()
        self.privacySettings = PrivacySettings()
        self.performanceConfig = PerformanceConfiguration()
        self.networkConfig = NetworkConfiguration()
        self.mlConfig = MLConfiguration()
        
        setupConfiguration()
    }
    
    // MARK: - Configuration Methods
    func updateEnvironment(_ environment: Environment) {
        currentEnvironment = environment
        applyEnvironmentSpecificSettings()
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
        try await applyPrivacySettings()
    }
    
    // MARK: - Private Methods
    private func setupConfiguration() {
        loadSavedConfiguration()
        setupObservers()
    }
    
    private func loadSavedConfiguration() {
        // Load from UserDefaults or remote config
    }
    
    private func setupObservers() {
        // Setup configuration change observers
    }
    
    private func applyEnvironmentSpecificSettings() {
        switch currentEnvironment {
        case .development:
            applyDevelopmentSettings()
        case .staging:
            applyStagingSettings()
        case .production:
            applyProductionSettings()
        }
    }
    
    private func applyPrivacySettings() async throws {
        // Implement privacy settings application
    }
}

// MARK: - Configuration Components
struct FeatureFlags: Codable {
    var isMLEnabled: Bool = true
    var isRealtimeProcessingEnabled: Bool = true
    var isBackgroundProcessingEnabled: Bool = true
    var isCloudSyncEnabled: Bool = false
    var isDebugLoggingEnabled: Bool = false
    var isAnalyticsEnabled: Bool = true // Added for Analytics
    var isAutoProcessingEnabled: Bool = true // Added for Analytics
    
    static let development = FeatureFlags(
        isMLEnabled: true,
        isRealtimeProcessingEnabled: true,
        isBackgroundProcessingEnabled: true,
        isCloudSyncEnabled: false,
        isDebugLoggingEnabled: true
    )
    
    static let production = FeatureFlags(
        isMLEnabled: true,
        isRealtimeProcessingEnabled: true,
        isBackgroundProcessingEnabled: true,
        isCloudSyncEnabled: true,
        isDebugLoggingEnabled: false
    )
}

struct ProcessingRules: Codable {
    var batchSize: Int = 100
    var processingInterval: TimeInterval = 300 // 5 minutes
    var maxRetryAttempts: Int = 3
    var timeoutInterval: TimeInterval = 30
    var priorityThreshold: Double = 0.7
    
    func validate() -> Bool {
        guard batchSize > 0 else { return false }
        guard processingInterval > 0 else { return false }
        guard maxRetryAttempts > 0 else { return false }
        guard timeoutInterval > 0 else { return false }
        guard priorityThreshold >= 0 && priorityThreshold <= 1 else { return false }
        return true
    }
}

struct StoragePolicy: Codable {
    var retentionPeriod: TimeInterval = 30 * 24 * 3600 // 30 days
    var maxStorageSize: Int64 = 100 * 1024 * 1024 // 100 MB
    var compressionEnabled: Bool = true
    var encryptionEnabled: Bool = true
    var autoCleanupEnabled: Bool = true
    
    func validate() -> Bool {
        guard retentionPeriod > 0 else { return false }
        guard maxStorageSize > 0 else { return false }
        return true
    }
}

struct PrivacySettings: Codable {
    var dataCollectionEnabled: Bool = true
    var locationTrackingEnabled: Bool = false
    var healthKitEnabled: Bool = false
    var analyticsEnabled: Bool = true
    var dataSharingEnabled: Bool = false
    
    func validate() -> Bool {
        // Add privacy validation rules
        return true
    }
}

struct PerformanceConfiguration {
    let maxConcurrentOperations: Int = 4
    let maxMemoryUsage: Int64 = 50 * 1024 * 1024 // 50 MB
    let backgroundTaskTimeout: TimeInterval = 180
    let minimumBatteryLevel: Float = 0.2
}

struct NetworkConfiguration {
    let maxRetries: Int = 3
    let timeout: TimeInterval = 30
    let batchSize: Int = 50
    let compressionThreshold: Int = 1024 * 10 // 10 KB
}

struct MLConfiguration {
    let modelUpdateInterval: TimeInterval = 24 * 3600 // 24 hours
    let minimumConfidence: Double = 0.7
    let maxPredictionWindow: TimeInterval = 7 * 24 * 3600 // 7 days
    let trainingDataLimit: Int = 1000
}

// MARK: - Supporting Types
enum Environment: String {
    case development
    case staging
    case production
}

enum ConfigurationError: Error {
    case invalidConfiguration
    case invalidPrivacySettings
    case invalidProcessingRules
    case invalidStoragePolicy
    
    var localizedDescription: String {
        switch self {
        case .invalidConfiguration:
            return "Invalid analytics configuration"
        case .invalidPrivacySettings:
            return "Invalid privacy settings"
        case .invalidProcessingRules:
            return "Invalid processing rules"
        case .invalidStoragePolicy:
            return "Invalid storage policy"
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let analyticsConfigurationUpdated = Notification.Name("analyticsConfigurationUpdated")
}

// MARK: - Testing Support
extension AnalyticsConfiguration {
    static var preview: AnalyticsConfiguration {
        let config = AnalyticsConfiguration()
        config.updateFeatureFlags(.development)
        return config
    }
}


