//
//  CRAVETabView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

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
