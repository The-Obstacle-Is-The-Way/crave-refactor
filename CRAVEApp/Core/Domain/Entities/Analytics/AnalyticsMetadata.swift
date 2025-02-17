//AnalyticsMetadata.swift

import SwiftData
import Foundation

@Model
public final class AnalyticsMetadata {
    @Attribute(.unique) public var id: UUID
    // Add other properties as needed, ensuring they have appropriate types and attributes
    public var userActions: [UserAction]?  // Use the correct type

    public init(id: UUID, userActions: [UserAction]? = nil) {
        self.id = id
        self.userActions = userActions
    }

    // Define the UserAction struct *within* the AnalyticsMetadata file
    public struct UserAction: Codable {
        public var actionType: String
        public var timestamp: Date
        public var details: String?

        public init(actionType: String, timestamp: Date, details: String? = nil) {
            self.actionType = actionType
            self.timestamp = timestamp
            self.details = details
        }
    }
}

