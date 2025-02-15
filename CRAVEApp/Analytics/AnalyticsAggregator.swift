//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsAggregator.swift
//  Purpose: 
//
//

import Foundation
import Combine
import SwiftData

@MainActor
class AnalyticsAggregator: ObservableObject {

    @Published private(set) var dailyAggregates: [Date: DailyAnalytics] = [:]
    @Published private(set) var weeklyAggregates: [Int: WeeklyAnalytics] = [:]
    @Published private(set) var monthlyAggregates: [Int: MonthlyAnalytics] = [:]

    private var analyticsStorage: AnalyticsStorage
    private var cancellables = Set<AnyCancellable>()

    init(analyticsStorage: AnalyticsStorage) {
        self.analyticsStorage = analyticsStorage
        //setupObservers() // Removed as we are simplifying
    }

    // No longer using Combine for event processing, so removed setupObservers
    /*
    private func setupObservers() {
        analyticsStorage.eventPublisher
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    print("Error receiving analytics event: \(error)")
                case .finished:
                    print("Analytics event stream finished")
                }
            }, receiveValue: { [weak self] event in
                guard let self = self else { return }
                self.processAnalyticsEvent(event: event)
            })
            .store(in: &cancellables)
    }
     */

    func processAnalyticsEvent(event: any AnalyticsEvent) {
        Task {
            await aggregateEvent(event: event)
        }
    }

    private func aggregateEvent(event: any AnalyticsEvent) async {
        switch event.eventType {
        case .cravingCreated:
            // Downcast to CravingEvent (assuming you have a CravingEvent struct)
            guard let cravingEvent = event as? CravingEvent else { return }
            await updateDailyAggregates(for: cravingEvent)
            await updateWeeklyAggregates(for: cravingEvent)
            await updateMonthlyAggregates(for: cravingEvent)
        default:
            break
        }
    }
    
    private func updateDailyAggregates(for event: CravingEvent) async {
        let date = event.timestamp.onlyDate // Correct onlyDate usage
        var dailyData = dailyAggregates[date] ?? DailyAnalytics(date: date)
        dailyData.totalCravings += 1
        dailyAggregates[date] = dailyData
    }

    private func updateWeeklyAggregates(for event: CravingEvent) async {
        let weekNumber = Calendar.current.component(.weekOfYear, from: event.timestamp)
        var weeklyData = weeklyAggregates[weekNumber] ?? WeeklyAnalytics(weekNumber: weekNumber)
        weeklyData.totalCravings += 1
        weeklyAggregates[weekNumber] = weeklyData
    }

    private func updateMonthlyAggregates(for event: CravingEvent) async {
        let monthNumber = Calendar.current.component(.month, from: event.timestamp)
        var monthlyData = monthlyAggregates[monthNumber] ?? MonthlyAnalytics(monthNumber: monthNumber)
        monthlyData.totalCravings += 1
        monthlyAggregates[monthNumber] = monthlyData
    }
}

// MARK: - Supporting Structures
struct DailyAnalytics {
    let date: Date
    var totalCravings: Int = 0
}

struct WeeklyAnalytics {
    let weekNumber: Int
    var totalCravings: Int = 0
}

struct MonthlyAnalytics {
    let monthNumber: Int
    var totalCravings: Int = 0
}
