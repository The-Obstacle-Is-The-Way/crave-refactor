//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsPattern.swift
//  Purpose: Defines pattern recognition and analysis for craving behaviors
//
//

import Foundation
import SwiftData

// MARK: - Pattern Protocol
protocol AnalyticsPattern: Codable, Identifiable {
    var id: UUID { get }
    var patternType: PatternType { get }
    var confidence: Double { get }
    var frequency: Int { get }
    var firstObserved: Date { get }
    var lastObserved: Date { get }
    var metadata: PatternMetadata { get }
    
    func matches(_ analytics: CravingAnalytics) -> Bool
    func updateWith(_ analytics: CravingAnalytics)
    func calculateConfidence() -> Double
}

// MARK: - Base Pattern Implementation
class BasePattern: AnalyticsPattern {
    let id: UUID
    let patternType: PatternType
    private(set) var confidence: Double
    private(set) var frequency: Int
    private(set) var firstObserved: Date
    private(set) var lastObserved: Date
    private(set) var metadata: PatternMetadata
    
    private var observations: [PatternObservation]
    
    init(type: PatternType, metadata: PatternMetadata) {
        self.id = UUID()
        self.patternType = type
        self.confidence = 0.0
        self.frequency = 0
        self.firstObserved = Date()
        self.lastObserved = Date()
        self.metadata = metadata
        self.observations = []
    }
    
    func matches(_ analytics: CravingAnalytics) -> Bool {
        fatalError("Must be implemented by subclass")
    }
    
    func updateWith(_ analytics: CravingAnalytics) {
        frequency += 1
        lastObserved = analytics.timestamp
        
        let observation = PatternObservation(
            timestamp: analytics.timestamp,
            strength: calculateStrength(for: analytics)
        )
        observations.append(observation)
        
        confidence = calculateConfidence()
        updateMetadata(with: analytics)
    }
    
    func calculateConfidence() -> Double {
        guard !observations.isEmpty else { return 0.0 }
        
        let totalStrength = observations.reduce(0.0) { $0 + $1.strength }
        let averageStrength = totalStrength / Double(observations.count)
        
        // Factor in frequency and time span
        let timeSpan = lastObserved.timeIntervalSince(firstObserved)
        let frequencyFactor = min(Double(frequency) / 10.0, 1.0) // Cap at 10 observations
        let timeFactor = min(timeSpan / (30 * 24 * 3600), 1.0) // Cap at 30 days
        
        return averageStrength * frequencyFactor * timeFactor
    }
    
    private func calculateStrength(for analytics: CravingAnalytics) -> Double {
        // Default implementation - override in subclasses
        return 1.0
    }
    
    private func updateMetadata(with analytics: CravingAnalytics) {
        metadata.updateWith(analytics)
    }
}

// MARK: - Specific Pattern Types
class TimeBasedPattern: BasePattern {
    private let timeWindow: TimeInterval
    private let targetHour: Int
    
    init(hour: Int, windowMinutes: Int) {
        self.targetHour = hour
        self.timeWindow = TimeInterval(windowMinutes * 60)
        super.init(type: .timeBased, metadata: PatternMetadata())
    }
    
    override func matches(_ analytics: CravingAnalytics) -> Bool {
        let hour = Calendar.current.component(.hour, from: analytics.timestamp)
        let minuteDifference = abs(Double(hour - targetHour) * 3600)
        return minuteDifference <= timeWindow
    }
    
    override func calculateStrength(for analytics: CravingAnalytics) -> Double {
        let hour = Calendar.current.component(.hour, from: analytics.timestamp)
        let hourDifference = abs(Double(hour - targetHour))
        return max(1.0 - (hourDifference / 12.0), 0.0)
    }
}

class TriggerBasedPattern: BasePattern {
    private let triggerSet: Set<String>
    
    init(triggers: Set<String>) {
        self.triggerSet = triggers
        super.init(type: .triggerBased, metadata: PatternMetadata())
    }
    
    override func matches(_ analytics: CravingAnalytics) -> Bool {
        !triggerSet.isDisjoint(with: analytics.triggers)
    }
    
    override func calculateStrength(for analytics: CravingAnalytics) -> Double {
        let commonTriggers = triggerSet.intersection(analytics.triggers)
        return Double(commonTriggers.count) / Double(triggerSet.count)
    }
}

// MARK: - Supporting Types
enum PatternType: String, Codable {
    case timeBased
    case locationBased
    case triggerBased
    case contextBased
    case combinedBased
}

struct PatternMetadata: Codable {
    var observations: Int = 0
    var averageIntensity: Double = 0.0
    var successRate: Double = 0.0
    var contextualFactors: [String: Int] = [:]
    
    mutating func updateWith(_ analytics: CravingAnalytics) {
        observations += 1
        averageIntensity = ((averageIntensity * Double(observations - 1)) + Double(analytics.intensity)) / Double(observations)
        // Update other metadata...
    }
}

struct PatternObservation: Codable {
    let timestamp: Date
    let strength: Double
}

// MARK: - Pattern Recognition Engine
class PatternRecognitionEngine {
    private var patterns: [AnalyticsPattern] = []
    private let configuration: PatternConfiguration
    
    init(configuration: PatternConfiguration = .default) {
        self.configuration = configuration
    }
    
    func processAnalytics(_ analytics: CravingAnalytics) {
        // Update existing patterns
        updateExistingPatterns(with: analytics)
        
        // Detect new patterns
        if let newPattern = detectNewPattern(from: analytics) {
            patterns.append(newPattern)
        }
        
        // Prune low-confidence patterns
        prunePatterns()
    }
    
    private func updateExistingPatterns(with analytics: CravingAnalytics) {
        patterns.forEach { pattern in
            if pattern.matches(analytics) {
                pattern.updateWith(analytics)
            }
        }
    }
    
    private func detectNewPattern(from analytics: CravingAnalytics) -> AnalyticsPattern? {
        // Implement pattern detection logic
        return nil
    }
    
    private func prunePatterns() {
        patterns.removeAll { $0.confidence < configuration.minimumConfidence }
    }
}

// MARK: - Configuration
struct PatternConfiguration {
    let minimumConfidence: Double
    let minimumObservations: Int
    let maximumPatterns: Int
    
    static let `default` = PatternConfiguration(
        minimumConfidence: 0.3,
        minimumObservations: 3,
        maximumPatterns: 50
    )
}

// MARK: - Testing Support
extension BasePattern {
    static func mock(type: PatternType = .timeBased) -> BasePattern {
        BasePattern(type: type, metadata: PatternMetadata())
    }
}
