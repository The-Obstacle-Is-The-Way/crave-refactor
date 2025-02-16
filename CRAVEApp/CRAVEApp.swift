//
//  🍒
//  CRAVEApp/CRAVEApp.swift
//  Purpose: Main entry point for the app.
//
//

// File: CRAVEApp.swift
// Title: CRAVEApp – SwiftData & SwiftUI Best Practices Entry Point
// Description: Main entry point for the CRAVE application. This file sets up the ModelContainer for SwiftData,
// registers required value transformers before container creation, and injects the container into the SwiftUI
// environment. (No changes are needed to the metadata file.)

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    let sharedModelContainer: ModelContainer

    init() {
        // Register any value transformers BEFORE creating the container.
        ValueTransformer.setValueTransformer(UserActionsTransformer(), forName: NSValueTransformerName("UserActionsTransformer"))
        
        do {
            // Initialize the ModelContainer with your persistent models.
            // The container will automatically infer child models and handle migrations as needed.
            sharedModelContainer = try ModelContainer(
                for: CravingModel.self,
                AnalyticsMetadata.self,
                InteractionData.self,
                ContextualData.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView() // Your root view remains unchanged.
        }
        .modelContainer(sharedModelContainer)
    }
}

/*
  Additional Best Practices:
  1. Use safe optional unwrapping: Prefer optional binding or nil coalescing over force unwrapping.
  2. In your models, use a custom soft-delete flag (e.g., isArchived) rather than naming a property isDeleted,
     which conflicts with SwiftData’s internal flag.
  3. When using relationships, always explicitly define the inverse relationship to avoid crashes (as seen in iOS 17.4+).
  4. Separate your data/business logic from your SwiftUI views by abstracting data operations (e.g., using a DataProvider).
  5. The metadata file does not need to be fixed—only this application file requires these updates.
*/
