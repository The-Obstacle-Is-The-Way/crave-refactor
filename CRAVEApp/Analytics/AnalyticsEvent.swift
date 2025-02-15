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
}

// Make AnalyticsEventType Codable
enum AnalyticsEventType: String, Codable {
    case cravingCreated = "cravingCreated"
    case systemEvent = "systemEvent"
    case userEvent = "userEvent"
    case interactionEvent = "interactionEvent"
    case unknown = "unknown" // Add a default case for decoding safety
}


// Base class for analytics events - conforming to Codable
class BaseAnalyticsEvent: AnalyticsEvent { // Correct conformance and class definition
    let eventType: AnalyticsEventType
    let timestamp: Date

    init(eventType: AnalyticsEventType, timestamp: Date = Date()) {
        self.eventType = eventType
        self.timestamp = timestamp
    }

    // Explicitly implement Codable conformance (though synthesized conformance should work for these simple properties)
    enum CodingKeys: String, CodingKey {
        case eventType
        case timestamp
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventType = try container.decode(AnalyticsEventType.self, forKey: .eventType)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        super.init() // Call to super.init needed if inheriting from NSObject directly, but not needed here as NSObject is not inherited directly
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

// Example concrete event types - extend BaseAnalyticsEvent
final class UserEvent: BaseAnalyticsEvent {
    let userId: String

    init(userId: String, timestamp: Date = Date()) {
        self.userId = userId
        super.init(eventType: .userEvent, timestamp: timestamp)
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case userId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseAnalyticsEvent.CodingKeys.self).superDecoder()
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try keyedContainer.decode(String.self, forKey: .userId)
        try super.init(from: decoder)
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
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case systemInfo
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseAnalyticsEvent.CodingKeys.self).superDecoder()
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.systemInfo = try keyedContainer.decode(String.self, forKey: .systemInfo)
        try super.init(from: decoder)
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
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case cravingId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseAnalyticsEvent.CodingKeys.self).superDecoder()
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.cravingId = try keyedContainer.decode(UUID.self, forKey: .cravingId)
        try super.init(from: decoder)
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
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case interactionId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseAnalyticsEvent.CodingKeys.self).superDecoder()
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.interactionId = try keyedContainer.decode(UUID.self, forKey: .interactionId)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(interactionId, forKey: .interactionId)
    }
}
