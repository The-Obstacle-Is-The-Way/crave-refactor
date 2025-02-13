// DateListViewModel.swift

import SwiftUI
import SwiftData

@MainActor
class DateListViewModel: ObservableObject {
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
