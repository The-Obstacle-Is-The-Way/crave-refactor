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
            // Create a ModelContainer using the proper initializer with your model type.
            let container = try ModelContainer(for: CravingModel.self)
            let dummyContext = container.mainContext
            let dummyCravingManager = CravingManager(context: dummyContext)
            let dummyAnalyticsManager = AnalyticsManager(cravingManager: dummyCravingManager)
            return AnalyticsDashboardView(viewModel: AnalyticsDashboardViewModel(analyticsManager: dummyAnalyticsManager))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
