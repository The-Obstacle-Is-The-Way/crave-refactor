//
//  CravingListViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@MainActor
final class CravingListViewModel: ObservableObject {
    @Environment(\.modelContext) private var modelContext

    @Published var cravings: [CravingModel] = [] // ✅ Convert to @Published
    
    init() {
        fetchCravings() // ✅ Load cravings manually
    }

    func fetchCravings() {
        do {
            let descriptor = FetchDescriptor<CravingModel>(predicate: #Predicate { !$0.isArchived })
            cravings = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching cravings: \(error)")
        }
    }
}
