// Core/Data/DataSources/Local/CravingManager.swift
import Foundation
import SwiftData

@MainActor
final class CravingManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchActiveCravings() async throws -> [CravingDTO] {
        let descriptor = FetchDescriptor<CravingDTO>(
            predicate: #Predicate<CravingDTO> { !$0.isArchived },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func insert(_ dto: CravingDTO) throws {
        modelContext.insert(dto)
        try save()
    }

    func archive(_ dto: CravingDTO) throws {
        let descriptor = FetchDescriptor<CravingDTO>(
            predicate: #Predicate<CravingDTO> { $0.id == dto.id }
        )
        if let model = try modelContext.fetch(descriptor).first {
            model.isArchived = true
            try save()
        }
    }

    func delete(_ dto: CravingDTO) throws {
        let descriptor = FetchDescriptor<CravingDTO>(
            predicate: #Predicate<CravingDTO> { $0.id == dto.id }
        )
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try save()
        }
    }

    private func save() throws {
        try modelContext.save()
    }
}

// Core/Data/Mappers/CravingMapper.swift
import Foundation

struct CravingMapper {
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

// Core/Domain/Interfaces/Repositories/CravingRepository.swift
import Foundation

public protocol CravingRepository {
    func fetchAllActiveCravings() async throws -> [CravingEntity]
    func addCraving(_ craving: CravingEntity)
    func archiveCraving(_ craving: CravingEntity)
    func deleteCraving(_ craving: CravingEntity)
}

// Core/Data/Repositories/CravingRepositoryImpl.swift
import Foundation

final class CravingRepositoryImpl: CravingRepository {
    private let cravingManager: CravingManager
    private let mapper: CravingMapper

    init(cravingManager: CravingManager, mapper: CravingMapper) {
        self.cravingManager = cravingManager
        self.mapper = mapper
    }

    func fetchAllActiveCravings() async throws -> [CravingEntity] {
        let dtos = try await cravingManager.fetchActiveCravings()
        return dtos.map(mapper.mapToEntity)
    }

    func addCraving(_ craving: CravingEntity) {
        let dto = mapper.mapToDTO(craving)
        try? cravingManager.insert(dto)
    }

    func archiveCraving(_ craving: CravingEntity) {
        let dto = mapper.mapToDTO(craving)
        try? cravingManager.archive(dto)
    }

    func deleteCraving(_ craving: CravingEntity) {
        let dto = mapper.mapToDTO(craving)
        try? cravingManager.delete(dto)
    }
}
