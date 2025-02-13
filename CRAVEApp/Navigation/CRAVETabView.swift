// CRAVETabView.swift
// Tab-based navigation for the "Log" and "History" sections.

import SwiftUI

struct CRAVETabView: View {
    var body: some View {
        TabView {
            LogCravingView()
                .tabItem {
                    Label("Log", systemImage: "plus.square.on.square")
                }

            DateListView()
                .tabItem {
                    Label("History", systemImage: "list.bullet.rectangle")
                }
        }
    }
}
