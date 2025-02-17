// Core/Domain/Entities/Analytics/AnalyticsMetadata.swift
import Foundation
import SwiftData

@Model
public final class AnalyticsMetadata {
    public var id: UUID
    public var eventType: String
    public var timestamp: Date
    public var interactionCount: Int
    public var lastProcessed: Date?
    public var userActions: [String]
    
    public init(
        id: UUID = UUID(),
        eventType: String,
        timestamp: Date = Date(),
        interactionCount: Int = 0,
        lastProcessed: Date? = nil,
        userActions: [String] = []
    ) {
        self.id = id
        self.eventType = eventType
        self.timestamp = timestamp
        self.interactionCount = interactionCount
        self.lastProcessed = lastProcessed
        self.userActions = userActions
    }
}
