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
            eventType: event.type.rawValue,
            timestamp: event.timestamp,
            interactionCount: 1
        )
        try? await storage.store(metadata)
    }
    
    private func processSystemEvent(_ event: SystemEvent) async {
        let metadata = AnalyticsMetadata(
            eventType: event.type.rawValue,
            timestamp: event.timestamp
        )
        try? await storage.store(metadata)
    }
    
    private func processUserEvent(_ event: UserEvent) async {
        let metadata = AnalyticsMetadata(
            eventType: event.type.rawValue,
            timestamp: event.timestamp,
            userActions: [event.behavior]
        )
        try? await storage.store(metadata)
    }
}

