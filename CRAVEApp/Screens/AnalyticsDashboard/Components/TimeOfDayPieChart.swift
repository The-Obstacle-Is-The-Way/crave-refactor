//
//  TimeOfDayPieChart.swift
//  CRAVE
//

import SwiftUI
import Charts

struct TimeOfDayPieChart: View {
    let data: [String: Int] // ✅ Data passed from AnalyticsViewModel

    private let colors: [String: Color] = [
        "Morning": .yellow,
        "Afternoon": .orange,
        "Evening": .purple,
        "Night": .blue
    ] // ✅ Distinct colors for clarity

    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No cravings logged yet.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart {
                    ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { time, count in
                        SectorMark(
                            angle: .value("Cravings", count),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(colors[time, default: .gray]) // ✅ Uses defined colors
                        .accessibilityLabel("\(time): \(count) cravings") // ✅ VoiceOver support
                    }
                }
                .chartLegend(position: .bottom) // ✅ Adds a clear legend
                .frame(height: 300)
                .padding()
            }
        }
    }
}

// ✅ Preview with sample data
struct TimeOfDayPieChart_Previews: PreviewProvider {
    static var previews: some View {
        TimeOfDayPieChart(data: ["Morning": 5, "Afternoon": 3, "Evening": 7, "Night": 2])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
