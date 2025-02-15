//
//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/Components/TimeOfDayPieChart.swift
//  Purpose:
//
//

import SwiftUI
import Charts

struct TimeOfDayPieChart: View {
    let data: [String: Int]

    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No cravings logged yet.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart(data.sorted(by: { $0.key < $1.key }), id: \.key) { time, count in
                    SectorMark(
                        angle: .value("Cravings", count),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Time", time))
                    .cornerRadius(5)
                }
                .frame(height: 300)
                .padding()
            }
        }
    }
}

#Preview {
    TimeOfDayPieChart(data: [
        "Morning": 3,
        "Afternoon": 5,
        "Evening": 2,
        "Night": 4
    ])
}
