// File: AnalyticsDTO.swift
// Description:
// This public model represents the Data Transfer Object (DTO) for analytics events.
// By annotating it with @Model, it conforms to PersistentModel and can be used with SwiftData methods (like insert, fetch, etc.).
// NOTE: Ensure that all properties are of types that SwiftData can persist. In some cases, types like [String: Any] might require custom handling.
import SwiftData
import Foundation

@Model
public final class AnalyticsDTO {
    // Unique identifier for the event.
    public var id: UUID
    // The type of the event as a string.
    public var eventType: String
    // The timestamp when the event occurred.
    public var timestamp: Date
    // Additional metadata associated with the event.
    public var metadata: [String: Any]

    // Public initializer.
    public init(id: UUID, eventType: String, timestamp: Date, metadata: [String: Any]) {
        self.id = id
        self.eventType = eventType
        self.timestamp = timestamp
        self.metadata = metadata
    }
}
