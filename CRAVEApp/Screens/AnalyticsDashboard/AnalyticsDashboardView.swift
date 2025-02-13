// AnalyticsDashboardView.swift

import SwiftUI

struct AnalyticsDashboardView: View {
    @StateObject var viewModel: AnalyticsDashboardViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let stats = viewModel.basicStats {
                        Text("Cravings by Day")
                            .font(.headline)
                        CravingBarChart(data: stats.cravingsPerDay)
                            .frame(height: 200)
                        
                        Text("Time of Day Breakdown")
                            .font(.headline)
                        TimeOfDayPieChart(data: stats.cravingsByTimeSlot)
                            .frame(width: 200, height: 200)
                        
                        Text("Calendar Heatmap")
                            .font(.headline)
                        CalendarHeatmapView(data: stats.cravingsPerDay)
                            .frame(height: 300)
                    } else {
                        ProgressView("Loading Analytics...")
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics Dashboard")
            .onAppear {
                viewModel.loadAnalytics()
            }
        }
    }
}

struct AnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // Dummy data for preview purposes
        let sampleData: [Date: Int] = {
            var dict = [Date: Int]()
            let calendar = Calendar.current
            let today = Date()
            for offset in -6...0 {
                if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                    dict[date] = Int.random(in: 0...5)
                }
            }
            return dict
        }()
        let sampleTimeData = ["Morning": 3, "Afternoon": 2, "Evening": 4, "Night": 1]
        let sampleStats = BasicAnalyticsResult(cravingsPerDay: sampleData, cravingsByTimeSlot: sampleTimeData)
        let viewModel = AnalyticsDashboardViewModel(analyticsManager: AnalyticsManager(cravingManager: CravingManager()))
        viewModel.basicStats = sampleStats
        return AnalyticsDashboardView(viewModel: viewModel)
    }
}
