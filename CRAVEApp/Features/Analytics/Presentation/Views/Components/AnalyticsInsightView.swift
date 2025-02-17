//
//
//  🍒
//  CRAVEApp/Features/Analytics/Presentation/Views/Components/AnalyticsInsightView.swift
//  Purpose: A view that displays analytics insights
//
//

import SwiftUI
import Charts

struct AnalyticsInsightView: View {
    let calendarData: [Date: Int]
    let timeOfDayData: [String: Int]

    var body: some View {
        VStack(spacing: 20) {
            Text("Analytics Insights")
                .font(CRAVEDesignSystem.Typography.title1) //UPDATE: title1
                .padding()

            VStack(alignment: .leading) {
                Text("Daily Activity")
                    .font(CRAVEDesignSystem.Typography.headline) //UPDATE: headline
                    .padding(.horizontal)

                CalendarHeatmapView(data: calendarData)
                    .padding(.horizontal)
            }

            VStack(alignment: .leading) {
                Text("Time of Day Patterns")
                    .font(CRAVEDesignSystem.Typography.headline) //UPDATE: headline
                    .padding(.horizontal)

                TimeOfDayPieChart(data: timeOfDayData)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    AnalyticsInsightView(
        calendarData: {
            var data = [Date: Int]()
            let calendar = Calendar.current
            let today = Date()
            for offset in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                    data[date] = Int.random(in: 0...4)
                }
            }
            return data
        }(),
        timeOfDayData: [
            "Morning": 3,
            "Afternoon": 2,
            "Evening": 5,
            "Night": 1
        ]
    )
}
