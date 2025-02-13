//
//  CRAVEApp.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25
//

import SwiftUI
import SwiftData

@main
struct CraveApp: App {
    @State private var modelContainer: ModelContainer
    
    init() {
        do {
            let container = try ModelContainer(for: Craving.self)
            _modelContainer = State(wrappedValue: container)
        } catch {
            // If model container initialization fails, handle it gracefully
            // For a real-world app, you might show an alert or attempt a fallback.
            // Here, we'll stop execution in debug builds to make the issue obvious:
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .modelContainer(modelContainer)
        }
    }
}
