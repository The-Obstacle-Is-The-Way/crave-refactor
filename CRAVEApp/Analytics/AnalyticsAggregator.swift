//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsAggregator.swift
//  Purpose: 
//
//

import Foundation
import Combine
import SwiftData // Make sure to import SwiftData

@MainActor
class AnalyticsAggregator: ObservableObject {

    @Published private(set) var dailyAggregates: [Date: DailyAnalytics] = [:]
    @Published private(set) var weeklyAggregates: [Int: WeeklyAnalytics] = [:]
    @Published private(set) var monthlyAggregates: [Int: MonthlyAnalytics] = [:]

    private var analyticsStorage: AnalyticsStorage // ✅ No longer ambiguous with proper import
    private var cancellables = Set<AnyCancellable>()

    init(analyticsStorage: AnalyticsStorage) {
        self.analyticsStorage = analyticsStorage
        setupObservers()
    }

    private func setupObservers() {
        analyticsStorage.eventPublisher
            .sink(completion: { completion in // ✅ Explicit type annotation
                switch completion {
                case .failure(let error):
                    print("Error receiving analytics event: \(error)")
                case .finished:
                    print("Analytics event stream finished")
                }
            }, receiveValue: { [weak self] event in // ✅ Explicit type annotation
                self?.processAnalyticsEvent(event: event)
            })
            .store(in: &cancellables)
    }

    private func processAnalyticsEvent(event: any AnalyticsEvent) { // ✅ Explicit type annotation
        Task {
            await aggregateEvent(event: event)
        }
    }

    private func aggregateEvent(event: any AnalyticsEvent) async { // ✅ Explicit type annotation
        switch event.eventType {
        case .cravingCreated:
            guard let cravingEvent = event as? CravingEvent else { return } // ✅ No longer ambiguous
            await updateDailyAggregates(for: cravingEvent)
            await updateWeeklyAggregates(for: cravingEvent)
            await updateMonthlyAggregates(for: cravingEvent)
        default:
            break
        }
    }

    private func updateDailyAggregates(for event: CravingEvent) async { // ✅ Explicit type annotation
        let date = event.timestamp.onlyDate
        var dailyData = dailyAggregates[date] ?? DailyAnalytics(date: date)
        dailyData.totalCravings += 1
        dailyAggregates[date] = dailyData
    }

    private func updateWeeklyAggregates(for event: CravingEvent) async { // ✅ Explicit type annotation
        let weekNumber = Calendar.current.component(.weekOfYear, from: event.timestamp)
        var weeklyData = weeklyAggregates[weekNumber] ?? WeeklyAnalytics(weekNumber: weekNumber)
        weeklyData.totalCravings += 1
        weeklyAggregates[weekNumber] = weeklyData
    }

    private func updateMonthlyAggregates(for event: CravingEvent) async { // ✅ Explicit type annotation
        let monthNumber = Calendar.current.component(.month, from: event.timestamp)
        var monthlyData = monthlyAggregates[monthNumber] ?? MonthlyAnalytics(monthNumber: monthNumber)
        monthlyData.totalCravings += 1
        monthlyAggregates[monthNumber] = monthlyData
    }
}

// MARK: - Supporting Structures - These should be defined elsewhere if not already
struct DailyAnalytics {
    let date: Date
    var totalCravings: Int = 0

    init(date: Date) {
        self.date = date
    }
}

struct WeeklyAnalytics {
    let weekNumber: Int
    var totalCravings: Int = 0
    init(weekNumber: Int) {
        self.weekNumber = weekNumber
    }
}

struct MonthlyAnalytics {
    let monthNumber: Int
    var totalCravings: Int = 0
    init(monthNumber: Int) {
        self.monthNumber = monthNumber
    }
}

// MARK: - AnalyticsStorage (Placeholder) - Ensure AnalyticsStorage is properly defined in your project
class AnalyticsStorage { // Placeholder - replace with your actual AnalyticsStorage implementation
    var eventPublisher: PassthroughSubject<any AnalyticsEvent, Error> = PassthroughSubject<any AnalyticsEvent, Error>()

    func storeEvent(event: any AnalyticsEvent) async throws {
        // Store event logic here
        eventPublisher.send(event) // Example: immediately publish event for aggregation
    }
}

// MARK: - Example AnalyticsEvent and CravingEvent - Define these as per your AnalyticsEvent.swift if not already defined
enum AnalyticsEventType: String { // Assuming you have an enum for event types
    case cravingCreated
    case systemEvent // Example
    case userEvent   // Example
    case interactionEvent // Example
}

protocol AnalyticsEvent { // Assuming you have an AnalyticsEvent protocol
    var eventType: AnalyticsEventType { get }
    var timestamp: Date { get }
}

struct CravingEvent: AnalyticsEvent { // Example CravingEvent struct
    let eventType: AnalyticsEventType = .cravingCreated
    let timestamp: Date
    let cravingId: UUID
    // ... craving-specific data ...
}

