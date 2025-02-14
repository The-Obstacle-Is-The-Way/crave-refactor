//
//  CRAVETabView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            CravingListView(viewModel: CravingListViewModel(context: modelContext))
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                        .accessibilityIdentifier("Cravings")
                }
            DateListView(viewModel: DateListViewModel(context: modelContext))
                .tabItem {
                    Label("Dates", systemImage: "calendar")
                        .accessibilityIdentifier("Dates")
                }
            LogCravingView(viewModel: LogCravingViewModel(context: modelContext))
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                        .accessibilityIdentifier("Log")
                }
            AnalyticsView(viewModel: AnalyticsViewModel(
                cravingManager: CravingManager(cravingManager: modelContext)
            ))
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                        .accessibilityIdentifier("Analytics")
                }
        }
    }
}

struct CRAVETabView_Previews: PreviewProvider {
    static var previews: some View {
        CRAVETabView()
    }
}
