// CravingRepository.swift

import Foundation

public protocol CravingRepository {
    func fetchAllActiveCravings() async throws -> [CravingEntity]
    func saveCraving(_ craving: CravingEntity) async throws
    func deleteCraving(_ craving: CravingEntity) async throws
}
