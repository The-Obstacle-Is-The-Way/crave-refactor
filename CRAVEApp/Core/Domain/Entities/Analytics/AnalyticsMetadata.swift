import Foundation

public struct AnalyticsMetadata {
    public let id: UUID
    public let cravingId: UUID
    public let createdAt: Date

    public private(set) var interactionCount: Int
    public private(set) var lastProcessed: Date
    public private(set) var userActions: [UserAction]

    public init(cravingId: UUID) {
        self.id = UUID()
        self.cravingId = cravingId
        self.createdAt = Date()
        self.interactionCount = 0
        self.lastProcessed = Date()
        self.userActions = []
    }

    public mutating func incrementInteractions() {
        interactionCount += 1
        lastProcessed = Date()
    }

    public mutating func addUserAction(_ action: UserAction) {
        userActions.append(action)
        incrementInteractions()
    }
}

public extension AnalyticsMetadata {
    struct UserAction: Codable, Equatable {
        public let id: UUID
        public let timestamp: Date
        public let actionType: ActionType
        public let metadata: [String: String]

        public init(timestamp: Date = .now, actionType: ActionType, metadata: [String: String] = [:]) {
            self.id = UUID()
            self.timestamp = timestamp
            self.actionType = actionType
            self.metadata = metadata
        }
    }

    enum ActionType: String, Codable {
        case cravingLogged = "craving_logged"
        case cravingResisted = "craving_resisted"
        case cravingUpdated = "craving_updated"
        case insightViewed = "insight_viewed"
        case patternIdentified = "pattern_identified"
    }
}

