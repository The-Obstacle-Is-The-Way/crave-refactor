// Core/Data/Repositories/CravingRepositoryImpl.swift
import Foundation

internal final class CravingRepositoryImpl: CravingRepository {
    private let cravingManager: CravingManager
    private let mapper: CravingMapper

    internal init(cravingManager: CravingManager, mapper: CravingMapper) {
        self.cravingManager = cravingManager
        self.mapper = mapper
    }

    public func fetchAllActiveCravings() async throws -> [CravingEntity] {
        let dtos = try await cravingManager.fetchActiveCravings()
        return dtos.map(mapper.mapToEntity)
    }

    public func addCraving(_ craving: CravingEntity) {
        let dto = mapper.mapToDTO(craving)
        try? cravingManager.insert(dto)
    }

    public func archiveCraving(_ craving: CravingEntity) {
        let dto = mapper.mapToDTO(craving)
        try? cravingManager.archive(dto)
    }

    public func deleteCraving(_ craving: CravingEntity) {
        let dto = mapper.mapToDTO(craving)
        try? cravingManager.delete(dto)
    }
}

