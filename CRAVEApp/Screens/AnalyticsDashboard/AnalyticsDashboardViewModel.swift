//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/AnalyticsDashboardViewModel.swift
//
//

import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View { // Corrected struct name
    @Environment(\.modelContext) var modelContext // NO private keyword
    @StateObject private var viewModel = AnalyticsDashboardViewModel()

    var body: some View {
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

                        // Additional insights can be added here
                        if !stats.cravingsByFrequency.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Activity Calendar")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)

                                CalendarHeatmapView(data: stats.cravingsByFrequency)
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
            viewModel.loadAnalytics(modelContext: modelContext) // Corrected: Pass modelContext
        }
    }
}

#Preview {
    MainActor.assumeIsolated {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: CravingModel.self, configurations: config)
            // Create a sample craving and insert it.  This is important!
            let sampleCraving = CravingModel(cravingText: "Preview Craving")
            container.mainContext.insert(sampleCraving)
            
            return AnalyticsDashboardView()
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
}
