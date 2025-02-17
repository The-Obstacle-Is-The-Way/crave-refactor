// Core/Data/DTOs/AnalyticsDTO.swift
import Foundation
import SwiftData

@Model
final class AnalyticsDTO {
    var id: UUID
    var eventType: String
    var timestamp: Date
    var metadata: [String: String] // Note: SwiftData can't store [String: Any] directly
    
    init(id: UUID = UUID(), eventType: String, timestamp: Date = Date(), metadata: [String: String] = [:]) {
        self.id = id
        self.eventType = eventType
        self.timestamp = timestamp
        self.metadata = metadata
    }
}
