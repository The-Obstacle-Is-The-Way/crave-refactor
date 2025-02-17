// CRAVEApp/CRAVEApp.swift

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    // This creates our app's database system (like setting up filing cabinets)
    // ModelContainer is like a big filing cabinet that holds all our app's data
    var sharedModelContainer: ModelContainer = {
        // Tell SwiftData what kind of data we want to store
        // Think of Schema like a blueprint for our filing cabinet
        let initialSchema = Schema([CravingModel.self])

        // Configure how we want to store data
        // isStoredInMemoryOnly: false means "save it permanently, not just in temporary memory"
        let config = ModelConfiguration(schema: initialSchema, isStoredInMemoryOnly: false)

        do {
            // Try to create our database container
            let container = try ModelContainer(for: initialSchema, configurations: [config])

            // Check if we need to update our database structure
            // (like checking if we need to add new drawers to our filing cabinet)
            let needsMigration; =!UserDefaults.standard.bool(forKey: "hasMigratedToV2")

            if needsMigration {
                // If we need to update, do it here
                // This adds all the different "drawers" to our filing cabinet
                let finalSchema = Schema([
                    CravingModel.self,
                    AnalyticsMetadata.self,
                    InteractionData.self,
                    ContextualData.self
                ])

                // Create the final container with everything we need
                return try ModelContainer(for: finalSchema, configurations: [config])
            } else {
                return container
            }
        } catch {
            // If something goes wrong setting up our database, crash the app
            // (in real apps, we'd handle this more gracefully)
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // This runs when the app first starts
    init() {
        // Set up haptic feedback (the little vibrations when you tap things)
        CRAVEDesignSystem.Haptics.prepareAll()
    }

    // This creates the main window of our app
    var body: some Scene {
        WindowGroup {
            CRAVETabView()
              .environment(DependencyContainer(modelContext: sharedModelContainer.mainContext))
        }
        // Connect our database to our app's interface
      .modelContainer(sharedModelContainer)
    }
}
