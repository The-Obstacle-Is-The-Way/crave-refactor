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
    let container: ModelContainer

    init() {
        do {
            // Register value transformers before creating the container.
            ValueTransformer.registerTransformers()
            container = try ModelContainer(
                for: CravingModel.self,
                AnalyticsMetadata.self,
                InteractionData.self,
                ContextualData.self,
                configurations: ModelConfiguration() // Explicit configuration is required!
            )
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .modelContainer(container) // Inject the container into the view hierarchy.
        }
    }
}
