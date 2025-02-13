//
//  CravingListViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
class CravingListViewModel: ObservableObject {
    @Published var cravings: [CravingModel] = []
    private let cravingManager: CravingManager
    
    init(cravingManager: CravingManager) {
        self.cravingManager = cravingManager
    }
    
    func loadCravings() {
        Task {
            self.cravings = await cravingManager.fetchAllCravings()
        }
    }
}
