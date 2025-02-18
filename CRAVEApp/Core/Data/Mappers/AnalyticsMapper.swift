// Core/Data/Mappers/AnalyticsMapper.swift

import Foundation

final class AnalyticsMapper { // Or public
    func mapToEntity(_ dto: AnalyticsDTO) -> AnalyticsEntity {
        let metadata = dto.metadata.reduce(into: [String: Any]()) { result, pair in
            result[pair.key] = pair.value
        }
        
        return AnalyticsEntity(
            id: dto.id,
            eventType: dto.eventType,
            timestamp: dto.timestamp,
            metadata: metadata
        )
    }
    
    func mapToDTO(_ entity: AnalyticsEntity) -> AnalyticsDTO {
        let stringMetadata = entity.metadata.reduce(into: [String: String]()) { result, pair in
            result[pair.key] = String(describing: pair.value)
        }
        
        return AnalyticsDTO(
            id: entity.id,
            eventType: entity.eventType,
            timestamp: entity.timestamp,
            metadata: stringMetadata
        )
    }
}

