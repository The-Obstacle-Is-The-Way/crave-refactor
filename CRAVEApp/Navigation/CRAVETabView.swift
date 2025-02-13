//
//  CRAVETabView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) var modelContext

    var body: some View {
        TabView {
            CravingListView()
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }
            
            DateListView()
                .tabItem {
                    Label("Dates", systemImage: "calendar")
                }
            
            LogCravingView(viewModel: LogCravingViewModel(cravingManager: CravingManager(context: modelContext)))
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                }
            
            AnalyticsDashboardView(viewModel: AnalyticsDashboardViewModel(
                analyticsManager: AnalyticsManager(cravingManager: CravingManager(context: modelContext))
            ))
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
        }
    }
}

struct CRAVETabView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let container = try ModelContainer(for: CravingModel.self)
            return CRAVETabView()
                .environment(\.modelContext, container.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
