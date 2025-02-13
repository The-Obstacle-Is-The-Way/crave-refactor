//
//  CraveApp.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@main
struct CraveApp: App {
    private let container: ModelContainer

    init() {
        do {
            let schema = Schema([CravingModel.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            
            // 🚨 RESET DATABASE IF NEEDED
            let storeURL = URL.documentsDirectory.appendingPathComponent("CRAVE.sqlite")
            if FileManager.default.fileExists(atPath: storeURL.path) {
                try FileManager.default.removeItem(at: storeURL)
                print("🗑 Deleted old SwiftData database to reset")
            }
            
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
