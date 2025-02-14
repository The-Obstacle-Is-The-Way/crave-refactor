// CRAVEApp/CRAVEApp.swift

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    let container: ModelContainer
    
    init() {
        // Register value transformers
        registerValueTransformers()
        
        // Initialize container
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(
                for: CravingModel.self, AnalyticsMetadata.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CRAVETabView()
            }
        }
        .modelContainer(container)
    }
    
    private func registerValueTransformers() {
        // User Actions Transformer
        ValueTransformer.setValueTransformer(
            UserActionsTransformer(),
            forName: NSValueTransformerName("UserActionsTransformer")
        )
        
        // Pattern Identifiers Transformer
        ValueTransformer.setValueTransformer(
            PatternIdentifiersTransformer(),
            forName: NSValueTransformerName("PatternIdentifiersTransformer")
        )
        
        // Correlation Factors Transformer
        ValueTransformer.setValueTransformer(
            CorrelationFactorsTransformer(),
            forName: NSValueTransformerName("CorrelationFactorsTransformer")
        )
        
        // Streak Data Transformer
        ValueTransformer.setValueTransformer(
            StreakDataTransformer(),
            forName: NSValueTransformerName("StreakDataTransformer")
        )
    }
}
