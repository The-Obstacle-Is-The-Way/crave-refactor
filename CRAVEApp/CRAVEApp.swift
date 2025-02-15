//
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
                for: CravingModel.self, AnalyticsMetadata.self, ContextualData.self, InteractionData.self,
                configurations: config
            )
        } catch {
            // Handle the error appropriately.  Don't just print in a production app.
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView() // Changed to use the main tab view
        }
        .modelContainer(container)
    }
}

// MARK: - Value Transformers - Moved here for registration

final class UserActionsTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSData.self  // Corrected
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let actions = value as? [AnalyticsMetadata.UserAction] else { return nil }
        return try? JSONEncoder().encode(actions) as NSData
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil } // Corrected type
        return try? JSONDecoder().decode([AnalyticsMetadata.UserAction].self, from: data)
    }
}

final class PatternIdentifiersTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSData.self // Corrected
    }
    override class func allowsReverseTransformation() -> Bool { // Corrected
        return true
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let patterns = value as? [String] else { return nil }
        return try? JSONEncoder().encode(patterns) as NSData
    }
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }  // Corrected type
        return try? JSONDecoder().decode([String].self, from: data)
    }
}

final class CorrelationFactorsTransformer: ValueTransformer { // Added NSSecureCoding
    override class func transformedValueClass() -> AnyClass {
        return NSData.self // Corrected
    }

     override class func allowsReverseTransformation() -> Bool { // Corrected
        return true
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let factors = value as? [AnalyticsMetadata.CorrelationFactor] else { return nil }
        return try? JSONEncoder().encode(factors) as NSData
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil } // Corrected type
        return try? JSONDecoder().decode([AnalyticsMetadata.CorrelationFactor].self, from: data)
    }
}

final class StreakDataTransformer: ValueTransformer { // Added NSSecureCoding
    override class func transformedValueClass() -> AnyClass {
        return NSData.self // Corrected
    }

    override class func allowsReverseTransformation() -> Bool { // Corrected
        return true
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let streakData = value as? AnalyticsMetadata.StreakData else { return nil }
        return try? JSONEncoder().encode(streakData) as NSData
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil } // Corrected type
        return try? JSONDecoder().decode(AnalyticsMetadata.StreakData.self, from: data)
    }
}
