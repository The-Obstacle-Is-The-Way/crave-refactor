//
//  CRAVETabView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import SwiftUI
import SwiftData

struct CRAVETabView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            CravingListView(viewModel: CravingListViewModel(context: context))
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                        .accessibilityIdentifier("Cravings")
                }
            DateListView(viewModel: DateListViewModel(context: context))
                .tabItem {
                    Label("Dates", systemImage: "calendar")
                        .accessibilityIdentifier("Dates")
                }
            LogCravingView(viewModel: LogCravingViewModel(context: context))
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                        .accessibilityIdentifier("Log")
                }
            // Note: AnalyticsViewModel expects a CravingManager instance.
            AnalyticsView(viewModel: AnalyticsViewModel(cravingManager: CravingManager()))
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
