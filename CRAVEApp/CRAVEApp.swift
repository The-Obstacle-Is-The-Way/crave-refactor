//
//  🍒
//  CRAVEApp/CRAVEApp.swift
//  Purpose: Main entry point for the CRAVE app with SwiftData initialization.
//
//
import SwiftUI    // Imports Apple's UI framework
import SwiftData  // Imports Apple's new database framework

// @main tells Swift "Start the app here!" - like the main entrance to a building
@main
struct CRAVEApp: App {
    // This creates our app's database system (like setting up filing cabinets)
    // ModelContainer is like a big filing cabinet that holds all our app's data
    var sharedModelContainer: ModelContainer = {
        // Tell SwiftData what kind of data we want to store
        // Think of Schema like a blueprint for our filing cabinet
        let initialSchema = Schema([CravingModel.self])
        
        // Configure how we want to store data
        // isStoredInMemoryOnly: false means "save it permanently, not just in temporary memory"
        let config = ModelConfiguration(schema: initialSchema, isStoredInMemoryOnly: false)
        
        do {
            // Try to create our database container
            let container = try ModelContainer(for: initialSchema, configurations: [config])
            
            // Check if we need to update our database structure
            // (like checking if we need to add new drawers to our filing cabinet)
            let needsMigration = !UserDefaults.standard.bool(forKey: "hasMigratedToV2")
            
            if needsMigration {
                // If we need to update, do it here
                // This is like reorganizing our filing cabinet
                
                // Mark that we've done the update
                UserDefaults.standard.set(true, forKey: "hasMigratedToV2")
            }
            
            // Create our final database structure with all our data types
            // This adds all the different "drawers" to our filing cabinet
            let finalSchema = Schema([CravingModel.self, AnalyticsMetadata.self, InteractionData.self, ContextualData.self])
            
            // Create the final container with everything we need
            return try ModelContainer(for: finalSchema, configurations: [config])
        } catch {
            // If something goes wrong setting up our database, crash the app
            // (in real apps, we'd handle this more gracefully)
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // This runs when the app first starts
    init() {
        // Set up haptic feedback (the little vibrations when you tap things)
        CRAVEDesignSystem.Haptics.prepareAll()
    }
    
    // This creates the main window of our app
    var body: some Scene {
        WindowGroup {
            CRAVETabView() // Start with our main tab view
        }
        // Connect our database to our app's interface
        .modelContainer(sharedModelContainer)
    }
}

/* Key Concepts for Beginners:
1. This file is like the "main entrance" to your app - everything starts here
2. `ModelContainer` is your app's database - it stores all your data
3. `Schema` tells the database what kinds of data to expect
4. The `do-try-catch` block is like a safety net for when things might go wrong
5. `WindowGroup` creates your app's main window
6. The `init()` function runs when your app first starts up */
