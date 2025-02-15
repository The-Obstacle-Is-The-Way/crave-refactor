//
//  🍒
//  CRAVEApp/Analytics/AnalyticsCoordinator.swift
//  Purpose: Coordinates and orchestrates all analytics operations across the app
//
//

import Foundation
import SwiftData

@MainActor
final class AnalyticsProcessor {
    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage

    init(configuration: AnalyticsConfiguration, storage: AnalyticsStorage) {
        self.configuration = configuration
        self.storage = storage
    }

    func processEvent(_ event: AnalyticsEvent) async {
        switch event.eventType {
        case .cravingLogged:
            await processCravingEvent(event)
        case .interaction:
            await processInteractionEvent(event)
        case .system:
            await processSystemEvent(event)
        case .user:
            await processUserEvent(event)
        case .unknown:
            print("Unknown event type received")
        }
    }

    private func processCravingEvent(_ event: AnalyticsEvent) async {
        guard let cravingEvent = event as? CravingEvent else { return }
        print("Processing craving event: \(cravingEvent.cravingText)")
    }

    private func processInteractionEvent(_ event: AnalyticsEvent) async {
        print("Processing interaction event")
    }

    private func processSystemEvent(_ event: AnalyticsEvent) async {
        print("Processing system event")
    }

    private func processUserEvent(_ event: AnalyticsEvent) async {
        print("Processing user event")
    }
}
