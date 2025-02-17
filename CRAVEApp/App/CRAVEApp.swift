// App/CRAVEApp.swift
import SwiftUI

@main
struct CRAVEApp: App {
    @StateObject private var container = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .environmentObject(container)
        }
    }
}
