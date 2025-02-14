//
//  CravingBarChart.swift
//  CRAVE
//

import SwiftUI
import Charts

struct CravingBarChart: View {
    let data: [String: Int] // ✅ Data passed from AnalyticsViewModel

    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No cravings logged yet.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart {
                    ForEach(sortedData(), id: \.key) { date, count in
                        BarMark(
                            x: .value("Date", date),
                            y: .value("Cravings", count)
                        )
                        .foregroundStyle(Color.accentColor) // ✅ Uses adaptive color
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

    // MARK: - Sort Data by Date
    private func sortedData() -> [(key: String, value: Int)] {
        return data.sorted { $0.key < $1.key }
    }
}

// ✅ Preview with sample data
struct CravingBarChart_Previews: PreviewProvider {
    static var previews: some View {
        CravingBarChart(data: ["01/20": 5, "01/21": 3, "01/22": 7])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
