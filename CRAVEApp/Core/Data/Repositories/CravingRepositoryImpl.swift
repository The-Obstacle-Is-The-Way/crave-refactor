// Core/Data/Repositories/CravingRepositoryImpl.swift
import Foundation
import SwiftData

@MainActor
internal final class CravingRepositoryImpl: CravingRepository {
    private let cravingManager: CravingManager
    
    internal init(cravingManager: CravingManager) {
        self.cravingManager = cravingManager
    }
    
    public func fetchAllActiveCravings() async throws -> [CravingEntity] {
        try await cravingManager.fetchActiveCravings()
    }
    
    public func addCraving(_ craving: CravingEntity) async throws {
        try await cravingManager.insert(craving)
    }
    
    public func archiveCraving(_ craving: CravingEntity) async throws {
        try await cravingManager.archive(craving)
    }
    
    public func deleteCraving(_ craving: CravingEntity) async throws {
        try await cravingManager.delete(craving)
    }
}
