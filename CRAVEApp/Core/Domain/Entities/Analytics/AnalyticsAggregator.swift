import Foundation
import SwiftData

@MainActor
public final class AnalyticsAggregator {
    private let storage: AnalyticsStorage

    public init(storage: AnalyticsStorage) {
        self.storage = storage
    }

    public func aggregateEvent(_ event: AnalyticsEvent) async {
        switch event.eventType {
        case .cravingLogged:
            await aggregateCravingEvent(event)
        case .interaction:
            if let interactionEvent = event as? InteractionEvent {
                await aggregateInteractionEvent(interactionEvent)
            }
        case .system:
            if let systemEvent = event as? SystemEvent {
                await aggregateSystemEvent(systemEvent)
            }
        case .user:
            if let userEvent = event as? UserEvent {
                await aggregateUserEvent(userEvent)
            }
        case .unknown:
            print("Unknown event type received")
        }

        if let cravingEvent = event as? CravingEvent {
            await updateCravingAnalytics(cravingEvent)
        }
    }

    private func aggregateCravingEvent(_ event: AnalyticsEvent) async {
        guard let cravingEvent = event as? CravingEvent else {
            print("Incorrect event type")
            return
        }
        print("Aggregating craving event: \(cravingEvent.eventType)")
    }

    private func aggregateInteractionEvent(_ event: InteractionEvent) async {
        print("Aggregating interaction event: \(event.eventType)")
    }

    private func aggregateSystemEvent(_ event: SystemEvent) async {
        print("Aggregating system event: \(event.eventType)")
    }

    private func aggregateUserEvent(_ event: UserEvent) async {
        print("Aggregating user event: \(event.eventType)")
    }

    private func updateCravingAnalytics(_ cravingEvent: CravingEvent) async {
        let cravingId = cravingEvent.cravingId
        do {
            var metadata = try storage.fetchMetadata(forCravingId: cravingId) ?? createNewMetadata(for: cravingId)
            metadata.interactionCount += 1
            metadata.lastProcessed = Date()
            
            let action = AnalyticsMetadata.UserAction(
                timestamp: Date(),
                actionType: .cravingLogged,
                metadata: ["text": cravingEvent.cravingText]
            )
            metadata.userActions.append(action)
            
            try storage.modelContext.save()
        } catch {
            print("Error updating metadata: \(error)")
        }
    }

    private func createNewMetadata(for cravingId: UUID) -> AnalyticsMetadata {
        let metadata = AnalyticsMetadata(cravingId: cravingId)
        storage.modelContext.insert(metadata)
        return metadata
    }
}

public extension AnalyticsAggregator {
    func processEventBatch(_ events: [AnalyticsEvent]) async {
        for event in events {
            await aggregateEvent(event)
        }
    }
    
    func processHistoricalData(_ startDate: Date, _ endDate: Date) async {
        print("Processing historical data from \(startDate) to \(endDate)")
    }
    
    static func preview(storage: AnalyticsStorage) -> AnalyticsAggregator {
        return AnalyticsAggregator(storage: storage)
    }
}

