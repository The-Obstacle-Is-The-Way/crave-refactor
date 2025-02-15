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
    let data: [String: Int] // Takes a dictionary: ["Morning": 5, "Afternoon": 3, ...]

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
                        innerRadius: .ratio(0.618), // Optional: Create a "donut" chart
                        angularInset: 1.5 // Optional: Add some spacing between slices
                    )
                    .foregroundStyle(by: .value("Time", time))
                    .cornerRadius(5) // Optional: Rounded corners
                }
                .frame(height: 300)
                .padding()
            }
        }
    }
}
