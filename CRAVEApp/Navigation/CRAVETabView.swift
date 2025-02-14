import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            // Craving List – note that we now call CravingListView() with no parameters.
            CravingListView()
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
            
            // Analytics – AnalyticsView requires a view model.
            AnalyticsView(viewModel: AnalyticsViewModel())
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                        .accessibilityIdentifier("AnalyticsTab")
                }
        }
    }
}

struct CRAVETabView_Previews: PreviewProvider {
    static var previews: some View {
        CRAVETabView()
            .modelContainer(for: CravingModel.self, inMemory: true) // Preview configuration for SwiftData
    }
}
