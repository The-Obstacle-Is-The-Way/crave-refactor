//
//  CRAVETabView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // Create one CravingManager from the environment’s modelContext.
        let cravingManager = CravingManager(cravingManager: modelContext)
        TabView {
            CravingListView(viewModel: CravingListViewModel(cravingManager: cravingManager))
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                        .accessibilityIdentifier("Cravings")
                }
            DateListView(viewModel: DateListViewModel(cravingManager: cravingManager))
                .tabItem {
                    Label("Dates", systemImage: "calendar")
                        .accessibilityIdentifier("Dates")
                }
            LogCravingView(viewModel: LogCravingViewModel(cravingManager: cravingManager))
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                        .accessibilityIdentifier("Log")
                }
            AnalyticsView(viewModel: AnalyticsViewModel(cravingManager: cravingManager))
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                        .accessibilityIdentifier("Analytics")
                }
        }
    }
}

struct CRAVETabView_Previews: PreviewProvider {
    static var previews: some View {
        CRAVETabView()
    }
}
