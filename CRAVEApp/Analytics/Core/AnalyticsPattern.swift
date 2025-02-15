//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsPattern.swift
//  Purpose: Defines pattern recognition and analysis for craving behaviors
//
//

import Foundation

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
    }
}

struct DetectedPattern: Identifiable {
    let id: UUID
    let type: PatternType
    let description: String
    let confidence: Double
    let strength: Double
}

class BasePattern: AnalyticsPattern {
    let id: UUID
    let patternType: PatternType
    private(set) var confidence: Double
    private(set) var frequency: Int
    private(set) var firstObserved: Date
    private(set) var lastObserved: Date
    private(set) var metadata: PatternMetadata
    
    private var observations: [PatternObservation] = []
    
    init(type: PatternType, metadata: PatternMetadata = PatternMetadata()) {
        self.id = UUID()
        self.patternType = type
        self.confidence = 0.0
        self.frequency = 0
        self.firstObserved = Date()
        self.lastObserved = Date()
        self.metadata = metadata
    }
    
    func matches(_ analytics: CravingAnalytics) -> Bool {
        fatalError("Must be implemented by subclass")
    }
    
    func updateWith(_ analytics: CravingAnalytics) {
        frequency += 1
        lastObserved = analytics.timestamp
        confidence = calculateConfidence()
        metadata.updateWith(analytics)
    }
    
    func calculateConfidence() -> Double {
        guard frequency > 0 else { return 0.0 }
        let timeSpan = lastObserved.timeIntervalSince(firstObserved)
        let frequencyFactor = min(Double(frequency) / 10.0, 1.0)
        let timeFactor = min(timeSpan / (30 * 24 * 3600), 1.0)
        return frequencyFactor * timeFactor
    }
}
