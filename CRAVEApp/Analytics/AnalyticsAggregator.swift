//
// CRAVEApp/Analytics/AnalyticsAggregator.swift
//  CRAVE
//

import Foundation
import Combine // Make sure to import Combine if not already present

@MainActor
class AnalyticsAggregator: ObservableObject { // Added ObservableObject conformance and @MainActor

    @Published private(set) var dailyAggregates: [Date: DailyAnalytics] = [:]
    @Published private(set) var weeklyAggregates: [Int: WeeklyAnalytics] = [:] // Week number to WeeklyAnalytics
    @Published private(set) var monthlyAggregates: [Int: MonthlyAnalytics] = [:] // Month number to MonthlyAnalytics

    private var analyticsStorage: AnalyticsStorage // Assuming you have AnalyticsStorage defined
    private var cancellables = Set<AnyCancellable>() // Import Combine

    init(analyticsStorage: AnalyticsStorage) {
        self.analyticsStorage = analyticsStorage
        setupObservers()
    }

    private func setupObservers() {
        // Example observer setup - adjust based on your actual event publishing mechanism
        // Assuming AnalyticsStorage publishes events
        analyticsStorage.eventPublisher // Assuming eventPublisher exists in AnalyticsStorage and publishes AnalyticsEvent
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error receiving analytics event: \(error)")
                case .finished:
                    print("Analytics event stream finished")
                }
            } receiveValue: { [weak self] event in
                self?.processAnalyticsEvent(event)
            }
            .store(in: &cancellables)
    }

    private func processAnalyticsEvent(_ event: any AnalyticsEvent) { // Use 'any AnalyticsEvent'
        Task {
            await aggregateEvent(event) // Call async function with await
        }
    }


    private func aggregateEvent(event: any AnalyticsEvent) async { // Use 'any AnalyticsEvent' and mark as async
        switch event.eventType {
        case .cravingCreated:
            guard let cravingEvent = event as? CravingEvent else { return } // Safe cast
            await updateDailyAggregates(for: cravingEvent)
            await updateWeeklyAggregates(for: cravingEvent)
            await updateMonthlyAggregates(for: cravingEvent)
        default:
            break
        }
    }

    private func updateDailyAggregates(for event: CravingEvent) async {
        let date = event.timestamp.onlyDate // Assuming .onlyDate extension exists
        var dailyData = dailyAggregates[date] ?? DailyAnalytics(date: date) // Initialize if nil
        dailyData.totalCravings += 1 // Example aggregation
        // ... other daily aggregations ...
        dailyAggregates[date] = dailyData // Update dictionary - this is now safe on main actor
    }

    private func updateWeeklyAggregates(for event: CravingEvent) async {
        let weekNumber = Calendar.current.component(.weekOfYear, from: event.timestamp)
        var weeklyData = weeklyAggregates[weekNumber] ?? WeeklyAnalytics(weekNumber: weekNumber) // Initialize if nil
        weeklyData.totalCravings += 1 // Example aggregation
        // ... other weekly aggregations ...
        weeklyAggregates[weekNumber] = weeklyData // Update dictionary - this is now safe on main actor
    }

    private func updateMonthlyAggregates(for event: CravingEvent) async {
        let monthNumber = Calendar.current.component(.month, from: event.timestamp)
        var monthlyData = monthlyAggregates[monthNumber] ?? MonthlyAnalytics(monthNumber: monthNumber) // Initialize if nil
        monthlyData.totalCravings += 1 // Example aggregation
        // ... other monthly aggregations ...
        monthlyAggregates[monthNumber] = monthlyData // Update dictionary - this is now safe on main actor
    }
}

// MARK: - Supporting Structures - Define these structs as per your AnalyticsModel if not already defined
struct DailyAnalytics {
    let date: Date
    var totalCravings: Int = 0
    // ... other daily metrics ...

    init(date: Date) {
        self.date = date
    }
}

struct WeeklyAnalytics {
    let weekNumber: Int
    var totalCravings: Int = 0
    // ... other weekly metrics ...
    init(weekNumber: Int) {
        self.weekNumber = weekNumber
    }
}

struct MonthlyAnalytics {
    let monthNumber: Int
    var totalCravings: Int = 0
    // ... other monthly metrics ...
    init(monthNumber: Int) {
        self.monthNumber = monthNumber
    }
}

// MARK: - Example AnalyticsEvent and CravingEvent - Define these as per your AnalyticsEvent.swift if not already defined
enum AnalyticsEventType { // Assuming you have an enum for event types
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

// MARK: - AnalyticsStorage (Placeholder) - Ensure AnalyticsStorage is properly defined in your project
class AnalyticsStorage { // Placeholder - replace with your actual AnalyticsStorage implementation
    var eventPublisher: PassthroughSubject<any AnalyticsEvent, Error> = PassthroughSubject<any AnalyticsEvent, Error>()

    func storeEvent(_ event: any AnalyticsEvent) async throws {
        // Store event logic here
        eventPublisher.send(event) // Example: immediately publish event for aggregation
    }
}
