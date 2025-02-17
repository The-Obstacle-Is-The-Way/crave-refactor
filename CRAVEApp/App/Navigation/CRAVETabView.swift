// App/Navigation/CRAVETabView.swift
import SwiftUI

public struct CRAVETabView: View {
    private let container: DependencyContainer
    
    public init(container: DependencyContainer = DependencyContainer()) {
        self.container = container
    }
    
    public var body: some View {
        TabView {
            container.makeAnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
            
            // Other tabs can be added here
            // Each using container.makeXXXView()
        }
    }
}
