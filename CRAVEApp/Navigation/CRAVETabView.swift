//
//  CRAVETabView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) private var modelContext // ✅ Get ModelContext from Environment
    @State private var selection = 1 // Default to Log Craving tab

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

            // ✅ Pass modelContext to DateListViewModel initializer
            DateListView(viewModel: DateListViewModel(modelContext: modelContext))
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(2)
        }
    }
}

#Preview {
    CRAVETabView()
        .modelContainer(for: CravingModel.self, inMemory: true)
}


