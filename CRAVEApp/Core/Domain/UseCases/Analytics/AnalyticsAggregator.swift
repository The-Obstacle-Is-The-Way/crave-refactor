// Core/Domain/UseCases/Analytics/AnalyticsAggregator.swift
import Foundation

@MainActor
public final class AnalyticsAggregator {
    private let storage: AnalyticsStorage

    init(storage: AnalyticsStorage) { // Removed 'public'
        self.storage = storage
    }

    public func aggregateEvent(_ event: any AnalyticsEvent) async {
        // Implementation for aggregating events.
        print("event of type: \(event.type) aggregated") //placeholder
    }
}
