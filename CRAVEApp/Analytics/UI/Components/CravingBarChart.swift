//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/Components/CravingBarChart.swift
//  Purpose: Displays a bar chart of craving frequency per day.
//
//


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
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart {
                    ForEach(data.keys.sorted(), id: \.self) { date in
                        BarMark(
                            x: .value("Date", date, unit: .day),
                            y: .value("Count", data[date] ?? 0)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .annotation(position: .top) {
                            if let count = data[date], count > 0 {
                                Text("\(count)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(dateFormatter.string(from: date))
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 300)
                .padding()
            }
        }
    }
}

#Preview {
    CravingBarChart(data: {
        var data = [Date: Int]()
        let calendar = Calendar.current
        let today = Date()
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                data[date] = Int.random(in: 0...5)
            }
        }
        return data
    }())
}
