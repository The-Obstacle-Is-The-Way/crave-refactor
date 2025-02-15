//
//  AnalyticsViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var basicStats: BasicAnalyticsResult?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var analyticsManager: AnalyticsManager?
    private var cancellables = Set<AnyCancellable>()
    
    func loadAnalytics(modelContext: ModelContext) async {
        isLoading = true
        error = nil
        
        do {
            self.analyticsManager = AnalyticsManager(modelContext: modelContext)
            
            if let manager = analyticsManager {
                self.basicStats = await manager.getBasicStats()
            }
        } catch {
            self.error = error
            print("Error loading analytics: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshData(modelContext: ModelContext) async {
        await loadAnalytics(modelContext: modelContext)
    }
}
