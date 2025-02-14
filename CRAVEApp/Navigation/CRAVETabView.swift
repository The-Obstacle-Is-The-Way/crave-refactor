//
//  CRAVETabView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    var body: some View {
        TabView {
            // Craving List
            CravingListView()
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }

            // Log New Craving
            LogCravingView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                }

            // Analytics
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
        }
    }
}

struct CRAVETabView_Previews: PreviewProvider {
    static var previews: some View {
        CRAVETabView()
            .modelContainer(for: CravingModel.self, inMemory: true)
    }
}
