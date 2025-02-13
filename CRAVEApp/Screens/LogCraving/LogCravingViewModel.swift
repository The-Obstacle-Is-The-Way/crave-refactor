//
//  LogCravingViewModel.swift
//  CRAVE
//

import SwiftUI

@MainActor
public class LogCravingViewModel: ObservableObject {
    @Published public var currentCraving: CravingModel?
    @Published public var typedText: String = ""
    
    private let cravingManager: CravingManager
    
    public init(cravingManager: CravingManager = CravingManager()) {
        self.cravingManager = cravingManager
    }
    
    public func logCraving() {
        let newCraving = CravingModel(timestamp: Date(), notes: typedText)
        currentCraving = newCraving
        // Insert saving logic if needed:
        // Task { await cravingManager.saveCraving(newCraving) }
        typedText = ""
    }
}
