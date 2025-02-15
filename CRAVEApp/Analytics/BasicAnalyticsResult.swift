//
//  BasicAnalyticsResult.swift
//  CRAVE
//

import Foundation

struct BasicAnalyticsResult {
    let cravingsByFrequency: [Date: Int]
    let cravingsPerDay: [Date: Int]
    let cravingsByTimeSlot: [String: Int]
    
    // Computed properties
    var totalCravings: Int {
        cravingsPerDay.values.reduce(0, +)
    }
    
    var averageCravingsPerDay: Double {
        guard !cravingsPerDay.isEmpty else { return 0 }
        return Double(totalCravings) / Double(cravingsPerDay.count)
    }
    
    var mostActiveTimeSlot: (slot: String, count: Int)? {
        cravingsByTimeSlot.max(by: { $0.value < $1.value })
    }
    
    var dateRange: ClosedRange<Date>? {
        guard let earliest = cravingsPerDay.keys.min(),
              let latest = cravingsPerDay.keys.max() else {
            return nil
        }
        return earliest...latest
    }
    
    init(
        cravingsByFrequency: [Date: Int] = [:],
        cravingsPerDay: [Date: Int] = [:],
        cravingsByTimeSlot: [String: Int] = [:]
    ) {
        self.cravingsByFrequency = cravingsByFrequency
        self.cravingsPerDay = cravingsPerDay
        self.cravingsByTimeSlot = cravingsByTimeSlot
    }
    
    // Helper methods
    func getCravings(in dateRange: DateInterval) -> [Date: Int] {
        cravingsPerDay.filter { dateRange.contains($0.key) }
    }
    
    func timeSlotDistribution() -> [String: Double] {
        guard totalCravings > 0 else { return [:] }
        return cravingsByTimeSlot.mapValues { Double($0) / Double(totalCravings) }
    }
}

// MARK: - Preview Helpers
extension BasicAnalyticsResult {
    static var preview: BasicAnalyticsResult {
        BasicAnalyticsResult(
            cravingsByFrequency: generatePreviewFrequencyData(),
            cravingsPerDay: generatePreviewDailyData(),
            cravingsByTimeSlot: [
                "Morning": 3,
                "Afternoon": 5,
                "Evening": 4,
                "Night": 2
            ]
        )
    }
    
    private static func generatePreviewFrequencyData() -> [Date: Int] {
        var data: [Date: Int] = [:]
        let calendar = Calendar.current
        let today = Date()
        
        for day in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                data[date] = Int.random(in: 0...5)
            }
        }
        return data
    }
    
    private static func generatePreviewDailyData() -> [Date: Int] {
        var data: [Date: Int] = [:]
        let calendar = Calendar.current
        let today = Date()
        
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                data[date] = Int.random(in: 1...8)
            }
        }
        return data
    }
}
