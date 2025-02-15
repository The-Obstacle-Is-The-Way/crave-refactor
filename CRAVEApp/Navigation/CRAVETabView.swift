//
//  🍒
//  CRAVEApp/Navigation/CRAVETabView.swift
//  Purpose: Main entry point for the app.
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) var modelContext: ModelContext // Removed private
    @State private var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            CravingListView()
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }
                .tag(0)

            LogCravingView()
                .tabItem {
                    Label("Log Craving", systemImage: "square.and.pencil")
                }
                .tag(1)

            DateListView()
                .tabItem {
                    Label("Cravings by Date", systemImage: "calendar")
                }
                .tag(2)

            AnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
    }
}
```

```swift
// CRAVEApp/Screens/AnalyticsDashboard/AnalyticsDashboardView.swift
import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View { // Corrected struct name
    @Environment(\.modelContext) var modelContext // Removed private
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
    MainActor.assumeIsolated { // Corrected: Use assumeIsolated
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: CravingModel.self, configurations: config)
            return AnalyticsDashboardView()
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container: \(error)") // Improved error handling
        }
    }
}

