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
        let schema = Schema([
            CravingModel.self,
            AnalyticsMetadata.self,
            InteractionData.self, // Keep these if you have them.
            ContextualData.self   // Keep these if you have them.
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            CRAVETabView() // Your main view
        }
        .modelContainer(sharedModelContainer)
    }
}
