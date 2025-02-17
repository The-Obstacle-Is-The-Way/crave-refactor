// Core/Domain/Entities/Craving/CravingEntity.swift
import Foundation

public struct CravingEntity: Identifiable {
    public let id: UUID
    public let text: String
    public let timestamp: Date
    public let isArchived: Bool
    
    public init(id: UUID = UUID(), text: String, timestamp: Date = Date(), isArchived: Bool = false) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.isArchived = isArchived
    }
}
