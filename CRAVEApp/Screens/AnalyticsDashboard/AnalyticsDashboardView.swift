//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/AnalyticsDashboardView.swift
//  Purpose: Displays analytics data in a SwiftUI view.
//

import SwiftUI

struct AnalyticsDashboardView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack {
                if let stats = viewModel.basicStats {
                    // Use the stats here.  This is just an example.
                    Text("Total Cravings: \(stats.totalCravings)")
                        .font(.title)
                    AnalyticsInsightView(calendarData: stats.cravingsByFrequency, timeOfDayData: stats.cravingsByTimeSlot)
                    
                } else {
                    // Show a loading indicator or an error message
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
        }
        .navigationTitle("Analytics Dashboard")
        .onAppear {
            viewModel.loadAnalytics(modelContext: modelContext)
        }
    }
}
