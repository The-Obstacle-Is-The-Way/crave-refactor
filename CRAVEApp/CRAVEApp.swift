// CRAVEApp/CRAVEApp.swift

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    var sharedModelContainer: ModelContainer = {
        let initialSchema = Schema([CravingModel.self]) // Make sure CravingModel exists
        let config = ModelConfiguration(schema: initialSchema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: initialSchema, configurations: [config])
            // Check if this is the first launch and create historical data if needed
            if UserDefaults.standard.bool(forKey: "FirstLaunch") == false {
                Task {
                    await createHistoricalData(in: container.mainContext)
                    UserDefaults.standard.set(true, forKey: "FirstLaunch")
                }
            }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // Create the DependencyContainer here, ONCE.
    var dependencyContainer: DependencyContainer

    init() {
        // Set up haptic feedback (the little vibrations when you tap things)
        CRAVEDesignSystem.Haptics.prepareAll()
        // Initialize dependency container with the main context
        dependencyContainer = DependencyContainer(modelContext: sharedModelContainer.mainContext)
        ValueTransformer.registerTransformers()
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .environment(dependencyContainer) // Pass the container down
        }
        .modelContainer(sharedModelContainer)
    }

    // Function to create some initial data
    func createHistoricalData(in context: ModelContext) async {
        let historicalCravings = [
            "Chocolate Cake", "Pizza", "Ice Cream", "French Fries", "Potato Chips"
        ]

        for cravingText in historicalCravings {
            let newCraving = CravingModel(cravingText: cravingText)
            context.insert(newCraving)
        }

        do {
            try context.save()
        } catch {
            print("Error saving historical data: \(error)")
        }
    }
}
