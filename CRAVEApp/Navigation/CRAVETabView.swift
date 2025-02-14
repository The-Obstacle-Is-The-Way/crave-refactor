//
//  CRAVETabView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext

    var body: some View {
        let cravingManager = CravingManager(modelContext: modelContext) // ✅ Fixed initialization

        TabView {
            // Craving List
            CravingListView(viewModel: CravingListViewModel(cravingManager: cravingManager))
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                        .accessibilityIdentifier("CravingsTab")
                }

            // Log New Craving
            LogCravingView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                        .accessibilityIdentifier("LogCravingTab")
                }

            // Analytics
            AnalyticsView(viewModel: AnalyticsViewModel())
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                        .accessibilityIdentifier("AnalyticsTab")
                }
        }
    }
}

// ✅ Preview with ModelContainer
struct CRAVETabView_Previews: PreviewProvider {
    static var previews: some View {
        CRAVETabView()
            .modelContainer(for: CravingModel.self, inMemory: true) // ✅ Ensure SwiftData works in preview
    }
}
