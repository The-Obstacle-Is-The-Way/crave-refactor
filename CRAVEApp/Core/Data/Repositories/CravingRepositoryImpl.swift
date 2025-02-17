//  CRAVEApp/Core/Data/Repositories/CravingRepositoryImpl.swift

import Foundation
import SwiftData

class CravingRepositoryImpl: CravingRepository {
    private let cravingManager: CravingManager
    private let mapper: CravingMapper

    init(cravingManager: CravingManager, mapper: CravingMapper) {
        self.cravingManager = cravingManager
        self.mapper = mapper
    }

    func fetchAllActiveCravings() async throws -> [CravingEntity] {
        let activeCravings = await cravingManager.fetchAllActiveCravings()
        return activeCravings.map { mapper.mapToEntity(from: $0) }
    }

    func addCraving(_ craving: CravingEntity) {
        cravingManager.insert(craving)
    }

    func archiveCraving(_ craving: CravingEntity) {
        cravingManager.archiveCraving(craving)
    }

    func deleteCraving(_ craving: CravingEntity) {
        cravingManager.deleteCraving(craving)
    }
}
