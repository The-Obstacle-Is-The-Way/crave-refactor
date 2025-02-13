// AnalyticsDashboardView.swift

import SwiftUI
import SwiftData

public struct AnalyticsDashboardView: View {
    @StateObject public var viewModel: AnalyticsDashboardViewModel

    public init(viewModel: AnalyticsDashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack {
            if let stats = viewModel.basicStats {
                Text("Cravings by Day").font(.headline)
                CravingBarChart(data: stats.cravingsPerDay)
                
                Text("Time of Day").font(.headline)
                TimeOfDayPieChart(data: stats.cravingsByTimeSlot)
            } else {
                ProgressView("Loading Analytics...")
            }
        }
        .onAppear {
            viewModel.loadAnalytics()
        }
    }
}

struct AnalyticsDashboardView_Previews: PreviewProvider {
    public static var previews: some View {
        let dummyManager = AnalyticsManager(cravingManager: CravingManager())
        let viewModel = AnalyticsDashboardViewModel(analyticsManager: dummyManager)
        return AnalyticsDashboardView(viewModel: viewModel)
    }
}
