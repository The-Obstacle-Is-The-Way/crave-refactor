import SwiftUI


struct CRAVETabView: View {
    @EnvironmentObject private var container: DependencyContainer
    @StateObject private var coordinator: AppCoordinator = AppCoordinator(container: DependencyContainer())


    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            CravingListView(viewModel: container.makeCravingListViewModel())
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }
                .tag(0)


            container.makeAnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(1)
        }
    }
}

