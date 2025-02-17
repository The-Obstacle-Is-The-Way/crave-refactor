//  CRAVEApp/Core/Data/Mappers/AnalyticsMapper.swift

import Foundation

struct AnalyticsMapper {

    func mapToEntity(from dto: AnalyticsDTO) -> AnalyticsEntity {
        AnalyticsEntity(
            id: dto.id,
            cravingId: dto.cravingId,
            timestamp: dto.timestamp,
            interactionCount: dto.interactionCount,
            userActions: dto.userActions
        )
    }

    func mapToDTO(from entity: AnalyticsEntity) -> AnalyticsDTO {
        AnalyticsDTO(
            id: entity.id,
            cravingId: entity.cravingId,
            timestamp: entity.timestamp,
            interactionCount: entity.interactionCount,
            userActions: entity.userActions
        )
    }
}
