//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/Components/CravingBarChart.swift
//  Purpose:
//
//

import SwiftUI
import Charts

struct CravingBarChart: View {
    let data: [Date: Int]

    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No cravings logged yet.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart {
                    ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, count in
                        BarMark(
                            x: .value("Date", date, unit: .day), // Use .day for daily data
                            y: .value("Cravings", count)
                        )
                        .foregroundStyle(Color.blue) // Use a specific color
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) // Keep Y axis on the leading edge
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 7)) { value in // Aim for ~7 marks
                        AxisGridLine()
                        AxisTick()
                        // Format as month and day
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .frame(height: 300)
                .padding()
            }
        }
    }
}

