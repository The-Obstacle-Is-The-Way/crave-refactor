//  CRAVEApp/Core/Data/Mappers/CravingMapper.swift

import Foundation

struct CravingMapper {

    func mapToEntity(from dto: CravingDTO) -> CravingEntity {
        CravingEntity(
            id: dto.id,
            text: dto.text,
            timestamp: dto.timestamp,
            isArchived: dto.isArchived
        )
    }

    func mapToDTO(from entity: CravingEntity) -> CravingDTO {
        CravingDTO(
            id: entity.id,
            text: entity.text,
            timestamp: entity.timestamp,
            isArchived: entity.isArchived
        )
    }
}
