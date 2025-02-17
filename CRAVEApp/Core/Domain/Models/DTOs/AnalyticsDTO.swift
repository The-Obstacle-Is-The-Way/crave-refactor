// Core/Domain/Models/DTOs/AnalyticsDTO.swift
import Foundation

public struct AnalyticsDTO {
    public let id: UUID
    public let cravingId: UUID
    public let timestamp: Date
    public let interactionCount: Int
    public let userActions: [AnalyticsMetadata.UserAction]

    public init(
        id: UUID,
        cravingId: UUID,
        timestamp: Date,
        interactionCount: Int,
        userActions: [AnalyticsMetadata.UserAction]
    ) {
        self.id = id
        self.cravingId = cravingId
        self.timestamp = timestamp
        self.interactionCount = interactionCount
        self.userActions = userActions
    }
}

