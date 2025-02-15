//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/AnalyticsDashboardView.swift
//
//

import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AnalyticsDashboardViewModel()

    var body: some View {
        VStack {
            if let stats = viewModel.basicStats {
                Text("Cravings by Day")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                // Bar Chart (Placeholder - you'll need to implement CravingBarChart)
                CravingBarChart(data: stats.cravingsPerDay)

                Text("Time of Day")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                // Pie Chart (Placeholder - you'll need to implement TimeOfDayPieChart)
                TimeOfDayPieChart(data: stats.cravingsByTimeSlot)

                Spacer()
            } else {
                ProgressView("Loading Analytics...")
            }
        }
        .navigationTitle("Analytics") // Keep navigationTitle
        .onAppear {
            viewModel.loadAnalytics(modelContext: modelContext) // Pass modelContext
        }
    }
}

