//
//  CRAVEApp.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    var body: some Scene {
        WindowGroup {
            CRAVETabView() // ✅ Main entry point
                .modelContainer(for: CravingModel.self) // ✅ Ensures SwiftData persistence
                .onAppear {
                    configureGlobalAppearance() // ✅ Apply UI tweaks globally
                }
        }
    }

    // MARK: - Global UI Configuration
    private func configureGlobalAppearance() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue] // ✅ Custom navigation bar styling
    }
}
