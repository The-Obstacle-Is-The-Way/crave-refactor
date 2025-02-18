// File: AnalyticsAggregator.swift
// Description:
// This public class aggregates analytics events.
// It depends on AnalyticsStorageProtocol so that internal storage details are hidden.
// A placeholder implementation is provided so that the app runs even if the full API is not yet active.

import Foundation

@MainActor
public final class AnalyticsAggregator {
    // Dependency on storage via the public protocol.
    private let storage: AnalyticsStorageProtocol

    // Public initializer accepts any instance conforming to AnalyticsStorageProtocol.
    public init(storage: AnalyticsStorageProtocol) {
        self.storage = storage
    }

    // Aggregates a given analytics event.
    // Placeholder: replace this with your real aggregation logic as needed.
    public func aggregateEvent(_ event: any AnalyticsEvent) async {
        print("event of type: \(event.type) aggregated")
    }
}
