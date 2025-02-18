// File: AnalyticsManager.swift
// Description:
// This public class handles analytics-related operations.
// It depends on several components (repository, aggregator, patternDetection).
// To ensure that AnalyticsManager can be used in public APIs (like in AnalyticsDashboardViewModel),
// its initializer must be public so that external modules can create an instance.
// If the initializer remains internal, any public API returning a type that depends on AnalyticsManager
// will expose an internal type, which causes a compiler error.
import Foundation

public final class AnalyticsManager {
    private let repository: AnalyticsRepository  // Public protocol; implementation details are hidden.
    private let aggregator: AnalyticsAggregator    // Must be fully public.
    private let patternDetection: PatternDetectionService  // Must be fully public.

    // PUBLIC INITIALIZER:
    // Marking this initializer as public allows external code (and our DependencyContainer)
    // to create instances of AnalyticsManager. This is required because AnalyticsDashboardViewModel
    // takes an AnalyticsManager in its initializer.
    public init(repository: AnalyticsRepository,
                aggregator: AnalyticsAggregator,
                patternDetection: PatternDetectionService) {
        self.repository = repository
        self.aggregator = aggregator
        self.patternDetection = patternDetection
    }

    public func getBasicStats() async throws -> BasicAnalyticsResult {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate) ?? endDate

        let events = try await repository.fetchEvents(from: startDate, to: endDate)
        var cravingsByDate: [Date: Int] = [:]
        var cravingsByHour: [Int: Int] = [:]
        var cravingsByWeekday: [Int: Int] = [:]
        var triggers: [String: Int] = [:]
        var totalIntensity: Double = 0
        var intensityCount: Int = 0

        for event in events {
            if let userEvent = event as? UserEvent {
                let date = Calendar.current.startOfDay(for: event.timestamp)
                cravingsByDate[date, default: 0] += 1

                let hour = Calendar.current.component(.hour, from: event.timestamp)
                cravingsByHour[hour, default: 0] += 1

                let weekday = Calendar.current.component(.weekday, from: event.timestamp)
                cravingsByWeekday[weekday, default: 0] += 1

                if let trigger = userEvent.metadata["trigger"] as? String {
                    triggers[trigger, default: 0] += 1
                }

                if let intensity = userEvent.metadata["intensity"] as? Double {
                    totalIntensity += intensity
                    intensityCount += 1
                }
            }
        }

        let patterns = try await patternDetection.detectPatterns()
        let averageIntensity = intensityCount > 0 ? totalIntensity / Double(intensityCount) : nil
        let timePatterns = cravingsByHour.compactMap { hour, frequency -> BasicAnalyticsResult.TimePattern? in
            let confidence = Double(frequency) / Double(events.count)
            return BasicAnalyticsResult.TimePattern(
                hour: hour,
                frequency: frequency,
                confidence: confidence
            )
        }

        return BasicAnalyticsResult(
            totalCravings: events.count,
            totalResisted: events.filter { ($0 as? UserEvent)?.metadata["resisted"] as? Bool == true }.count,
            averageIntensity: averageIntensity,
            cravingsByDate: cravingsByDate,
            cravingsByHour: cravingsByHour,
            cravingsByWeekday: cravingsByWeekday,
            commonTriggers: triggers,
            timePatterns: timePatterns,
            detectedPatterns: patterns
        )
    }

    public func trackEvent(_ event: AnalyticsEvent) async throws {
        try await repository.storeEvent(event)
        await aggregator.aggregateEvent(event)
    }

    public func clearOldData(before date: Date) async throws {
        try await repository.cleanupOldData(before: date)
    }
}
