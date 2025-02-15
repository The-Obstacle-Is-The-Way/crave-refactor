//
//  CRAVEApp/Data/Entities/InteractionData.swift
//  CRAVE
//

import Foundation
import SwiftData

// MARK: - InteractionData Model
@Model
final class InteractionData {
    // MARK: - Core Properties
    @Attribute(.unique) var id: UUID
    var cravingId: UUID
    var timestamp: Date

    // MARK: - Interaction Metrics
    var viewDuration: TimeInterval
    var interactionType: InteractionType
    var interactionResult: InteractionResult
    var userActions: [UserInteractionEvent]

    // MARK: - UI/UX Data
    var screenPath: [String]
    var inputMethod: InputMethod
    var completionTime: TimeInterval
    var retryCount: Int

    // MARK: - Performance Metrics
    var responseTime: TimeInterval
    var loadTime: TimeInterval
    var renderTime: TimeInterval

    // MARK: - Validation
    var validationAttempts: Int
    var validationErrors: [ValidationError]
    var isValidated: Bool

    // MARK: - Initialization
    init(cravingId: UUID,
         interactionType: InteractionType = .view,
         inputMethod: InputMethod = .direct) {
        self.id = UUID()
        self.cravingId = cravingId
        self.timestamp = Date()
        self.viewDuration = 0
        self.interactionType = interactionType
        self.interactionResult = .pending
        self.userActions = []
        self.screenPath = []
        self.inputMethod = inputMethod
        self.completionTime = 0
        self.retryCount = 0
        self.responseTime = 0
        self.loadTime = 0
        self.renderTime = 0
        self.validationAttempts = 0
        self.validationErrors = []
        self.isValidated = false
    }
}

// MARK: - Supporting Types
extension InteractionData {
    enum InteractionType: String, Codable {
        case view
        case create
        case update
        case delete
        case analyze
        case export
    }

    enum InteractionResult: String, Codable {
        case pending
        case success
        case failure
        case cancelled
        case timeout
    }

    enum InputMethod: String, Codable {
        case direct      // Manual text entry
        case voice      // Voice input
        case selection  // Picker/List selection
        case automatic  // System generated
    }

    struct UserInteractionEvent: Codable {
        let timestamp: Date
        let eventType: EventType
        let duration: TimeInterval
        let metadata: [String: String]

        enum EventType: String, Codable {
            case screenView
            case buttonTap
            case textInput
            case validation
            case submission
            case error
        }
    }

    struct ValidationError: Codable {
        let field: String
        let errorType: ErrorType
        let message: String
        let timestamp: Date

        enum ErrorType: String, Codable {
            case required
            case format
            case range
            case custom
        }
    }
}
