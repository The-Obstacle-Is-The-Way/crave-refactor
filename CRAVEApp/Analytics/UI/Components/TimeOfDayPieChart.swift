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
    
    private let colors: [Color] = [.blue, .green, .orange, .purple]
    
    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No data available")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(data.sorted(by: { $0.key < $1.key }), id: \.key) { time, count in
                    SectorMark(
                        angle: .value("Count", count),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Time", time))
                    .annotation(position: .overlay) {
                        if count > 0 {
                            Text("\(count)")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .chartLegend(position: .bottom)
                .frame(height: 300)
                .padding()
                
                // Legend
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                    ForEach(Array(data.keys.sorted().enumerated()), id: \.element) { index, key in
                        HStack {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 10, height: 10)
                            Text(key)
                                .font(.caption)
                            Text("(\(data[key] ?? 0))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
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
