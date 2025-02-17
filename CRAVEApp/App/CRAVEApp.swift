import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    @StateObject private var container: DependencyContainer
    
    init() {
        let schema = Schema([
            CravingEntity.self,
            AnalyticsMetadata.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = modelContainer.mainContext
            _container = StateObject(wrappedValue: DependencyContainer(modelContext: context))
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
        
        // Initialize design system
        CRAVEDesignSystem.Haptics.prepareAll()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
                .modelContext(container.modelContext)
        }
    }
}

struct ContentView: View {
    var body: some View {
        AppCoordinator()
    }
}
