//
// File: AnalyticsPrediction.swift
// Purpose: Implements predictive analytics for future craving patterns
//

import Foundation

protocol AnalyticsPrediction: Identifiable, Codable {
    var id: UUID { get }
    var predictionType: PredictionType { get }
    var timestamp: Date { get }
    var confidenceScore: Double { get }
    var explanation: String { get }
    var suggestedAction: String { get }
    var metadata: [String: String]? { get }
}

enum PredictionType: String, Codable, CaseIterable {
    case cravingLikelihood
    case triggerIdentification
    case optimalIntervention
    case patternAnticipation
}

struct CravingLikelihoodPrediction: AnalyticsPrediction {
    let id: UUID
    let predictionType: PredictionType
    let timestamp: Date
    let confidenceScore: Double
    let explanation: String
    let suggestedAction: String
    let metadata: [String: String]?

    // Corrected initializer:  NO default values for id, predictionType and timestamp.
    init(id: UUID, predictionType: PredictionType, timestamp: Date, confidenceScore: Double, explanation: String, suggestedAction: String, metadata: [String : String]? = nil) {
        self.id = id
        self.predictionType = predictionType
        self.timestamp = timestamp
        self.confidenceScore = confidenceScore
        self.explanation = explanation
        self.suggestedAction = suggestedAction
        self.metadata = metadata
    }
}

// MARK: - Preview Support
extension CravingLikelihoodPrediction {
    static var preview: CravingLikelihoodPrediction {
        CravingLikelihoodPrediction(
            id: UUID(), // Provide explicit UUID
            predictionType: .cravingLikelihood,
            timestamp: Date(), // Provide explicit Date
            confidenceScore: 0.85,
            explanation: "High likelihood of craving in the next hour based on historical patterns",
            suggestedAction: "Consider engaging in a preventive activity",
            metadata: ["time_of_day": "evening", "day_of_week": "wednesday"]
        )
    }
}
