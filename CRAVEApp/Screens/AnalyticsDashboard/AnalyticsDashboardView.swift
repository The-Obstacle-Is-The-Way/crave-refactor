// AnalyticsDashboardView.swift

import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @StateObject var viewModel: AnalyticsDashboardViewModel
    
    var body: some View {
        VStack {
            if let stats = viewModel.basicStats {
                Text("Cravings by Day")
                    .font(.headline)
                List(stats.cravingsPerDay.sorted(by: { $0.key < $1.key }), id: \.key) { date, count in
                    Text("\(date.formattedDate()): \(count)")
                }
                
                Text("Time of Day")
                    .font(.headline)
                List(stats.cravingsByTimeSlot.sorted(by: { $0.key < $1.key }), id: \.key) { slot, count in
                    Text("\(slot): \(count)")
                }
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
    static var previews: some View {
        do {
            let _ = try ModelContainer(for: CravingModel.self)  // Use _ to explicitly ignore
            let dummyCravingManager = CravingManager()
            let dummyAnalyticsManager = AnalyticsManager(cravingManager: dummyCravingManager)
            return AnalyticsDashboardView(viewModel: AnalyticsDashboardViewModel(analyticsManager: dummyAnalyticsManager))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
