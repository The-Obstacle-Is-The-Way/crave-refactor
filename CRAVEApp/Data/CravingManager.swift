//
//  CravingManager.swift
//  CRAVE
//

import Foundation
import SwiftData

public final class CravingManager {
    // Replace with your actual ModelContainer management.
    public func fetchAllCravings() async -> [CravingModel] {
        // This is a dummy fetch using the default container.
        // Replace with your own asynchronous fetching logic.
        guard let container = ModelContainer.shared else { return [] }
        return (try? container.viewContext.fetch(FetchDescriptor<CravingModel>())) ?? []
    }
    
    // Additional CRUD methods can be added here.
}
