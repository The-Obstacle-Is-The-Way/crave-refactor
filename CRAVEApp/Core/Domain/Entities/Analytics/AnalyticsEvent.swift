// Core/Domain/Entities/Analytics/AnalyticsEvent.swift
import Foundation

public protocol AnalyticsEvent {
    var id: UUID { get }
    var timestamp: Date { get }
    var type: EventType { get }
}

public enum EventType: String, Codable { //Conform to codable
    case interaction
    case system
    case user
}

public struct InteractionEvent: AnalyticsEvent {
    public let id: UUID
    public let timestamp: Date
    public let type: EventType = .interaction
    public let action: String
    public let context: String

    public init(id: UUID = UUID(), timestamp: Date = Date(), action: String, context: String) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.context = context
    }
}

public struct SystemEvent: AnalyticsEvent {
    public let id: UUID
    public let timestamp: Date
    public let type: EventType = .system
    public let category: String
    public let detail: String

    public init(id: UUID = UUID(), timestamp: Date = Date(), category: String, detail: String) {
        self.id = id
        self.timestamp = timestamp
        self.category = category
        self.detail = detail
    }
}


public struct UserEvent: AnalyticsEvent {
    public let id: UUID
    public let timestamp: Date
    public let type: EventType = .user
    public let behavior: String
    public let metadata: [String: Any]

    public init(id: UUID = UUID(), timestamp: Date = Date(), behavior: String, metadata: [String: Any] = [:]) {
        self.id = id
        self.timestamp = timestamp
        self.behavior = behavior
        self.metadata = metadata
    }
}

