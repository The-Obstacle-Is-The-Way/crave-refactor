//
//  🍒
//  CRAVEApp/Data/Models/InteractionData.swift
//  Purpose: Model for tracking user interactions.
//
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
    @Attribute(.externalStorage) var userActions: [UserInteractionEvent] // Use external storage

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
         timestamp: Date = Date(), // Add timestamp
         viewDuration: TimeInterval = 0,
         interactionType: InteractionType = .view,
         interactionResult: InteractionResult = .pending,
         userActions: [UserInteractionEvent] = [],
         screenPath: [String] = [],
         inputMethod: InputMethod = .direct,
         completionTime: TimeInterval = 0,
         retryCount: Int = 0,
         responseTime: TimeInterval = 0,
         loadTime: TimeInterval = 0,
         renderTime: TimeInterval = 0,
         validationAttempts: Int = 0,
         validationErrors: [ValidationError] = [],
         isValidated: Bool = false
    ) {
        self.id = UUID()
        self.cravingId = cravingId
        self.timestamp = timestamp // Use the provided timestamp
        self.viewDuration = viewDuration
        self.interactionType = interactionType
        self.interactionResult = interactionResult
        self.userActions = userActions
        self.screenPath = screenPath
        self.inputMethod = inputMethod
        self.completionTime = completionTime
        self.retryCount = retryCount
        self.responseTime = responseTime
        self.loadTime = loadTime
        self.renderTime = renderTime
        self.validationAttempts = validationAttempts
        self.validationErrors = validationErrors
        self.isValidated = isValidated
    }

    // MARK: - Supporting Types
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
