//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsEvent.swift
//  Purpose: Defines the core analytics event system and event processing pipeline
//
//

import Foundation

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
}

final class CravingEvent: BaseAnalyticsEvent {
    let cravingId: UUID?
    let cravingText: String
    
    init(cravingId: UUID?, cravingText: String, timestamp: Date = Date()) {
        self.cravingId = cravingId
        self.cravingText = cravingText
        super.init(eventType: .cravingLogged, timestamp: timestamp)
    }
}

final class UserEvent: BaseAnalyticsEvent {
    let userId: String
    
    init(userId: String, timestamp: Date = Date()) {
        self.userId = userId
        super.init(eventType: .user, timestamp: timestamp)
    }
}

final class SystemEvent: BaseAnalyticsEvent {
    let systemInfo: String
    
    init(systemInfo: String, timestamp: Date = Date()) {
        self.systemInfo = systemInfo
        super.init(eventType: .system, timestamp: timestamp)
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
}

