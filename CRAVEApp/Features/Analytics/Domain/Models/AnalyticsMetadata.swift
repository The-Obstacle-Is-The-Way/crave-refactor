//
//  AnalyticsMetadata.swift
//  CRAVEApp
//
//  Purpose: Stores craving analytics metadata.
//

import Foundation
import SwiftData

@Model
final class AnalyticsMetadata {
    @Attribute(.unique) var id: UUID
    var cravingId: UUID // Foreign Key - Unidirectional Dependency
    var timestamp: Date
    var interactionCount: Int
    var lastProcessed: Date
    @Attribute(.externalStorage)
    var userActions: [UserAction]

    // NO RELATIONSHIP HERE - Unidirectional Dependency

    init(cravingId: UUID) {
        self.id = UUID()
        self.cravingId = cravingId
        self.timestamp = Date()
        self.interactionCount = 0
        self.lastProcessed = Date()
        self.userActions = []
    }

    struct UserAction: Codable {
        let timestamp: Date
        let actionType: String
        let metadata: [String: String]
    }
}
