//
//  CRAVEApp/Analytics/AnalyticsView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let stats = viewModel.basicStats {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Cravings by Day Section
                            VStack(alignment: .leading) {
                                Text("Cravings by Day")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                
                                CravingBarChart(data: stats.cravingsPerDay)
                                    .frame(height: 300)
                                    .padding(.horizontal)
                            }
                            
                            // Time of Day Section
                            VStack(alignment: .leading) {
                                Text("Time of Day Distribution")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                
                                TimeOfDayPieChart(data: stats.cravingsByTimeSlot)
                                    .frame(height: 300)
                                    .padding(.horizontal)
                            }
                            
                            // Calendar View Section
                            VStack(alignment: .leading) {
                                Text("Activity Calendar")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                
                                CalendarHeatmapView(data: stats.cravingsByFrequency)
                                    .padding(.horizontal)
                            }
                            
                            // Additional Insights Section
                            if let mostActive = stats.mostActiveTimeSlot {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Key Insights")
                                        .font(.title2)
                                        .bold()
                                        .padding(.horizontal)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Most Active Time: \(mostActive.slot)")
                                        Text("Total Cravings: \(stats.totalCravings)")
                                        if stats.averageCravingsPerDay > 0 {
                                            Text("Daily Average: \(String(format: "%.1f", stats.averageCravingsPerDay))")
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                } else {
                    ProgressView("Loading Analytics...")
                }
            }
            .navigationTitle("Analytics")
            .onAppear {
                Task {
                    await viewModel.loadAnalytics(modelContext: modelContext)
                }
            }
        }
    }
}

#Preview {
    MainActor.run {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: CravingModel.self,
            configurations: config
        )
        
        // Add some sample data
        let context = container.mainContext
        for _ in 0..<10 {
            let craving = CravingModel(
                cravingText: "Sample Craving",
                intensity: Int.random(in: 1...10)
            )
            context.insert(craving)
        }
        try! context.save()
        
        return AnalyticsView()
            .modelContainer(container)
    }
}

