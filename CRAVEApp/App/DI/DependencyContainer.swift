// DependencyContainer.swift

import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()
    
    let cravingRepository: CravingRepository

    private init() {
        self.cravingRepository = CravingRepositoryImpl()
    }
}
