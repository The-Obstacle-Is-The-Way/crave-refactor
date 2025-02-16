//
//
//  🍒
//  CRAVEApp/Data/Entities/AnalyticsMetadata.swift
//  Purpose:
//
//

import Foundation
import SwiftData

@Model
final class AnalyticsMetadata {
    @Attribute(.unique) var id: UUID
    var cravingId: UUID
    var timestamp: Date
    var interactionCount: Int
    var lastProcessed: Date

    @Attribute(.externalStorage)
    var userActions: [UserAction]

    // Must point back to CravingModel — not AnalyticsMetadata
    @Relationship(deleteRule: .cascade, inverse: \CravingModel.analyticsMetadata)
    var craving: CravingModel?

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
