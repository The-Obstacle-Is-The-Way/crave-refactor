//
//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/Components/PatternVisualizationView.swift
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
                        angle: .value("Cravings", count)
                    )
                    .foregroundStyle(by: .value("Time", time))
                }
                .frame(height: 300)
                .padding()
            }
        }
    }
}

struct TimeOfDayPieChart_Previews: PreviewProvider {
    static var previews: some View {
        TimeOfDayPieChart(data: [
            "Morning": 3,
            "Afternoon": 5,
            "Evening": 2,
            "Night": 4
        ])
    }
}
