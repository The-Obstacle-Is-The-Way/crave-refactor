//  CRAVEApp/Core/Presentation/Views/Analytics/CravingBarChart.swift

import SwiftUI
import Charts

struct CravingBarChart: View {
    let data: [Date: Int]

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }

    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No cravings logged yet")
                  .font(CRAVEDesignSystem.Typography.headline)
                  .foregroundColor(CRAVEDesignSystem.Colors.textSecondary)
                  .padding()
            } else {
                Chart {
                    ForEach(data.keys.sorted(), id: \.self) { date in
                        BarMark(
                            x:.value("Date", date, unit:.day),
                            y:.value("Count", data[date]?? 0)
                        )
                      .foregroundStyle(Color.blue.gradient)
                      .annotation(position:.top) {
                            if let count = data[date], count > 0 {
                                Text("\(count)")
                                  .font(CRAVEDesignSystem.Typography.caption2)
                                  .foregroundColor(CRAVEDesignSystem.Colors.textSecondary)
                            }
                        }
                    }
                }
              .chartXAxis {
                    AxisMarks(values:.stride(by:.day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(dateFormatter.string(from: date))
                        }
                    }
                }
              .chartYAxis {
                    AxisMarks(position:.leading)
                }
              .frame(height: 300)
              .padding()
            }
        }
    }
}
