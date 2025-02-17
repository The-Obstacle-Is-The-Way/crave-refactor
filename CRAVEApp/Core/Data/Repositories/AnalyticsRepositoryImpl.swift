//  CRAVEApp/Core/Data/Repositories/AnalyticsRepositoryImpl.swift

import Foundation
import SwiftData

class AnalyticsRepositoryImpl: AnalyticsRepository {
    private let storage: AnalyticsStorage
    private let mapper: AnalyticsMapper

    init(storage: AnalyticsStorage, mapper: AnalyticsMapper) {
        self.storage = storage
        self.mapper = mapper
    }

    func fetchAnalytics() async throws -> [AnalyticsEntity] {
        let analyticsData = try await storage.fetchMetadata()
        return analyticsData.map { mapper.mapToEntity(from: $0) }
    }
}
