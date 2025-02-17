
// Update AnalyticsDashboardView.swift
import SwiftUI

public struct AnalyticsDashboardView: View {
    @StateObject private var viewModel: AnalyticsDashboardViewModel
    
    public init(viewModel: AnalyticsDashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack {
            if let stats = viewModel.basicStats {
                // Your analytics dashboard UI
                Text("Total Cravings: \(stats.totalCravings)")
            } else {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadAnalytics()
        }
    }
}
