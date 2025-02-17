import SwiftUI

@main
struct CRAVEApp: App {
    let container: DependencyContainer

    init() {
        let modelContainer = try! ModelContainer(for: [CravingEntity.self, AnalyticsMetadata.self])
        let context = modelContainer.mainContext
        container = DependencyContainer(modelContext: context)
    }
    
    var body: some Scene {
        WindowGroup {
            AppCoordinator().start()
                .environmentObject(container)
        }
    }
}

