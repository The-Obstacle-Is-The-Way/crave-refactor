//
//  CRAVEApp.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25
//

import SwiftUI
import SwiftData

@main
struct CraveApp: App {
    @State private var modelContainer: ModelContainer
    
    init() {
        _modelContainer = State(
            wrappedValue: try! ModelContainer(for: Craving.self)
        )
    }
    
    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .modelContainer(modelContainer)
        }
    }
}
