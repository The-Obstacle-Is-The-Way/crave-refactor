//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsEvent.swift
//  Purpose: Defines the core analytics event system and event processing pipeline
//
//

import Foundation

// Define the base protocol for all analytics events
protocol AnalyticsEvent: Codable { // Explicitly conform to Codable
    var eventType: AnalyticsEventType { get }
    var timestamp: Date { get }
    var priority: EventPriority { get } // Add priority
}

// Make AnalyticsEventType Codable
enum AnalyticsEventType: String, Codable, CaseIterable {
    case cravingCreated = "cravingCreated"
    case systemEvent = "systemEvent"
    case userEvent = "userEvent"
    case interactionEvent = "interactionEvent"
    case unknown = "unknown" // Add a default case for decoding safety
}

enum EventPriority: String, Codable, CaseIterable {
    case normal
    case critical
}


// Base class for analytics events - conforming to Codable
class BaseAnalyticsEvent: AnalyticsEvent { // Correct conformance and class definition
    let eventType: AnalyticsEventType
    let timestamp: Date
    var priority: EventPriority = .normal

    init(eventType: AnalyticsEventType, timestamp: Date = Date()) {
        self.eventType = eventType
        self.timestamp = timestamp
    }

    // Explicitly implement Codable conformance (though synthesized conformance should work for these simple properties)
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

// Example concrete event types - extend BaseAnalyticsEvent
final class UserEvent: BaseAnalyticsEvent {
    let userId: String

    init(userId: String, timestamp: Date = Date()) {
        self.userId = userId
        super.init(eventType: .userEvent, timestamp: timestamp)
    }
    
    enum CodingKeys: String, CodingKey { // No CaseIterable
        case userId
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        try super.init(from: values.superDecoder())
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
    }
}

final class SystemEvent: BaseAnalyticsEvent {
    let systemInfo: String

    init(systemInfo: String, timestamp: Date = Date()) {
        self.systemInfo = systemInfo
        super.init(eventType: .systemEvent, timestamp: timestamp)
    }
    
    enum CodingKeys: String, CodingKey { // No CaseIterable
        case systemInfo
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        systemInfo = try values.decode(String.self, forKey: .systemInfo)
        try super.init(from: values.superDecoder())
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(systemInfo, forKey: .systemInfo)
    }
}

final class CravingEvent: BaseAnalyticsEvent {
    let cravingId: UUID

    init(cravingId: UUID, timestamp: Date = Date()) {
        self.cravingId = cravingId
        super.init(eventType: .cravingCreated, timestamp: timestamp)
    }
    
    enum CodingKeys: String, CodingKey { // No CaseIterable
        case cravingId
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cravingId = try values.decode(UUID.self, forKey: .cravingId)
        try super.init(from: values.superDecoder())
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cravingId, forKey: .cravingId)
    }
}

final class InteractionEvent: BaseAnalyticsEvent {
    let interactionId: UUID

    init(interactionId: UUID, timestamp: Date = Date()) {
        self.interactionId = interactionId
        super.init(eventType: .interactionEvent, timestamp: timestamp)
    }
    
    enum CodingKeys: String, CodingKey { // No CaseIterable
        case interactionId
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        interactionId = try values.decode(UUID.self, forKey: .interactionId)
        try super.init(from: values.superDecoder())
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(interactionId, forKey: .interactionId)
    }
}

// MARK: - Tracked Event
struct TrackedEvent: Identifiable, Codable {
    let id: UUID
    let type: EventType
    //let payload: Any // We'll use a concrete type later
    //let metadata: EventMetadata // We'll use a concrete type later
    let priority: EventPriority
    let timestamp: Date

    init(
        type: EventType,
        //payload: Any,
        //metadata: EventMetadata,
        priority: EventPriority = .normal
    ) {
        self.id = UUID()
        self.type = type
        //self.payload = payload
        //self.metadata = metadata
        self.priority = priority
        self.timestamp = Date()
    }
}

enum EventPriority: String, Codable, CaseIterable {
    case normal
    case critical
}
enum EventType: String, Codable, CaseIterable {
    case user
    case system
    case craving
    case interaction
}
