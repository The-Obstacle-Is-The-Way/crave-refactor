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
    let sharedModelContainer: ModelContainer

    init() {
        // 1. Register any value transformers BEFORE creating the container.
        ValueTransformer.setValueTransformer(
            UserActionsTransformer(),
            forName: NSValueTransformerName("UserActionsTransformer")
        )

        do {
            // 2. Initialize the ModelContainer with your SwiftData models.
            //    IMPORTANT: Include *all* your @Model classes here.
            sharedModelContainer = try ModelContainer(
                for: CravingModel.self,
                AnalyticsMetadata.self,
                InteractionData.self, // Assuming you have this
                ContextualData.self  // Assuming you have this
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView() // Your main view
        }
        .modelContainer(sharedModelContainer) // Inject the container
    }
}

/*
  Additional Best Practices:
  1.  For new properties, provide default values OR make them optional.
  2.  Avoid naming properties "isDeleted" (SwiftData uses this internally).
  3.  ALWAYS define BOTH sides of a two-way relationship with `inverse:`.
*/
