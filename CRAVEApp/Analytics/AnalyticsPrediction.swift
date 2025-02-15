//
// File: AnalyticsPrediction.swift
// Purpose: Implements predictive analytics for future craving patterns
//

import Foundation
import SwiftData
import CoreML

// MARK: - Prediction Protocol
protocol AnalyticsPrediction: Identifiable, Codable {
    var id: UUID { get }
    var type: PredictionType { get }
    var timestamp: Date { get }
    var confidence: Double { get }
    var timeWindow: TimeInterval { get }
    var metadata: PredictionMetadata { get }

    func validate() -> Bool
    func hasExpired() -> Bool
    func calculateAccuracy(against actual: CravingAnalytics) -> Double // ✅ CravingAnalytics should now be recognized
}

// MARK: - Base Prediction Implementation
struct BasePrediction: AnalyticsPrediction {
    let id: UUID
    let type: PredictionType
    let timestamp: Date
    let confidence: Double
    let timeWindow: TimeInterval
    let metadata: PredictionMetadata

    private let predictionDate: Date
    private let expirationDate: Date

    init(
        type: PredictionType,
        confidence: Double,
        timeWindow: TimeInterval,
        metadata: PredictionMetadata = PredictionMetadata()
    ) {
        self.id = UUID()
        self.type = type
        self.confidence = confidence
        self.timeWindow = timeWindow
        self.metadata = metadata
        self.timestamp = Date()
        self.predictionDate = Date().addingTimeInterval(timeWindow)
        self.expirationDate = self.predictionDate.addingTimeInterval(timeWindow * 0.5)
    }

    func validate() -> Bool {
        guard confidence >= 0 && confidence <= 1 else { return false }
        guard timeWindow > 0 else { return false }
        return true
    }

    func hasExpired() -> Bool {
        return Date() > expirationDate
    }

    func calculateAccuracy(against actual: CravingAnalytics) -> Double { // ✅ CravingAnalytics should now be recognized
        let timeDifference = abs(predictionDate.timeIntervalSince(actual.timestamp))
        let timeAccuracy = max(0, 1 - (timeDifference / timeWindow))
        return timeAccuracy * confidence
    }
}

// MARK: - Specific Prediction Types
struct TimePrediction: AnalyticsPrediction {
    let id: UUID = UUID()
    let type: PredictionType = .timeBasedCraving
    let timestamp: Date
    let confidence: Double
    let timeWindow: TimeInterval
    let metadata: PredictionMetadata

    let predictedHour: Int
    let predictedIntensity: Double
    let likelyTriggers: Set<String>

    init(
        hour: Int,
        intensity: Double,
        triggers: Set<String>,
        confidence: Double,
        windowMinutes: Int
    ) {
        self.predictedHour = hour
        self.predictedIntensity = intensity
        self.likelyTriggers = triggers
        self.confidence = confidence
        self.timeWindow = TimeInterval(windowMinutes * 60)
        self.timestamp = Date()
        self.metadata = PredictionMetadata(
            factors: ["hour": String(hour), "intensity": String(intensity)]
        )
    }

    func validate() -> Bool {
        guard predictedHour >= 0 && predictedHour < 24 else { return false }
        guard predictedIntensity >= 0 && predictedIntensity <= 10 else { return false }
        return true
    }

    func hasExpired() -> Bool {
        let currentHour = Calendar.current.component(.hour, from: Date())
        return currentHour > predictedHour
    }

    func calculateAccuracy(against actual: CravingAnalytics) -> Double { // ✅ CravingAnalytics should now be recognized
        let actualHour = Calendar.current.component(.hour, from: actual.timestamp)
        let hourDifference = abs(predictedHour - actualHour)
        let timeAccuracy = max(0, 1 - (Double(hourDifference) / 12.0))

        let intensityDifference = abs(predictedIntensity - Double(actual.intensity))
        let intensityAccuracy = max(0, 1 - (intensityDifference / 10.0))

        let triggerAccuracy = calculateTriggerAccuracy(against: actual.triggers)

        return (timeAccuracy + intensityAccuracy + triggerAccuracy) / 3.0 * confidence
    }

    private func calculateTriggerAccuracy(against actualTriggers: Set<String>) -> Double {
        guard !likelyTriggers.isEmpty else { return 0 }
        let commonTriggers = likelyTriggers.intersection(actualTriggers)
        return Double(commonTriggers.count) / Double(likelyTriggers.count)
    }
}

