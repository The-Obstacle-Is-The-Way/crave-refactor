// File: AnalyticsDTO.swift
// Description:
// This public model represents the Data Transfer Object (DTO) for analytics events.
// SwiftData requires that all persisted properties conform to Codable (or be a known persistable type).
// Since [String: Any] is not Codable, we store metadata as a JSON string (which is Codable)
// and provide a computed property to convert between the JSON string and a [String: Any] dictionary.
// This approach allows us to keep the flexibility of arbitrary metadata while satisfying SwiftData's requirements.

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
    // The metadata is stored as a JSON string because SwiftData needs a concrete, persistable type.
    public var metadataJSON: String

    // Public initializer.
    // When initializing, you provide the JSON representation of your metadata.
    // You can use the computed property 'metadata' to work with a [String: Any] dictionary instead.
    public init(id: UUID, eventType: String, timestamp: Date, metadataJSON: String) {
        self.id = id
        self.eventType = eventType
        self.timestamp = timestamp
        self.metadataJSON = metadataJSON
    }

    // Computed property to get and set metadata as a [String: Any] dictionary.
    // This allows you to work with a dictionary in your application logic,
    // while the underlying stored property remains a JSON string.
    public var metadata: [String: Any]? {
        get {
            // Convert the JSON string to Data.
            guard let data = metadataJSON.data(using: .utf8) else { return nil }
            // Try to decode the data into a dictionary.
            return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
        }
        set {
            // Attempt to convert the new dictionary into JSON data.
            if let newValue = newValue,
               let data = try? JSONSerialization.data(withJSONObject: newValue, options: []),
               let jsonString = String(data: data, encoding: .utf8) {
                metadataJSON = jsonString
            } else {
                // If conversion fails, default to an empty JSON object.
                metadataJSON = "{}"
            }
        }
    }
}
