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
        do {
            // Create an in-memory ModelContainer for preview purposes.
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: [CravingModel.self], configurations: [config])
            // Retrieve the preview context.
            let context = container.mainContext
            // Instantiate CravingManager using its new initializer.
            let cravingManager = CravingManager(cravingManager: context)
            // Create the AnalyticsViewModel with the CravingManager.
            let viewModel = AnalyticsViewModel(cravingManager: cravingManager)
            // Inject the container into the view's environment.
            return AnalyticsView(viewModel: viewModel)
                .modelContainer(container)
        } catch {
            return Text("Failed to create preview: \(error.localizedDescription)")
        }
    }
}
