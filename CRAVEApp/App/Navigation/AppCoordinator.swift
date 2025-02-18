// App/Navigation/AppCoordinator.swift

import SwiftUI
import Combine

public class AppCoordinator: ObservableObject {
    @Published var selectedTab: Int = 0
    private let container: DependencyContainer  // No longer private
    private var cancellables = Set<AnyCancellable>()

    public init(container: DependencyContainer) {
        self.container = container
        
    }

    public func start() -> some View {
        CRAVETabView(container: container) //Pass container
    }
}

