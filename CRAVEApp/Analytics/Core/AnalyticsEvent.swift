//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsEvent.swift
//  Purpose: Defines the core analytics event system and event processing pipeline
//
//

import Foundation

// Define the base protocol for all analytics events
protocol AnalyticsEvent: Codable {
    var eventType: AnalyticsEventType { get }
    var timestamp: Date { get }
    var priority: EventPriority { get }
}

enum AnalyticsEventType: String, Codable, CaseIterable {
    case cravingLogged = "cravingLogged"
    case interaction = "interaction"
    case system = "system"
    case user = "user"
    case unknown = "unknown"
}

enum EventPriority: String, Codable, CaseIterable {
    case normal
    case critical
}

class BaseAnalyticsEvent: AnalyticsEvent {
    let eventType: AnalyticsEventType
    let timestamp: Date
    var priority: EventPriority = .normal

    init(eventType: AnalyticsEventType, timestamp: Date = Date()) {
        self.eventType = eventType
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case eventType
        case timestamp
        case priority
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventType = try container.decode(AnalyticsEventType.self, forKey: .eventType)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        priority = try container.decodeIfPresent(EventPriority.self, forKey: .priority) ?? .normal
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(priority, forKey: .priority)
    }
}

final class UserEvent: BaseAnalyticsEvent {
    let userId: String

    init(userId: String, timestamp: Date = Date()) {
        self.userId = userId
        super.init(eventType: .user, timestamp: timestamp)
    }
    
    enum UserCodingKeys: String, CodingKey { //Needed a unique coding key
        case userId
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: UserCodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        try super.init(from: decoder) // Call super.init(from:) *after* decoding subclass properties.
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: UserCodingKeys.self)
        try container.encode(userId, forKey: .userId)
    }
}

final class SystemEvent: BaseAnalyticsEvent {
    let systemInfo: String

    init(systemInfo: String, timestamp: Date = Date()) {
        self.systemInfo = systemInfo
        super.init(eventType: .system, timestamp: timestamp)
    }
    
    enum SystemCodingKeys: String, CodingKey { //Needed a unique coding key
        case systemInfo
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SystemCodingKeys.self)
        systemInfo = try values.decode(String.self, forKey: .systemInfo)
        try super.init(from: decoder) // Call super.init(from:) *after* decoding subclass properties.
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: SystemCodingKeys.self)
        try container.encode(systemInfo, forKey: .systemInfo)
    }
}

final class CravingEvent: BaseAnalyticsEvent {
    let cravingId: UUID?
    let cravingText: String
    
    init(cravingId: UUID?, cravingText: String, timestamp: Date = Date()) {
        self.cravingId = cravingId
        self.cravingText = cravingText
        super.init(eventType: .cravingLogged, timestamp: timestamp)
    }
    
    enum CravingCodingKeys: String, CodingKey { //Needed a unique coding key
        case cravingId
        case cravingText
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CravingCodingKeys.self)
        cravingId = try values.decode(UUID?.self, forKey: .cravingId)
        cravingText = try values.decode(String.self, forKey: .cravingText)
        try super.init(from: decoder)  // Call super.init(from:) *after* decoding subclass properties.
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CravingCodingKeys.self)
        try container.encode(cravingId, forKey: .cravingId)
        try container.encode(cravingText, forKey: .cravingText)
    }
}

final class InteractionEvent: BaseAnalyticsEvent {
    let interactionId: UUID
    let cravingId: UUID
    let interactionType: String

    init(interactionId: UUID, cravingId: UUID, interactionType: String, timestamp: Date = Date()) {
        self.interactionId = interactionId
        self.cravingId = cravingId
        self.interactionType = interactionType
        super.init(eventType: .interaction, timestamp: timestamp)
    }
    
    enum InteractionCodingKeys: String, CodingKey { //Needed a unique coding key
        case interactionId
        case cravingId
        case interactionType
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: InteractionCodingKeys.self)
        interactionId = try values.decode(UUID.self, forKey: .interactionId)
        cravingId = try values.decode(UUID.self, forKey: .cravingId)
        interactionType = try values.decode(String.self, forKey: .interactionType)
        try super.init(from: decoder) // Call super.init(from:) *after* decoding subclass properties.
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: InteractionCodingKeys.self)
        try container.encode(interactionId, forKey: .interactionId)
        try container.encode(cravingId, forKey: .cravingId)
        try container.encode(interactionType, forKey: .interactionType)
    }
}

// This struct is not needed for the core analytics events.  It's redundant with BaseAnalyticsEvent
//struct TrackedEvent: Identifiable, Codable {
//    let id: UUID
//    let type: EventType
//    let priority: EventPriority
//    let timestamp: Date
//
//    init(
//        type: EventType,
//        priority: EventPriority = .normal
//    ) {
//        self.id = UUID()
//        self.type = type
//        self.priority = priority
//        self.timestamp = Date()
//    }
//}
//
//enum EventType: String, Codable, CaseIterable {
//    case user
//    case system
//    case craving
//    case interaction
//}
