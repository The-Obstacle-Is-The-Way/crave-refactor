// Core/Domain/Interfaces/Repositories/CravingRepository.swift
import Foundation

public protocol CravingRepository {
    func fetchAllActiveCravings() async throws -> [CravingEntity]
    func addCraving(_ craving: CravingEntity)
    func archiveCraving(_ craving: CravingEntity)
    func deleteCraving(_ craving: CravingEntity)
}

// Core/Data/Mappers/CravingMapper.swift
import Foundation

internal struct CravingMapper {
    func mapToEntity(_ dto: CravingDTO) -> CravingEntity {
        CravingEntity(
            id: dto.id,
            text: dto.text,
            timestamp: dto.timestamp,
            isArchived: dto.isArchived
        )
    }
    
    func mapToDTO(_ entity: CravingEntity) -> CravingDTO {
        CravingDTO(
            id: entity.id,
            text: entity.text,
            timestamp: entity.timestamp,
            isArchived: entity.isArchived
        )
    }
}
