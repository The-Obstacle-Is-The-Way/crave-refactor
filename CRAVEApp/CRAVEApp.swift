// CRAVEApp.swift
// The entry point, sets up the ModelContainer and attaches it.

import SwiftUI
import SwiftData

@main
struct CraveApp: App {
    private let container: ModelContainer

    init() {
        do {
            let schema = Schema([Craving.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)

            // Identify where SwiftData's default store lives:
            let defaultStoreURL = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!.appendingPathComponent("default.store")

            if FileManager.default.fileExists(atPath: defaultStoreURL.path) {
                // Remove any old store so there's no migration conflict
                try FileManager.default.removeItem(at: defaultStoreURL)
                print("🗑 Deleted old SwiftData store at: \(defaultStoreURL)")
            }

            // Now create a fresh container with the new Craving schema
            container = try ModelContainer(for: schema, configurations: [config])

        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .modelContainer(container)
        }
    }
}
