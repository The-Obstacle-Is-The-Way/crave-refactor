//  CRAVEApp/Navigation/CRAVETabView.swift

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        TabView {
            LogCravingView(viewModel: container.logCravingViewModel)
              .tabItem {
                    Label("Log Craving", systemImage: "square.and.pencil")
                }

            CravingListView(viewModel: container.cravingListViewModel)
              .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }

            DateListView(viewModel: container.dateListViewModel)
              .tabItem {
                    Label("Cravings by Date", systemImage: "calendar")
                }

            AnalyticsDashboardView(viewModel: container.analyticsDashboardViewModel)
              .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
        }
    }
}
