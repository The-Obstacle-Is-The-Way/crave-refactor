//
//  🍒
//  CRAVEApp/CRAVEApp.swift
//  Purpose: Main entry point for the CRAVE app with SwiftData initialization.
//
//

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    var sharedModelContainer: ModelContainer = {
        // Start with *only* CravingModel in the schema.
        let initialSchema = Schema([CravingModel.self])
        let config = ModelConfiguration(schema: initialSchema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: initialSchema, configurations: [config])
            // --- Migration/Conditional Model Addition ---
            // 1. Check if a migration is needed (you'd likely have a versioning system)
            //    For this example, we'll assume a simple flag.  In a real app,
            //    you'd check UserDefaults or another persistent store.
            let needsMigration = !UserDefaults.standard.bool(forKey: "hasMigratedToV2")

            if needsMigration {
                // Perform any migration steps *before* adding AnalyticsMetadata.
                // This could involve creating initial AnalyticsMetadata for existing CravingModels.
                // ... (Migration code would go here) ...

                // Example: Mark migration as complete (in a real app, use a version number)
                UserDefaults.standard.set(true, forKey: "hasMigratedToV2")
            }

            // 2.  *After* any migration, *now* add AnalyticsMetadata to the schema *if it exists*.
            //     This prevents the circular reference issue during initial schema creation.
            let finalSchema = Schema([CravingModel.self, AnalyticsMetadata.self, InteractionData.self, ContextualData.self])
            //We dont need to pass in configurations again
            return try ModelContainer(for: finalSchema, configurations: [config])


        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        CRAVEDesignSystem.Haptics.prepareAll() // Prepare haptics at app launch!
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView() // Your main view
        }
        .modelContainer(sharedModelContainer)
    }
}

