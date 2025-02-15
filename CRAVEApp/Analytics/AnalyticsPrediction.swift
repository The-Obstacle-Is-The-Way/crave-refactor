//
// File: AnalyticsPrediction.swift
// Purpose: Implements predictive analytics for future craving patterns
//

import Foundation

protocol AnalyticsPrediction: Identifiable { // MARKED: Protocol now conforms to Identifiable
    var id: UUID { get }
    var predictionType: PredictionType { get }
    var timestamp: Date { get }
    var confidenceScore: Double { get }
    var explanation: String { get }
    var suggestedAction: String { get }
    var metadata: [String: String]? { get }
}

enum PredictionType: String, Codable, CaseIterable { // MARKED: Codable, CaseIterable, String Raw Value
    case cravingLikelihood
    case triggerIdentification
    case optimalIntervention
    case patternAnticipation
}

// Placeholder - if you intend to use CravingAnalytics, define it or remove this line.
// ERROR RESOLVED (Potentially):  If CravingAnalytics is not needed, comment out or remove.
// If it *is* needed, you MUST define or import CravingAnalytics.
//protocol CravingAnalytics {  // COMMENTED OUT - Define or import CravingAnalytics if needed.
//    // ... define CravingAnalytics protocol requirements ...
//}

struct CravingLikelihoodPrediction: AnalyticsPrediction, Codable { // MARKED: Codable, Conforms to AnalyticsPrediction
    let id: UUID = UUID()
    let predictionType: PredictionType = .cravingLikelihood // Corrected: Use enum case directly
    let timestamp: Date = Date()
    let confidenceScore: Double
    let explanation: String
    let suggestedAction: String
    let metadata: [String: String]?

    // ADDED: Explicit CodingKeys to handle potential Codable issues
    enum CodingKeys: String, CodingKey {
        case confidenceScore, explanation, suggestedAction, metadata
    }
}

// Add other concrete prediction types (e.g., TriggerIdentificationPrediction, etc.)
// ... define other prediction structs similarly, ensuring Codable conformance and AnalyticsPrediction protocol conformance

