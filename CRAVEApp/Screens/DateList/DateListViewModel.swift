// DateListViewModel.swift

import SwiftUI

@MainActor
public class DateListViewModel: ObservableObject {
    @Published public var cravings: [CravingModel] = []
    
    private let cravingManager: CravingManager
    
    public init(cravingManager: CravingManager) {
        self.cravingManager = cravingManager
    }
    
    public func loadCravings() {
        Task {
            self.cravings = await cravingManager.fetchAllCravings()
        }
    }
}
