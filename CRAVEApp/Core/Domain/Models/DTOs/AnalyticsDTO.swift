// Core/Domain/Models/DTOs/AnalyticsDTO.swift

import Foundation

struct AnalyticsDTO {
    let id: UUID
    let cravingId: UUID
    let timestamp: Date
    let interactionCount: Int
    let userActions: [AnalyticsMetadata.UserAction]
}
