// Core/Domain/Entities/Analytics/AnalyticsMetadata.swift

import Foundation

// MARK: - Analytics Metadata Entity
struct AnalyticsMetadata {
    // MARK: - Properties
    let id: UUID
    let cravingId: UUID
    let createdAt: Date
    
    private(set) var interactionCount: Int
    private(set) var lastProcessed: Date
    private(set) var userActions: [UserAction]
    
    // MARK: - Initialization
    init(cravingId: UUID) {
        self.id = UUID()
        self.cravingId = cravingId
        self.createdAt = Date()
        self.interactionCount = 0
        self.lastProcessed = Date()
        self.userActions = []
    }
    
    // MARK: - Mutating Methods
    mutating func incrementInteractions() {
        interactionCount += 1
        lastProcessed = Date()
    }
    
    mutating func addUserAction(_ action: UserAction) {
        userActions.append(action)
        incrementInteractions()
    }
}

// MARK: - Supporting Types
extension AnalyticsMetadata {
    struct UserAction: Equatable {
        let id: UUID
        let timestamp: Date
        let actionType: ActionType
        let metadata: [String: String]
        
        init(actionType: ActionType, metadata: [String: String] = [:]) {
            self.id = UUID()
            self.timestamp = Date()
            self.actionType = actionType
            self.metadata = metadata
        }
    }
    
    enum ActionType: String {
        case cravingLogged = "craving_logged"
        case cravingResisted = "craving_resisted"
        case cravingUpdated = "craving_updated"
        case insightViewed = "insight_viewed"
        case patternIdentified = "pattern_identified"
    }
}

// MARK: - Business Rules
extension AnalyticsMetadata {
    var isActive: Bool {
        Date().timeIntervalSince(lastProcessed) < 24 * 3600 // 24 hours
    }
    
    var hasSignificantInteraction: Bool {
        interactionCount >= 5
    }
    
    func validateAction(_ action: UserAction) -> Bool {
        // Add business validation rules here
        return true
    }
}