// MARK: - Supporting Types
enum PredictionType: String, Codable {
    case timeBasedCraving
    case locationBasedCraving
    case triggerBasedCraving
    case intensityPrediction
    case durationPrediction

    var minimumConfidence: Double {
        switch self {
        case .timeBasedCraving: return 0.7
        case .locationBasedCraving: return 0.8
        case .triggerBasedCraving: return 0.75
        case .intensityPrediction: return 0.6
        case .durationPrediction: return 0.65
        }
    }
}

struct PredictionMetadata: Codable {
    var factors: [String: String] = [:]
    var dataPoints: Int = 0
    var modelVersion: String = "1.0"
    var generationTime: TimeInterval = 0

    init(factors: [String: String] = [:]) {
        self.factors = factors
        self.dataPoints = 0
        self.modelVersion = "1.0"
        self.generationTime = 0
    }
}

// MARK: - Prediction Engine
class PredictionEngine {
    private let configuration: PredictionConfiguration
    private var predictions: [AnalyticsPrediction] = []
    private var mlModel: MLModel?

    init(configuration: PredictionConfiguration = .default) {
        self.configuration = configuration
        setupMLModel()
    }

    func generatePrediction(from analytics: [CravingAnalytics]) throws -> AnalyticsPrediction { // ✅ CravingAnalytics should now be recognized
        cleanExpiredPredictions()

        // Generate prediction based on historical data
        let prediction = try generateTimePrediction(from: analytics)
        predictions.append(prediction)

        return prediction
    }

    private func generateTimePrediction(from analytics: [CravingAnalytics]) throws -> TimePrediction { // ✅ CravingAnalytics should now be recognized
        // Implement prediction logic using historical data and ML model
        guard let predictedHour = predictNextCravingHour(from: analytics),
              let predictedIntensity = predictIntensity(from: analytics),
              let likelyTriggers = predictTriggers(from: analytics) else {
            throw PredictionError.insufficientData
        }

        return TimePrediction(
            hour: predictedHour,
            intensity: predictedIntensity,
            triggers: likelyTriggers,
            confidence: calculateConfidence(for: analytics),
            windowMinutes: configuration.defaultWindowMinutes
        )
    }

    private func setupMLModel() {
        // Initialize ML model
    }

    private func cleanExpiredPredictions() {
        predictions.removeAll { $0.hasExpired() }
    }

    private func predictNextCravingHour(from analytics: [CravingAnalytics]) -> Int? { // ✅ CravingAnalytics should now be recognized
        // Implement hour prediction logic
        return nil
    }

    private func predictIntensity(from analytics: [CravingAnalytics]) -> Double? { // ✅ CravingAnalytics should now be recognized
        // Implement intensity prediction logic
        return nil
    }

    private func predictTriggers(from analytics: [CravingAnalytics]) -> Set<String>? { // ✅ CravingAnalytics should now be recognized
        // Implement trigger prediction logic
        return nil
    }

    private func calculateConfidence(for analytics: [CravingAnalytics]) -> Double { // ✅ CravingAnalytics should now be recognized
        // Implement confidence calculation
        return 0.8
    }
}

// MARK: - Configuration
struct PredictionConfiguration {
    let minimumDataPoints: Int
    let maximumPredictions: Int
    let defaultWindowMinutes: Int
    let confidenceThreshold: Double

    static let `default` = PredictionConfiguration(
        minimumDataPoints: 10,
        maximumPredictions: 5,
        defaultWindowMinutes: 60,
        confidenceThreshold: 0.6
    )
}

// MARK: - Errors
enum PredictionError: Error {
    case insufficientData
    case modelError
    case invalidPrediction
    case configurationError

    var localizedDescription: String {
        switch self {
        case .insufficientData:
            return "Insufficient data for prediction"
        case .modelError:
            return "Error in prediction model"
        case .invalidPrediction:
            return "Invalid prediction generated"
        case .configurationError:
            return "Invalid prediction configuration"
        }
    }
}

// MARK: - Testing Support
extension BasePrediction {
    static func mock() -> BasePrediction {
        BasePrediction(
            type: .timeBasedCraving,
            confidence: 0.8,
            timeWindow: 3600
        )
    }
}



