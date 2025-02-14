// File: AnalyticsAggregator.swift
// Purpose: Aggregates and processes analytics data for pattern recognition and insights

import Foundation
import SwiftData

@Model // Make CravingAnalytics a SwiftData Model
class CravingAnalytics: AnalyticsEvent {
    var id: UUID
    var timestamp: Date
    var eventType: AnalyticsEventType = .cravingCreated // Provide a default value
    var metadata: [String : AnyHashable] = [:] // Provide a default, use AnyHashable
    var priority: EventPriority = .normal // Provide a default

    var cravingId: UUID // Assuming you want to link this to a CravingModel
    var intensity: Double // Changed to Double to match TimePatternInsight
    var triggers: Set<String>

    init(id: UUID = UUID(), timestamp: Date = Date(), cravingId: UUID, intensity: Double, triggers: Set<String>, metadata: [String: AnyHashable] = [:]) {
        self.id = id
        self.timestamp = timestamp
        self.cravingId = cravingId
        self.intensity = intensity
        self.triggers = triggers
        self.metadata = metadata // Initialize metadata
    }

    // Add required and convenience init for Codable conformance, if you use @Model
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        eventType = try container.decode(AnalyticsEventType.self, forKey: .eventType)
        metadata = try container.decode([String: AnyHashable].self, forKey: .metadata)
        priority = try container.decode(EventPriority.self, forKey: .priority)
        cravingId = try container.decode(UUID.self, forKey: .cravingId)
        intensity = try container.decode(Double.self, forKey: .intensity)
        triggers = try container.decode(Set<String>.self, forKey: .triggers)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(priority, forKey: .priority)
        try container.encode(cravingId, forKey: .cravingId)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(triggers, forKey: .triggers)
    }

    enum CodingKeys: CodingKey {
        case id, timestamp, eventType, metadata, priority, cravingId, intensity, triggers
    }
}

actor AnalyticsAggregator {
    private let modelContext: ModelContext
    private var dailyAggregates: [Date: DailyAggregate] = [:]
    private var weeklyAggregates: [Date: WeeklyAggregate] = [:]
    private var monthlyAggregates: [Date: MonthlyAggregate] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let configuration: AggregatorConfiguration

    init(modelContext: ModelContext, configuration: AggregatorConfiguration = .default) {
        self.modelContext = modelContext
        self.configuration = configuration
        setupAggregation()
    }

    // MARK: - Public Interface
    func aggregate(_ analytics: CravingAnalytics) async throws {
        // Aggregate data for different time ranges
        let daily = try await aggregateDaily(analytics)
        let weekly = try await aggregateWeekly(analytics)
        let monthly = try await aggregateMonthly(analytics)
        await updateAggregates(daily: daily, weekly: weekly, monthly: monthly)
    }


     func getAggregates(for timeRange: TimeRange) async throws -> AggregateResult {
        switch timeRange {
        case .day(let date):
            return try await getDailyAggregate(for: date)
        case .week(let date):
            return try await getWeeklyAggregate(for: date)
        case .month(let date):
            return try await getMonthlyAggregate(for: date)
        case .custom(let startDate, let endDate):
            return try await getCustomRangeAggregate(from: startDate, to: endDate)
        }
    }

    // MARK: - Aggregation Logic
    private func aggregateDaily(_ analytics: CravingAnalytics) async throws -> DailyAggregate {
        let date = analytics.timestamp.startOfDay
        var aggregate: DailyAggregate
        if let exisitingAggregate = dailyAggregates[date]{
            aggregate = exisitingAggregate
        } else {
            aggregate = DailyAggregate(date: date)
        }

        // Update metrics
        aggregate.cravingCount += 1
        aggregate.totalIntensity += Int(analytics.intensity) // Cast to Int
        aggregate.updateTimeDistribution(for: analytics.timestamp)
        aggregate.updateTriggerPatterns(with: analytics.triggers)

        return aggregate
    }
    

    private func aggregateWeekly(_ analytics: CravingAnalytics) async throws -> WeeklyAggregate {
       let weekStart = analytics.timestamp.startOfWeek
        var aggregate: WeeklyAggregate
        if let existingAggregate = weeklyAggregates[weekStart]{
            aggregate = existingAggregate
        } else {
            aggregate = WeeklyAggregate(weekStart: weekStart)
        }

        // Update weekly metrics
        aggregate.updateDailyDistribution(for: analytics.timestamp)
        //aggregate.updatePatterns(with: analytics) // Removed as CravingAnalytics does not conform to CravingAnalyticsProtocol
        //aggregate.calculateTrends() // Removed, this needs specific implementation.  See notes.

        return aggregate
    }

    private func aggregateMonthly(_ analytics: CravingAnalytics) async throws -> MonthlyAggregate {
        let monthStart = analytics.timestamp.startOfMonth
        var aggregate: MonthlyAggregate
        
        if let existingAggregate = monthlyAggregates[monthStart]{
            aggregate = existingAggregate
        } else {
            aggregate = MonthlyAggregate(monthStart: monthStart)
        }
        
        // Update monthly metrics
        aggregate.updateWeeklyDistribution(for: analytics.timestamp)
        //aggregate.updateLongTermPatterns(with: analytics) // Removed as CravingAnalytics does not conform to CravingAnalyticsProtocol
        //aggregate.calculateMonthlyTrends() // Removed, needs specific implementation. See notes.
        
        return aggregate
    }

    @MainActor
    private func updateAggregates(daily: DailyAggregate, weekly: WeeklyAggregate, monthly: MonthlyAggregate) {
        dailyAggregates[daily.date] = daily
        weeklyAggregates[weekly.weekStart] = weekly
        monthlyAggregates[monthly.monthStart] = monthly
    }

    // MARK: - Aggregate Retrieval Methods
    private func getDailyAggregate(for date: Date) async throws -> AggregateResult {
        guard let aggregate = dailyAggregates[date.startOfDay] else {
            throw AggregationError.noDataAvailable
        }
        return .daily(aggregate)
    }

    private func getWeeklyAggregate(for date: Date) async throws -> AggregateResult {
       guard let aggregate = weeklyAggregates[date.startOfWeek] else {
            throw AggregationError.noDataAvailable
        }
        return .weekly(aggregate)
    }

    private func getMonthlyAggregate(for date: Date) async throws -> AggregateResult {
        guard let aggregate = monthlyAggregates[date.startOfMonth] else {
            throw AggregationError.noDataAvailable
        }
        return .monthly(aggregate)
    }

    private func getCustomRangeAggregate(from start: Date, to end: Date) async throws -> AggregateResult {
        // Create a new CustomRangeAggregate
        var newAggregate = CustomRangeAggregate(startDate: start, endDate: end)

        // Fetch all daily aggregates within the date range
        for (date, dailyAggregate) in dailyAggregates {
            if date >= start.startOfDay && date <= end.startOfDay {
                // Accumulate data from daily aggregates
                newAggregate.cravingCount += dailyAggregate.cravingCount
                // ... accumulate other metrics as needed
            }
        }
        return .custom(newAggregate)
    }

    // MARK: - Setup
    private func setupAggregation() {
        setupPeriodicAggregation()
        setupDataObservers()
    }

    private func setupPeriodicAggregation() {
        Timer.publish(every: configuration.aggregationInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    try? await self?.performPeriodicAggregation()
                }
            }
            .store(in: &cancellables)
    }

    private func setupDataObservers() {
        // Placeholder for SwiftData observation.  This is where you'd observe
        // changes to your CravingModel data and trigger aggregation updates.
        // SwiftData's change notifications are not directly compatible with
        // Combine, so you might need a different approach (e.g., observing
        // the ModelContext directly, or using a library that bridges the gap).
    }

    private func performPeriodicAggregation() async throws {
        // Implement periodic aggregation logic
        // Fetch data since last aggregation and call `aggregate`.
    }
}


