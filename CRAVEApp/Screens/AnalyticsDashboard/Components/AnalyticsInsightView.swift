//
// 🍒
// AnalyticsInsightView.swift
//
//

import SwiftUI

struct AnalyticsInsightView: View {
    let calendarData: [Date: Int]
    let timeOfDayData: [String: Int]

    var body: some View {
        VStack(spacing: 20) {
            Text("Analytics Insights")
                .font(.title)
                .padding()

            // Reference the single CalendarHeatmapView from CalendarHeatmapView.swift
            CalendarHeatmapView(data: calendarData)
                .padding(.horizontal)

            // Reference the single TimeOfDayPieChart from PatternVisualizationView.swift
            TimeOfDayPieChart(data: timeOfDayData)
                .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
}

struct AnalyticsInsightView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsInsightView(
            calendarData: sampleCalendarData(),
            timeOfDayData: sampleTimeOfDayData()
        )
    }

    static func sampleCalendarData() -> [Date: Int] {
        var data = [Date: Int]()
        let calendar = Calendar.current
        let today = Date()
        for offset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                data[date] = Int.random(in: 0...4)
            }
        }
        return data
    }

    static func sampleTimeOfDayData() -> [String: Int] {
        return [
            "Morning": 3,
            "Afternoon": 2,
            "Evening": 5,
            "Night": 1
        ]
    }
}
