//
//  AnalyticsView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel // ✅ Ensures reactivity

    init(viewModel: AnalyticsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel) // ✅ Proper initialization
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.cravings.isEmpty {
                    Text("No cravings logged yet.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack {
                        Text("Cravings Analytics")
                            .font(.title2)
                            .bold()
                            .padding(.top)

                        // Example: Bar chart of cravings per day
                        CravingBarChart(data: viewModel.cravingsByDate)

                        // Example: Pie chart for time-of-day cravings
                        TimeOfDayPieChart(data: viewModel.cravingsByTimeOfDay)

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics")
            .onAppear {
                viewModel.loadAnalytics() // ✅ Load analytics only when view appears
            }
        }
    }
}

// ✅ Preview with sample data
struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView(viewModel: AnalyticsViewModel())
            .modelContainer(for: CravingModel.self, inMemory: true)
    }
}
