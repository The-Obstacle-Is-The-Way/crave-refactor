// App/Navigation/CRAVETabView.swift
import SwiftUI

public struct CRAVETabView: View {
    @StateObject private var container: DependencyContainer
    
    public init() async {
        let container = await DependencyContainer()
        _container = StateObject(wrappedValue: container)
    }
    
    public var body: some View {
        TabView {
            container.makeAnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
        }
    }
}
