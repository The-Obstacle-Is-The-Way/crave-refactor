//
//
//  🍒
//  CRAVEApp/Navigation/CRAVETabView.swift
//  Purpose:
//
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) private var modelContext // Get the modelContext
    @State private var selection = 0 // Start with the first tab (Cravings)

    var body: some View {
        TabView(selection: $selection) {
            CravingListView()
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }
                .tag(0)

            LogCravingView()
                .tabItem {
                    Label("Log Craving", systemImage: "square.and.pencil")
                }
                .tag(1)

            DateListView()
                .tabItem {
                    Label("Cravings by Date", systemImage: "calendar") // Changed the image
                }
                .tag(2)
            
            AnalyticsDashboardView() // Added the AnalyticsDashboardView
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
    }
}

