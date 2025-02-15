//
//  AnalyticsStorage.swift
//  CRAVE
//
//  Created by John H Jung on 2/11/25.
//

import Foundation
import SwiftData

@MainActor
final class AnalyticsStorage {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func store(_ event: any AnalyticsEvent) async throws {
        if let cravingEvent = event as? CravingEvent {
            let metadata = AnalyticsMetadata(cravingId: cravingEvent.cravingId ?? UUID())
            modelContext.insert(metadata)
        }
        try saveContext()
    }

    func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata? {
        let descriptor = FetchDescriptor<AnalyticsMetadata>(
            predicate: #Predicate { $0.cravingId == cravingId }
        )
        return try modelContext.fetch(descriptor).first
    }

    func saveContext() throws {
        try modelContext.save()
    }

    static func preview() -> AnalyticsStorage {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: CravingModel.self,
            AnalyticsMetadata.self,
            configurations: config
        )
        return AnalyticsStorage(modelContext: container.mainContext)
    }
}
