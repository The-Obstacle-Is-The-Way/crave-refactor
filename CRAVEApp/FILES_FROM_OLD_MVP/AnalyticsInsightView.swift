//  CRAVEApp/Core/Presentation/Views/Analytics/AnalyticsInsightView.swift

import SwiftUI
import Charts

struct AnalyticsInsightView: View {
    let calendarData: [Date: Int]
    let timeOfDayData: [String: Int]

    var body: some View {
        VStack(spacing: 20) {
            Text("Analytics Insights")
              .font(CRAVEDesignSystem.Typography.title1)
              .padding()

            VStack(alignment:.leading) {
                Text("Daily Activity")
                  .font(CRAVEDesignSystem.Typography.headline)
                  .padding(.horizontal)

                CalendarHeatmapView(data: calendarData)
                  .padding(.horizontal)
            }

            VStack(alignment:.leading) {
                Text("Time of Day Patterns")
                  .font(CRAVEDesignSystem.Typography.headline)
                  .padding(.horizontal)

                TimeOfDayPieChart(data: timeOfDayData)
                  .padding(.horizontal)
            }
        }
      .padding(.bottom, 20)
    }
}
