//
//  CRAVETabView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @State private var selection = 1 // Default to Log Craving tab (assuming it's the second tab)

    var body: some View {
        TabView(selection: $selection) { // Bind selection state
            CravingListView()
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }
                .tag(0) // Tag for Cravings tab

            LogCravingView()
                .tabItem {
                    Label("Log Craving", systemImage: "square.and.pencil")
                }
                .tag(1) // Tag for Log Craving tab
                .badge(0) // Example of badge - remove if not needed

            DateListView(viewModel: DateListViewModel()) // Ensure ViewModel is passed
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(2) // Tag for Analytics tab
        }
    }
}

#Preview {
    CRAVETabView()
        .modelContainer(for: CravingModel.self, inMemory: true)
}
