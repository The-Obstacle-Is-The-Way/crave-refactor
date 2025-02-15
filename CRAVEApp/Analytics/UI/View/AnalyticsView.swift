//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsView.swift
//  Purpose: 
//
//


import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    LoadingView()
                } else if let stats = viewModel.basicStats {
                    VStack(spacing: 20) {
                        // Overview Card
                        OverviewCard(stats: stats)
                        
                        // Daily Trends
                        ChartSection(
                            title: "Daily Trends",
                            subtitle: "Cravings logged per day"
                        ) {
                            CravingBarChart(data: stats.cravingsPerDay)
                        }
                        
                        // Time Distribution
                        ChartSection(
                            title: "Time Distribution",
                            subtitle: "When cravings occur most often"
                        ) {
                            TimeOfDayPieChart(data: stats.cravingsByTimeSlot)
                        }
                        
                        // Activity Calendar
                        if !stats.cravingsByFrequency.isEmpty {
                            ChartSection(
                                title: "Activity Calendar",
                                subtitle: "Your craving patterns over time"
                            ) {
                                CalendarHeatmapView(data: stats.cravingsByFrequency)
                            }
                        }
                        
                        // Insights
                        if let mostActive = stats.mostActiveTimeSlot {
                            InsightsCard(stats: stats, mostActive: mostActive)
                        }
                    }
                    .padding(.vertical)
                } else {
                    EmptyStateView()
                }
            }
            .navigationTitle("Analytics")
            .refreshable {
                await viewModel.loadAnalytics(modelContext: modelContext)
            }
            .onAppear {
                Task {
                    await viewModel.loadAnalytics(modelContext: modelContext)
                }
            }
            .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.error) { _ in
                Button("OK") {}
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - Supporting Views
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Analytics...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Data Available")
                .font(.headline)
            
            Text("Start logging your cravings to see analytics")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OverviewCard: View {
    let stats: BasicAnalyticsResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.title2)
                .bold()
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Total",
                    value: "\(stats.totalCravings)",
                    subtitle: "Cravings"
                )
                
                StatItem(
                    title: "Daily Avg",
                    value: String(format: "%.1f", stats.averageCravingsPerDay),
                    subtitle: "Cravings"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct StatItem: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ChartSection<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    
    init(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .bold()
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            content
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct InsightsCard: View {
    let stats: BasicAnalyticsResult
    let mostActive: (slot: String, count: Int)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Insights")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                InsightRow(
                    icon: "clock",
                    title: "Peak Time",
                    value: "\(mostActive.slot) (\(mostActive.count) cravings)"
                )
                
                InsightRow(
                    icon: "calendar",
                    title: "Total Tracked",
                    value: "\(stats.totalCravings) cravings"
                )
                
                if stats.averageCravingsPerDay > 0 {
                    InsightRow(
                        icon: "chart.bar",
                        title: "Daily Average",
                        value: String(format: "%.1f cravings", stats.averageCravingsPerDay)
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .bold()
        }
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: CravingModel.self, inMemory: true)
}
