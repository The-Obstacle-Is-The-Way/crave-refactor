// ModelContainer.swift

import SwiftData

@MainActor
class ModelContainer {
    static let shared = ModelContainer()
    private var context: ModelContext
    
    private init() {
        let schema = Schema([CravingEntity.self])
        let configuration = ModelConfiguration(schema: schema)
        self.context = ModelContext(configuration: configuration)
    }

    func fetchCravings() async throws -> [CravingEntity] {
        return try await context.fetch(FetchRequest<CravingEntity>())
    }
}
