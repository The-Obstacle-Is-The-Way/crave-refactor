
// Update CRAVEApp.swift
import SwiftUI

@main
struct CRAVEApp: App {
    let container = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            CRAVETabView(container: container)
        }
    }
}

