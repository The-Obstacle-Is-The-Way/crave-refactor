// AnalyticsInsights.swift

import SwiftUI

struct AnalyticsInsights: View {
    var insights: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Insights")
                .font(.title2)
                .padding(.bottom, 5)

            ForEach(insights, id: \.self) { insight in
                Text("• \(insight)")
                    .font(.body)
                    .padding(.vertical, 2)
            }
        }
        .padding()
    }
}
