//
//  CravingListViewModel.swift
//  CRAVE
//

import SwiftUI

@MainActor
public class CravingListViewModel: ObservableObject {
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
