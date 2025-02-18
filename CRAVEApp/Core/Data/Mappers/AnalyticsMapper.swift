// Core/Data/Mappers/AnalyticsMapper.swift

import Foundation

final class AnalyticsMapper { // Or public
    func mapToEntity(_ dto: AnalyticsDTO) -> any AnalyticsEvent { // Corrected return type
        let metadata = dto.metadata.reduce(into: [String: Any]()) { result, pair in
            //This is a placeholder for more robust type handling.
            result[pair.key] = pair.value
        }

        // Determine the event type and create the appropriate event.
        switch dto.eventType {
        case "interaction":
            return InteractionEvent(id: dto.id, timestamp: dto.timestamp, action: metadata["action"] as? String ?? "", context: metadata["context"] as? String ?? "")
        case "system":
            return SystemEvent(id: dto.id, timestamp: dto.timestamp, category: metadata["category"] as? String ?? "", detail: metadata["detail"] as? String ?? "")
        case "user":
            return UserEvent(id: dto.id, timestamp: dto.timestamp, behavior: metadata["behavior"] as? String ?? "", metadata: metadata)
        default:
            // Handle unknown event types, possibly by throwing an error or returning a default event.
            fatalError("Unknown event type: \(dto.eventType)") // Or return a default event.
        }
    }

    func mapToDTO(_ event: any AnalyticsEvent) -> AnalyticsDTO { // Corrected parameter type.
        //Much simpler mapping
        var stringMetadata: [String: String] = [:]
           if let userEvent = event as? UserEvent {
               for (key, value) in userEvent.metadata {
                   stringMetadata[key] = String(describing: value)
               }
               return AnalyticsDTO(id: userEvent.id, eventType: userEvent.type.rawValue, timestamp: userEvent.timestamp, metadata: stringMetadata)
           } else if let interactionEvent = event as? InteractionEvent {
               stringMetadata["action"] = interactionEvent.action
               stringMetadata["context"] = interactionEvent.context
               return AnalyticsDTO(id: interactionEvent.id, eventType: interactionEvent.type.rawValue, timestamp: interactionEvent.timestamp, metadata: stringMetadata)
           } else if let systemEvent = event as? SystemEvent {
               stringMetadata["category"] = systemEvent.category
               stringMetadata["detail"] = systemEvent.detail
               return AnalyticsDTO(id: systemEvent.id, eventType: systemEvent.type.rawValue, timestamp: systemEvent.timestamp, metadata: stringMetadata)
           } else {
               fatalError("Unknown event type")
           }
    }
}

