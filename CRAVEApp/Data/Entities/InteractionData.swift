//
//  InteractionData.swift
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

// MARK: - Interaction Tracking
extension InteractionData {
    func trackAction(_ action: UserInteractionEvent) {
        userActions.append(action)
        updateMetrics(for: action)
    }
    
    func startInteraction() {
        timestamp = Date()
    }
    
    func completeInteraction(result: InteractionResult) {
        self.interactionResult = result
        self.completionTime = Date().timeIntervalSince(timestamp)
    }
    
    private func updateMetrics(for action: UserInteractionEvent) {
        switch action.eventType {
        case .screenView:
            viewDuration += action.duration
        case .validation:
            validationAttempts += 1
        case .error:
            retryCount += 1
        default:
            break
        }
    }
}

// MARK: - Performance Monitoring
extension InteractionData {
    func trackPerformance(loadTime: TimeInterval, renderTime: TimeInterval) {
        self.loadTime = loadTime
        self.renderTime = renderTime
        self.responseTime = loadTime + renderTime
    }
    
    var isPerformanceOptimal: Bool {
        return loadTime < 0.1 && renderTime < 0.05
    }
}

// MARK: - Validation
extension InteractionData {
    func addValidationError(_ error: ValidationError) {
        validationErrors.append(error)
        validationAttempts += 1
        isValidated = false
    }
    
    func clearValidation() {
        validationErrors.removeAll()
        isValidated = true
    }
}

// MARK: - Analytics Integration
extension InteractionData {
    func generateAnalytics() -> InteractionAnalytics {
        return InteractionAnalytics(
            interactionId: id,
            cravingId: cravingId,
            duration: completionTime,
            actionCount: userActions.count,
            errorRate: Double(validationErrors.count) / Double(validationAttempts),
            performanceMetrics: PerformanceMetrics(
                loadTime: loadTime,
                renderTime: renderTime,
                responseTime: responseTime
            )
        )
    }
}

// MARK: - Supporting Types for Analytics
struct InteractionAnalytics: Codable {
    let interactionId: UUID
    let cravingId: UUID
    let duration: TimeInterval
    let actionCount: Int
    let errorRate: Double
    let performanceMetrics: PerformanceMetrics
}

struct PerformanceMetrics: Codable {
    let loadTime: TimeInterval
    let renderTime: TimeInterval
    let responseTime: TimeInterval
}

// MARK: - Testing Support
extension InteractionData {
    static func mock(cravingId: UUID = UUID()) -> InteractionData {
        let interaction = InteractionData(cravingId: cravingId)
        interaction.viewDuration = TimeInterval.random(in: 0...300)
        interaction.completionTime = TimeInterval.random(in: 0...60)
        interaction.validationAttempts = Int.random(in: 0...3)
        return interaction
    }
}
