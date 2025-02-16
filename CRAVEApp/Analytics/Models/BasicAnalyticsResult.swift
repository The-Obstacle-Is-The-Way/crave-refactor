//
//  CRAVEApp/Analytics/Models/BasicAnalyticsResult.swift
//  CRAVE
//


import Foundation

struct BasicAnalyticsResult {
    // MARK: - Core Data
    let cravingsByFrequency: [Date: Int]
    let cravingsPerDay: [Date: Int]
    let cravingsByTimeSlot: [String: Int]
    
    // MARK: - Computed Properties
    var totalCravings: Int {
        cravingsPerDay.values.reduce(0, +)
    }
    
    var averageCravingsPerDay: Double {
        guard !cravingsPerDay.isEmpty else { return 0 }
        return Double(totalCravings) / Double(cravingsPerDay.count)
    }
    
    var mostActiveTimeSlot: (slot: String, count: Int)? {
        if let maxElement = cravingsByTimeSlot.max(by: { $0.value < $1.value }) {
            return (slot: maxElement.key, count: maxElement.value)
        } else {
            return nil
        }
    }
    
    var dateRange: ClosedRange<Date>? {
        guard let earliest = cravingsPerDay.keys.min(),
              let latest = cravingsPerDay.keys.max() else {
            return nil
        }
        return earliest...latest
    }
    
    // MARK: - Initialization
    init(
        cravingsByFrequency: [Date: Int] = [:],
        cravingsPerDay: [Date: Int] = [:],
        cravingsByTimeSlot: [String: Int] = [:]
    ) {
        self.cravingsByFrequency = cravingsByFrequency
        self.cravingsPerDay = cravingsPerDay
        self.cravingsByTimeSlot = cravingsByTimeSlot
    }
    
    // MARK: - Helper Methods
    func getCravings(in dateRange: DateInterval) -> [Date: Int] {
        cravingsPerDay.filter { dateRange.contains($0.key) }
    }
    
    func timeSlotDistribution() -> [String: Double] {
        guard totalCravings > 0 else { return [:] }
        return cravingsByTimeSlot.mapValues { Double($0) / Double(totalCravings) }
    }
    
    func weeklyAverage() -> Double {
        guard let dateRange = dateRange else { return 0 }
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: dateRange.lowerBound, to: dateRange.upperBound).weekOfYear ?? 1
        return Double(totalCravings) / max(Double(weeks), 1)
    }
    
    func monthlyTrend() -> [(month: Date, count: Int)] {
        guard !cravingsByFrequency.isEmpty else { return [] }
        
        let calendar = Calendar.current
        var monthlyData: [Date: Int] = [:]
        
        for (date, count) in cravingsByFrequency {
            let components = calendar.dateComponents([.year, .month], from: date)
            if let monthStart = calendar.date(from: components) {
                monthlyData[monthStart, default: 0] += count
            }
        }
        
        return monthlyData.sorted { $0.key < $1.key }
            .map { (month: $0.key, count: $0.value) }
    }
}


