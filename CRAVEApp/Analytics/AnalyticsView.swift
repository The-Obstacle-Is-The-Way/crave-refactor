//
//  AnalyticsView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @StateObject var viewModel: AnalyticsViewModel

    var body: some View {
        VStack {
            if let stats = viewModel.basicStats {
                Text("Cravings Per Day: \(stats.cravingsPerDay.description)")
                Text("Cravings by Time Slot: \(stats.cravingsByTimeSlot.description)")
            } else {
                ProgressView("Loading analytics...")
            }
        }
        .onAppear {
            viewModel.loadAnalytics()
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an in-memory ModelContainer for preview purposes.
        let container = try! ModelContainer(for: [CravingModel.self],
                                            configurations: [.init(isStoredInMemoryOnly: true)])
        // Explicitly cast container.mainContext to ModelContext.
        let context = container.mainContext as ModelContext
        // Instantiate CravingManager using its initializer that takes a ModelContext.
        let cravingManager = CravingManager(context: context)
        // Create the AnalyticsViewModel with the CravingManager.
        let viewModel = AnalyticsViewModel(cravingManager: cravingManager)
        // Inject the container into the view's environment.
        return AnalyticsView(viewModel: viewModel)
            .modelContainer(container)
    }
}
