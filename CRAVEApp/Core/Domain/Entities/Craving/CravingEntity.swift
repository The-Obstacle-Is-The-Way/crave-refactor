// Core/Domain/Entities/CravingEntity.swift
import Foundation

public struct CravingEntity: Identifiable {
    public let id: UUID
    public let name: String
    public let timestamp: Date

    public init(id: UUID = UUID(), name: String, timestamp: Date = Date()) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
    }
}

