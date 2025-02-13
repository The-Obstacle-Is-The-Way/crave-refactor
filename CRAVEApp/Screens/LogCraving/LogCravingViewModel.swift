//
//  LogCravingViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
class LogCravingViewModel: ObservableObject {
    @Published var note: String = ""
    @Published var intensity: Int = 5
    
    private let cravingManager: CravingManager
    
    // Now, you must inject a CravingManager instance (e.g. from your app's environment or parent view)
    init(cravingManager: CravingManager) {
        self.cravingManager = cravingManager
    }
    
    func saveCraving() {
        let newCraving = CravingModel(intensity: intensity, note: note)
        cravingManager.insert(newCraving)
        // Reset inputs after saving
        note = ""
        intensity = 5
    }
}
