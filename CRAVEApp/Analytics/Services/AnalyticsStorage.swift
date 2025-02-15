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
    
    func fetchAllEvents() async throws -> [CravingModel] {
        let descriptor = FetchDescriptor<CravingModel>(
            sortBy: [SortDescriptor(\CravingModel.timestamp)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func countEvents(ofType eventType: AnalyticsEventType, in dateInterval: DateInterval) async throws -> Int {
        let descriptor = FetchDescriptor<CravingModel>(
            predicate: #Predicate {
                $0.timestamp >= dateInterval.start && $0.timestamp <= dateInterval.end
            }
        )
        return try modelContext.fetchCount(descriptor)
    }

    func saveContext() throws {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
            throw StorageError.contextSaveFailed(error)
        }
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

enum StorageError: Error {
    case contextSaveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .contextSaveFailed(let error):
            return "Failed to save context: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \(error.localizedDescription)"
        }
    }
}
