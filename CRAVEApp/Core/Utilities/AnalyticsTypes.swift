// Core/Domain/Models/AnalyticsTypes.swift

import Foundation

// MARK: - Analytics Metadata
public struct AnalyticsMetadata: Codable, Identifiable {
    public let id = UUID()
    public var cravingId: UUID
    public var interactionCount: Int = 0
    public var lastProcessed: Date? = nil
    public var userActions: [UserAction] = []
    
    public struct UserAction: Codable {
        public let timestamp: Date
        public let actionType: String
        public let metadata: [String: String]
    }
    
    public init(cravingId: UUID) {
        self.cravingId = cravingId
    }
}

