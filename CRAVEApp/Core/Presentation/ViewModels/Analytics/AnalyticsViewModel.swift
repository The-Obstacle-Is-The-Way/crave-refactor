// Core/Presentation/ViewModels/Analytics/AnalyticsViewModel.swift
import SwiftUI
import SwiftData

@MainActor
public final class AnalyticsViewModel: ObservableObject {
    @Published public var isLoading = false
    private let manager: AnalyticsManager  // Receives the fully constructed manager

    // The ViewModel ONLY takes the AnalyticsManager.  It doesn't create anything else.
    public init(manager: AnalyticsManager) {
        self.manager = manager
    }

    // Add your analytics methods here, which now use self.manager
    // Example:
    // public func loadSomeData() async {
    //     isLoading = true
    //     do {
    //        let result = try await manager.someAnalyticsMethod()
    //        // ... process result, update @Published properties ...
    //     } catch {
    //         // Handle errors
    //     }
    //     isLoading = false
    // }
}

