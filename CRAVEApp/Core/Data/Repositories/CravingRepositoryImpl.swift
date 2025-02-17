import Foundation

public final class CravingRepositoryImpl: CravingRepository {
    private let cravingManager: CravingManager
    private let mapper: CravingMapper

    public init(cravingManager: CravingManager, mapper: CravingMapper) {
        self.cravingManager = cravingManager
        self.mapper = mapper
    }

    public func fetchAllActiveCravings() async throws -> [CravingEntity] {
        return try await cravingManager.fetchActiveCravings()
    }

    public func addCraving(_ craving: CravingEntity) {
        cravingManager.add(craving: craving)
    }

    public func archiveCraving(_ craving: CravingEntity) {
        cravingManager.archive(craving: craving)
    }

    public func deleteCraving(_ craving: CravingEntity) {
        cravingManager.delete(craving: craving)
    }
}

