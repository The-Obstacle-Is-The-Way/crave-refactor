//
//  AnalyticsView.swift
//  CRAVE
//


import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let stats = viewModel.basicStats {
                    Text("Cravings by Day")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    // Bar Chart
                    CravingBarChart(data: stats.cravingsByFrequency)

                    Text("Time of Day")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    // Pie Chart
                    TimeOfDayPieChart(data: stats.cravingsByTimeSlot)

                    Spacer()
                } else {
                    ProgressView("Loading Analytics...")
                }
            }
            .navigationTitle("Analytics")
            .onAppear {
                viewModel.loadAnalytics(modelContext: modelContext)
            }
        }
    }
}
