// Core/Domain/UseCases/Analytics/AnalyticsProcessor.swift
import Foundation

@MainActor
public final class AnalyticsProcessor {
    private let configuration: AnalyticsConfiguration
    private let storage: AnalyticsStorage

    init(configuration: AnalyticsConfiguration, storage: AnalyticsStorage) { // Removed 'public'
        self.configuration = configuration
        self.storage = storage
    }

    public func processEvent(_ event: any AnalyticsEvent) async {
        do {
            switch event.type {
            case .interaction:
                try await processInteractionEvent(event)
            case .system:
                try await processSystemEvent(event)
            case .user:
                try await processUserEvent(event)
            }
        } catch {
            print("Error processing event: \(error)")
        }
    }

    private func processInteractionEvent(_ event: any AnalyticsEvent) async throws {
        // Implementation here
    }

    private func processSystemEvent(_ event: any AnalyticsEvent) async throws {
        // Implementation here
    }

    private func processUserEvent(_ event: any AnalyticsEvent) async throws {
        // Implementation here
    }
}

