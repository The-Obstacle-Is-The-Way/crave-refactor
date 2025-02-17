// Core/Domain/Entities/Craving/CravingEvent.swift
import Foundation

public struct CravingEvent: AnalyticsEvent {
    public let id: UUID
    public let timestamp: Date
    public let type: EventType = .interaction
    public let cravingEntity: CravingEntity
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), cravingEntity: CravingEntity) {
        self.id = id
        self.timestamp = timestamp
        self.cravingEntity = cravingEntity
    }
}
