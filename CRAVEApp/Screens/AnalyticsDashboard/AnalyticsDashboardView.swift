//
//  AnalyticsDashboardView.swift
//  CRAVE
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
                
                // Bar Chart
                CravingBarChart(data: stats.cravingsPerDay)

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
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.loadAnalytics()
        }
    }
}

