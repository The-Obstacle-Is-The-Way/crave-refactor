//
// CRAVEApp/CRAVEApp.swift
//
//

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    let container: ModelContainer

    init() {
        // Register Value Transformers *before* creating the ModelContainer.
        ValueTransformer.setValueTransformer(
            UserActionsTransformer(),
            forName: NSValueTransformerName("UserActionsTransformer")
        )
        ValueTransformer.setValueTransformer(
            PatternIdentifiersTransformer(),
            forName: NSValueTransformerName("PatternIdentifiersTransformer")
        )
        ValueTransformer.setValueTransformer(
            CorrelationFactorsTransformer(),
            forName: NSValueTransformerName("CorrelationFactorsTransformer")
        )
        ValueTransformer.setValueTransformer(
            StreakDataTransformer(),
            forName: NSValueTransformerName("StreakDataTransformer")
        )


        do {
            // Include *all* your model types here.
            let config = ModelConfiguration(isStoredInMemoryOnly: false) // Use false for on-disk persistence
            container = try ModelContainer(
                for: CravingModel.self, AnalyticsMetadata.self,
                configurations: config
            )
        } catch {
            // Handle the error appropriately.  Don't just print in a production app.
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
              CravingListView() // Assuming you have a CravingListView
            }
        }
        .modelContainer(container)
    }
}
