// Core/Domain/Entities/Analytics/AnalyticsManager.swift
import Foundation

public final class AnalyticsManager {
    private let repository: AnalyticsRepository // Use the REPOSITORY
    private let aggregator: AnalyticsAggregator
    private let patternDetection: PatternDetectionService

    // Inject the repository, aggregator, and patternDetection
    init(repository: AnalyticsRepository, aggregator: AnalyticsAggregator, patternDetection: PatternDetectionService) {
        self.repository = repository
        self.aggregator = aggregator
        self.patternDetection = patternDetection
    }

    public func getBasicStats() async throws -> BasicAnalyticsResult {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate) ?? endDate

        // Use the REPOSITORY to fetch events.  This will return [AnalyticsEvent]
        let events = try await repository.fetchEvents(from: startDate, to: endDate)

        // --- The rest of this method remains the same ---
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
        try await repository.storeEvent(event) // Use repository
        await aggregator.aggregateEvent(event)  // Aggregate
    }

    public func clearOldData(before date: Date) async throws {
        try await repository.cleanupOldData(before: date) // Use repository
    }
}

