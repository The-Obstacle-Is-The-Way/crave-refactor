//
//  CRAVEApp.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@main
struct CRAVEApp: App {
    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .modelContainer(for: CravingModel.self)  // This is the key - simpler initialization
                .onAppear {
                    configureGlobalAppearance()
                }
        }
    }
    
    private func configureGlobalAppearance() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
    }
}
