//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsView.swift
//  Purpose: 
//
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject private var viewModel = AnalyticsViewModel() // ViewModel for the view

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Analytics Overview")
                    .font(.title)
                    .padding()

                // Example of how to display basic stats (replace with your actual charts/data)
                if let stats = viewModel.basicStats {
                    Text("Total Cravings: \(stats.totalCravings)")
                    Text("Average Cravings Per Day: \(stats.averageCravingsPerDay)")
                    // Add your charts and other UI elements here, using data from 'stats'
                    CravingBarChart(data: stats.cravingsPerDay) // Example of using a chart
                        .frame(height: 200)
                    TimeOfDayPieChart(data: stats.cravingsByTimeSlot)
                        .frame(height: 200)
                    CalendarHeatmapView(data: stats.cravingsByFrequency)
                        .frame(height: 200)

                } else {
                    ProgressView() // Show a loading indicator while fetching data
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadAnalytics(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    MainActor.run {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: CravingModel.self, configurations: config)
        return AnalyticsView()
            .modelContainer(container)
    }
}
