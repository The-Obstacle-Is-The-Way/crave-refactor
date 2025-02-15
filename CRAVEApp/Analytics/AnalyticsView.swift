//
//  CRAVEApp/Analytics/AnalyticsView.swift
//  CRAVE
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
                if let stats = viewModel.basicStats {
                    VStack(spacing: 20) {
                        // Overview Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overview")
                                .font(.title2)
                                .bold()
                            
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "Total",
                                    value: "\(stats.totalCravings)",
                                    subtitle: "Cravings"
                                )
                                
                                StatCard(
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
                        
                        // Cravings by Day Section
                        ChartSection(
                            title: "Daily Trends",
                            chart: CravingBarChart(data: stats.cravingsPerDay)
                        )
                        
                        // Time of Day Distribution
                        ChartSection(
                            title: "Time of Day Patterns",
                            chart: TimeOfDayPieChart(data: stats.cravingsByTimeSlot)
                        )
                        
                        // Activity Calendar
                        if !stats.cravingsByFrequency.isEmpty {
                            ChartSection(
                                title: "Activity Calendar",
                                chart: CalendarHeatmapView(data: stats.cravingsByFrequency)
                            )
                        }
                        
                        // Insights Section
                        if let mostActive = stats.mostActiveTimeSlot {
                            InsightsCard(stats: stats, mostActive: mostActive)
                        }
                    }
                    .padding(.vertical)
                } else {
                    LoadingView()
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
        }
    }
}

// MARK: - Supporting Views
private struct StatCard: View {
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
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

private struct ChartSection<Chart: View>: View {
    let title: String
    let chart: Chart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            chart
        }
        .padding(.vertical, 8)
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

#Preview {
    AnalyticsView()
        .modelContainer(for: CravingModel.self, inMemory: true)
}