// MARK: - Supporting Types
extension AnalyticsAggregator {
    struct AggregatorConfiguration {
        let aggregationInterval: TimeInterval
        let retentionPeriod: TimeInterval
        let batchSize: Int

        static let `default` = AggregatorConfiguration(
            aggregationInterval: 3600, // 1 hour
            retentionPeriod: 30 * 24 * 3600, // 30 days
            batchSize: 100
        )
    }
}

// MARK: - Aggregate Types
// Moved to global scope
struct DailyAggregate {
     var date: Date
    var cravingCount: Int = 0
    var totalIntensity: Int = 0
    var timeDistribution: [Int: Int] = [:] // Hour: Count
    var triggerPatterns: [String: Int] = [:]

    //init
    init(date: Date) {
            self.date = date
    }
    // Example methods to update the aggregate
    mutating func updateTimeDistribution(for timestamp: Date) {
        // Implement logic to categorize time of day (morning, afternoon, etc.)
         let hour = Calendar.current.component(.hour, from: timestamp)
        timeDistribution[hour, default: 0] += 1
    }

    mutating func updateTriggerPatterns(with triggers: Set<String>) {
        for trigger in triggers {
            triggerPatterns[trigger, default: 0] += 1
        }
    }
}

struct WeeklyAggregate {
    var weekStart: Date
    var dailyDistribution: [Date: Int] = [:]  // Weekday: Count.  Use Int for simplicity.
    //var patterns: [Pattern] = [] // Replace with your Pattern type
    //var trends: [Trend] = []   // Replace with your Trend type
    init(weekStart: Date){
        self.weekStart = weekStart
    }
    //add more
    mutating func updateDailyDistribution(for timestamp: Date) {
        let weekday = Calendar.current.component(.weekday, from: timestamp)
         dailyDistribution[Calendar.current.date(from: .init(weekday: weekday))!, default: 0] += 1 //maps to a date
    }
    mutating func updateWeeklyDistribution(for timestamp: Date) {}
}

struct MonthlyAggregate {
    var monthStart: Date
    //add more
    init(monthStart: Date){
        self.monthStart = monthStart
    }
    mutating func updateWeeklyDistribution(for timestamp: Date) {}
}
// Add CustomRangeAggregate
struct CustomRangeAggregate {
    // Define properties for custom range aggregation
    var startDate: Date
    var endDate: Date
    var cravingCount: Int = 0
    // ... other properties
}

enum AggregateResult {
    case daily(DailyAggregate)
    case weekly(WeeklyAggregate)
    case monthly(MonthlyAggregate)
    case custom(CustomRangeAggregate) // Add custom case
}
enum AggregationError: Error {
        case aggregationFailed(Error)
        case noDataAvailable
        case invalidDateRange
        case invalidConfiguration
        
        var localizedDescription: String {
            switch self {
            case .aggregationFailed(let error):
                return "Aggregation failed: \(error.localizedDescription)"
            case .noDataAvailable:
                return "No data available for aggregation"
            case .invalidDateRange:
                return "Invalid date range specified"
            case .invalidConfiguration:
                return "Invalid aggregator configuration"
            }
        }
    }
