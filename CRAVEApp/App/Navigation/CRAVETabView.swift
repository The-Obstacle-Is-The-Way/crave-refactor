// App/Navigation/CRAVETabView.swift
import SwiftUI

struct CRAVETabView: View {
    @EnvironmentObject private var container: DependencyContainer
    @StateObject private var coordinator: AppCoordinator

    init(container: DependencyContainer) {
        _coordinator = StateObject(wrappedValue: AppCoordinator(container: container))
        // Ensure that the AnalyticsDashboardViewModel is created here
        _ = container.makeAnalyticsDashboardViewModel() //This will be created
    }

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            CravingListView(viewModel: container.makeCravingListViewModel())
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }
                .tag(0)

            // Use the pre-created view model
            AnalyticsDashboardView(viewModel: container.makeAnalyticsDashboardViewModel())
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(1)
        }
    }
}

