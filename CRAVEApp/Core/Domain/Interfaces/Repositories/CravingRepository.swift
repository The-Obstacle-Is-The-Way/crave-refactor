// Core/Domain/Repositories/CravingRepository.swift
import Foundation

public protocol CravingRepository {
    func fetchAllActiveCravings() async throws -> [CravingEntity]
    func addCraving(_ craving: CravingEntity)
    func archiveCraving(_ craving: CravingEntity)
    func deleteCraving(_ craving: CravingEntity)
}

