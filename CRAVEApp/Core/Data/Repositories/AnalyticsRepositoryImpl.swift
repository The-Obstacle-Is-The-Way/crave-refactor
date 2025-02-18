// Core/Data/Repositories/AnalyticsRepositoryImpl.swift
import Foundation
import SwiftData

public final class AnalyticsRepositoryImpl: AnalyticsRepository {
    private let storage: AnalyticsStorage
    private let mapper: AnalyticsMapper

    public init(storage: AnalyticsStorage, mapper: AnalyticsMapper) {
        self.storage = storage
        self.mapper = mapper
    }

     public func storeEvent(_ event: AnalyticsEvent) async throws {
        do {
            let dto = mapper.mapToDTO(event as! AnalyticsEntity) //map event to dto
            try await storage.store(dto)  //store dto
        } catch {
            throw AnalyticsRepositoryError.storageError(error.localizedDescription)
        }
    }

    public func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [AnalyticsEvent] {
        do {
            let dtos = try await storage.fetchEvents(from: startDate, to: endDate)
            return dtos.map { mapper.mapToEntity($0) } //map dtos back to events
        } catch {
            throw AnalyticsRepositoryError.fetchError(error.localizedDescription)
        }
    }

    public func fetchEvents(ofType eventType: EventType) async throws -> [AnalyticsEvent] {
        do {
            let dtos = try await storage.fetchEvents(ofType: eventType.rawValue)
            return dtos.map { mapper.mapToEntity($0) }  //map dtos back to events
        } catch {
            throw AnalyticsRepositoryError.fetchError(error.localizedDescription)
        }
    }
    
    public func fetchMetadata(forCravingId cravingId: UUID) async throws -> AnalyticsMetadata? {
        do{
           return try await storage.fetchMetadata(forCravingId: cravingId)
        } catch {
            throw AnalyticsRepositoryError.fetchError(error.localizedDescription)
        }
    }
    
    public func updateMetadata(_ metadata: AnalyticsMetadata) async throws {
        do {
            try await storage.update(metadata: metadata)
        } catch {
            throw AnalyticsRepositoryError.storageError(error.localizedDescription)
        }
    }
    
    public func fetchAnalytics(from startDate: Date, to endDate: Date) async throws -> BasicAnalyticsResult {
        do {
            let events = try await fetchEvents(from: startDate, to: endDate)
            guard !events.isEmpty else { throw AnalyticsRepositoryError.noDataAvailable }
            return try await aggregateAnalytics(events: events) // Pass only events
        } catch {
            throw AnalyticsRepositoryError.fetchError(error.localizedDescription)
        }
    }

    public func fetchPatterns() async throws -> [BasicAnalyticsResult.DetectedPattern] {
           return []  // Implement pattern detection logic -  should not be empty
       }

    public func storeBatch(_ events: [AnalyticsEvent]) async throws {
        do {
            let dtos = events.map { mapper.mapToDTO($0 as! AnalyticsEntity) } //map events to dtos
            try await storage.storeBatch(dtos) //store dtos
        } catch {
            throw AnalyticsRepositoryError.batchProcessingFailed
        }
    }

    public func cleanupOldData(before date: Date) async throws {
        do {
            try await storage.cleanupData(before: date)
        } catch {
            throw AnalyticsRepositoryError.storageError(error.localizedDescription)
        }
    }

    // MARK: - Private Helpers

    private func aggregateAnalytics(events: [AnalyticsEvent]) async throws -> BasicAnalyticsResult { //removed patterns
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

        let averageIntensity = intensityCount > 0 ? totalIntensity / Double(intensityCount) : nil
        let timePatterns = cravingsByHour.map { hour, frequency in
            BasicAnalyticsResult.TimePattern(
                hour: hour,
                frequency: frequency,
                confidence: Double(frequency) / Double(max(events.count, 1))
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
            detectedPatterns: [] //removed patterns from here too
        )
    }
}

