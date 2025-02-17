// AnalyticsDashboardView.swift

import SwiftUI

struct AnalyticsDashboardView: View {
    @StateObject var viewModel = AnalyticsDashboardViewModel()

    var body: some View {
        VStack {
            Text("Analytics Dashboard")
                .font(.largeTitle)
                .padding()

            List(viewModel.analyticsData) { data in
                HStack {
                    Text(data.title)
                        .font(.headline)
                    Spacer()
                    Text(data.value)
                        .font(.subheadline)
                }
            }
        }
        .onAppear {
            viewModel.loadAnalytics()
        }
    }
}
