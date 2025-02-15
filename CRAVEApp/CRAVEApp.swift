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
             container: ModelContainer(for: CravingModel.self, AnalyticsMetadata.self, InteractionData.self, ContextualData.self, configurations: ModelConfiguration())
            // Register Value Transformers *before* creating the ModelContainer
            ValueTransformer.registerTransformers()
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .modelContainer(container) // Use the container created in init
        }
    }
}

