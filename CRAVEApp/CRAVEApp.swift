//
//  🍒
//  CRAVEApp/CRAVEApp.swift
//  Purpose: Main entry point for the app.
//
//

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    var sharedModelContainer: ModelContainer

    init() {
        // *** Register the transformer BEFORE creating the container ***
        ValueTransformer.setValueTransformer(UserActionsTransformer(), forName: NSValueTransformerName("UserActionsTransformer"))

        do {
            sharedModelContainer = try ModelContainer(
                for: CravingModel.self,
                AnalyticsMetadata.self,
                InteractionData.self,
                ContextualData.self
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }


    var body: some Scene {
        WindowGroup {
            CRAVETabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
