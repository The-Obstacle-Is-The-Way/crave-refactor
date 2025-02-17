// App/CRAVEApp.swift
import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    @StateObject private var container: DependencyContainer
    
    init() {
        _container = StateObject(wrappedValue: DependencyContainer())
    }
    
    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .environmentObject(container)
        }
    }
}
