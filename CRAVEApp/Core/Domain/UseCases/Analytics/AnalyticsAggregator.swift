// Core/Domain/UseCases/Analytics/AnalyticsAggregator.swift
import Foundation
import SwiftData

@MainActor
public final class AnalyticsAggregator {
    private let storage: AnalyticsStorage
    
    public init(storage: AnalyticsStorage) {
        self.storage = storage
    }
    
    public func aggregateEvent(_ event: any AnalyticsEvent) async {
        switch event.type {
        case .interaction:
            if let interactionEvent = event as? InteractionEvent {
                await processInteractionEvent(interactionEvent)
            }
        case .system:
            if let systemEvent = event as? SystemEvent {
                await processSystemEvent(systemEvent)
            }
        case .user:
            if let userEvent = event as? UserEvent {
                await processUserEvent(userEvent)
            }
        }
    }
    
    private func processInteractionEvent(_ event: InteractionEvent) async {
        let metadata = AnalyticsMetadata(
            id: UUID(),
            userActions: [
                AnalyticsMetadata.UserAction(
                    actionType: event.action,
                    timestamp: event.timestamp,
                    details: event.context
                )
            ]
        )
        try? await storage.store(event)
    }
    
    private func processSystemEvent(_ event: SystemEvent) async {
        let metadata = AnalyticsMetadata(
            id: UUID(),
            userActions: [
                AnalyticsMetadata.UserAction(
                    actionType: "system_\(event.category)",
                    timestamp: event.timestamp,
                    details: event.detail
                )
            ]
        )
        try? await storage.store(event)
    }
    
    private func processUserEvent(_ event: UserEvent) async {
        let metadata = AnalyticsMetadata(
            id: UUID(),
            userActions: [
                AnalyticsMetadata.UserAction(
                    actionType: event.behavior,
                    timestamp: event.timestamp,
                    details: event.metadata.description
                )
            ]
        )
        try? await storage.store(event)
    }
}
