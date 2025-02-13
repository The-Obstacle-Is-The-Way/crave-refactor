//
//  CRAVETabView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import SwiftUI
import SwiftData

public struct CRAVETabView: View {
    public init() { }
    
    public var body: some View {
        TabView {
            LogCravingView()
                .tabItem {
                    Label("Log", systemImage: "square.and.pencil")
                }
            CravingListView()
                .tabItem {
                    Label("Cravings", systemImage: "list.bullet")
                }
            DateListView()
                .tabItem {
                    Label("Dates", systemImage: "calendar")
                }
            AnalyticsDashboardView(
                viewModel: AnalyticsDashboardViewModel(
                    analyticsManager: AnalyticsManager(
                        cravingManager: CravingManager()
                    )
                )
            )
            .tabItem {
                Label("Analytics", systemImage: "chart.bar")
            }
        }
    }
}

struct CRAVETabView_Previews: PreviewProvider {
    public static var previews: some View {
        CRAVETabView()
    }
}
