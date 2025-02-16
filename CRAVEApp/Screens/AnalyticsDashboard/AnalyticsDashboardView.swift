//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/AnalyticsDashboardView.swift
//  Purpose: Displays analytics data in a SwiftUI view.
//


import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    @StateObject private var viewModel = AnalyticsDashboardViewModel()

    var body: some View {
        VStack {
            if let stats = viewModel.basicStats {
                // ... your existing code ...
            } else {
                ProgressView("Loading Analytics...")
            }
        }
        .navigationTitle("Analytics")
        .onAppear {
            viewModel.loadAnalytics(modelContext: modelContext)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CravingModel.self, configurations: config)

        // Insert sample data
        let sampleCraving = CravingModel(cravingText: "Preview Craving")
        container.mainContext.insert(sampleCraving)

        return AnalyticsDashboardView()
            .environment(\.modelContext, container.mainContext)
    } catch {
        fatalError("Failed to create model container: \(error)")
    }
}

