//
//  AnalyticsViewModel.swift
//  CRAVE
//


import SwiftUI
import SwiftData
import Combine

@MainActor
final class AnalyticsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var basicStats: BasicAnalyticsResult?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var showError: Bool = false
    
    // MARK: - Private Properties
    private var analyticsManager: AnalyticsManager?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func loadAnalytics(modelContext: ModelContext) async {
        isLoading = true
        error = nil
        
        do {
            self.analyticsManager = AnalyticsManager(modelContext: modelContext)
            
            if let manager = analyticsManager {
                let stats = await manager.getBasicStats()
                await MainActor.run {
                    self.basicStats = stats
                    self.isLoading = false
                }
            } else {
                throw AnalyticsError.managerInitializationFailed
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.showError = true
                self.isLoading = false
            }
            print("Error loading analytics: \(error)")
        }
    }
    
    func refreshData(modelContext: ModelContext) async {
        await loadAnalytics(modelContext: modelContext)
    }
}

// MARK: - Supporting Types
enum AnalyticsError: LocalizedError {
    case managerInitializationFailed
    case dataProcessingFailed
    case invalidTimeRange
    case noDataAvailable
    
    var errorDescription: String? {
        switch self {
        case .managerInitializationFailed:
            return "Failed to initialize analytics manager"
        case .dataProcessingFailed:
            return "Failed to process analytics data"
        case .invalidTimeRange:
            return "Invalid time range selected"
        case .noDataAvailable:
            return "No analytics data available"
        }
    }
}

// MARK: - Preview Support
extension AnalyticsViewModel {
    static var preview: AnalyticsViewModel {
        let viewModel = AnalyticsViewModel()
        viewModel.basicStats = .preview
        return viewModel
    }
}
