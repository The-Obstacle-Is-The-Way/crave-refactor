//  CRAVEApp/Core/Domain/Models/Entities/AnalyticsEntity.swift

import Foundation

struct AnalyticsEntity {
    let id: UUID
    let cravingId: UUID
    let timestamp: Date
    let interactionCount: Int
    let userActions: [AnalyticsMetadata.UserAction]
}
