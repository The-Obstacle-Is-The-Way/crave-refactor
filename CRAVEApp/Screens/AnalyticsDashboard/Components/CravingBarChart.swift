//
//  CravingBarChart.swift
//  CRAVE
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
                            x: .value("Date", date),
                            y: .value("Cravings", count)
                        )
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 7)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .frame(height: 300)
                .padding()
            }
        }
    }
}
