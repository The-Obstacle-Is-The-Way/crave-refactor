//
//
//  🍒
//  CRAVEApp/Navigation/CRAVETabView.swift
//  Purpose: Creates the main tab navigation interface of our app
//
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    // Get access to our database from SwiftUI's environment
    // Think of this like having a key to access our data anywhere in the app
    @Environment(\.modelContext) var modelContext: ModelContext
    
    // Keep track of which tab is selected (starts at 0)
    // Like remembering which page of a book you're on
    @State private var selection: Int = 0

    var body: some View {
        // TabView is like a file folder with different tabs
        TabView(selection: $selection) {
            // Tab 1: Screen to log a new craving
            LogCravingView()
                .tabItem {
                    Label("Log Craving", systemImage: "square.and.pencil")
                }
                .tag(0)
            
            // Tab 2: List of all cravings
            CravingListView()
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }
                .tag(1)

            // Tab 3: Calendar view of cravings
            DateListView()
                .tabItem {
                    Label("Cravings by Date", systemImage: "calendar")
                }
                .tag(2)

            // Tab 4: Analytics and charts
            AnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
    }
}

