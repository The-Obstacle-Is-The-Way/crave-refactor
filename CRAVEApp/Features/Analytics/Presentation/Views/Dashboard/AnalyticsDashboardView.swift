//
//
//  🍒
//  CRAVEApp/Features/Analytics/Presentation/Views/Dashboard/AnalyticsDashboardView.swift
//  Purpose: Displays analytics data in a SwiftUI view.
//
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
                        .font(CRAVEDesignSystem.Typography.title1) // UPDATE: Use title1
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
        //UPDATE: Use the new title font
        .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .principal) {
                  Text("Analytics Dashboard")
                      .font(CRAVEDesignSystem.Typography.headline)
                      .foregroundColor(CRAVEDesignSystem.Colors.textPrimary)
              }
          }
        .onAppear {
            viewModel.loadAnalytics(modelContext: modelContext)
        }
    }
}
