//
//  CraveApp.swift
//  CRAVE
//
//  Created by Your Name on 2/12/25.
//

import UIKit
import SwiftUI
import Foundation
import SwiftData

@main
struct CraveApp: App {
    @State private var modelContainer: ModelContainer

    init() {
        // We force-try (!) here, but you could do a do/catch if you prefer
        // more explicit error handling.
        _modelContainer = State(wrappedValue: try! ModelContainer(for: Craving.self))
    }

    var body: some Scene {
        WindowGroup {
            CRAVETabView()
                .modelContainer(modelContainer)
        }
    }
}
