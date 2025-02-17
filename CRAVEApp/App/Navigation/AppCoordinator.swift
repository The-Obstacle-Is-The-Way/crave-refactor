// App/Navigation/AppCoordinator.swift
import SwiftUI

public class AppCoordinator: ObservableObject {
    @Published var selectedTab: Int = 0
    private let container: DependencyContainer
    
    public init(container: DependencyContainer) {
        self.container = container
    }
    
    public func start() -> some View {
        CRAVETabView()
    }
}
