// Core/Presentation/Views/Analytics/AnalyticsView.swift

import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @Environment(DependencyContainer.self) private var container
    @StateObject private var viewModel: AnalyticsDashboardViewModel

    init() {
        _viewModel = StateObject(wrappedValue: AnalyticsDashboardViewModel(analyticsManager: AnalyticsManager(analyticsCoordinator: container.analyticsCoordinator)))
    }

    var body: some View {
        ScrollView {
            VStack {
                if let stats = viewModel.basicStats {
                    Text("Total Cravings: \(stats.totalCravings)")
                      .font(CRAVEDesignSystem.Typography.title1)
                    AnalyticsInsightView(calendarData: stats.cravingsByFrequency, timeOfDayData: stats.cravingsByTimeSlot)
                } else {
                    ProgressView()
                      .progressViewStyle(CircularProgressViewStyle())
                }
            }
          .padding()
        }
      .navigationTitle("Analytics Dashboard")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
            ToolbarItem(placement:.principal) {
                Text("Analytics Dashboard")
                  .font(CRAVEDesignSystem.Typography.headline)
                  .foregroundColor(CRAVEDesignSystem.Colors.textPrimary)
            }
        }
      .task {
            await viewModel.loadAnalytics()
        }
    }
}
