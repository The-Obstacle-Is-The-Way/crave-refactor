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
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Craving.self)
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
