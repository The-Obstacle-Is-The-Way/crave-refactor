// Core/Domain/Entities/Analytics/AnalyticsManager.swift
import Foundation

public final class AnalyticsManager {
    private let storage: AnalyticsStorage
    private let aggregator: AnalyticsAggregator
    private let patternDetection: PatternDetectionService

    init( //Removed public
        storage: AnalyticsStorage,
        aggregator: AnalyticsAggregator,
        patternDetection: PatternDetectionService
    ) {
        self.storage = storage
        self.aggregator = aggregator
        self.patternDetection = patternDetection
    }

    public func getBasicStats() async throws -> BasicAnalyticsResult {
        // Fetch events from storage
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate) ?? endDate

        let events = try await storage.fetchEvents(from: startDate, to: endDate)

        // Process events
        var cravingsByDate: [Date: Int] = [:]
        var cravingsByHour: [Int: Int] = [:]
        var cravingsByWeekday: [Int: Int] = [:]
        var triggers: [String: Int] = [:]
        var totalIntensity: Double = 0
        var intensityCount: Int = 0

        for event in events {
            if let userEvent = event as? UserEvent {
                // Process date
                let date = Calendar.current.startOfDay(for: event.timestamp)
                cravingsByDate[date, default: 0] += 1

                // Process hour
                let hour = Calendar.current.component(.hour, from: event.timestamp)
                cravingsByHour[hour, default: 0] += 1

                // Process weekday
                let weekday = Calendar.current.component(.weekday, from: event.timestamp)
                cravingsByWeekday[weekday, default: 0] += 1

                // Process trigger
                if let trigger = userEvent.metadata["trigger"] as? String {
                    triggers[trigger, default: 0] += 1
                }

                // Process intensity
                if let intensity = userEvent.metadata["intensity"] as? Double {
                    totalIntensity += intensity
                    intensityCount += 1
                }
            }
        }

        // Detect patterns
        let patterns = try await patternDetection.detectPatterns()

        // Calculate average intensity
        let averageIntensity = intensityCount > 0 ? totalIntensity / Double(intensityCount) : nil

        // Create time patterns from hour data
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
        // Store the event
        //try await storage.store(event) //Removed

        // Aggregate the event
        //await aggregator.aggregateEvent(event) //Removed
    }

    public func clearOldData(before date: Date) async throws {
       // try await storage.cleanupData(before: date) //Removed
    }
}

