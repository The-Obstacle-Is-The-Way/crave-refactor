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
    let id: UUID = UUID()
    let predictionType: PredictionType = .cravingLikelihood
    let timestamp: Date = Date()
    let confidenceScore: Double
    let explanation: String
    let suggestedAction: String
    let metadata: [String: String]?
}

// MARK: - Preview Support
extension CravingLikelihoodPrediction {
    static var preview: CravingLikelihoodPrediction {
        CravingLikelihoodPrediction(
            confidenceScore: 0.85,
            explanation: "High likelihood of craving in the next hour based on historical patterns",
            suggestedAction: "Consider engaging in a preventive activity",
            metadata: ["time_of_day": "evening", "day_of_week": "wednesday"]
        )
    }
}
