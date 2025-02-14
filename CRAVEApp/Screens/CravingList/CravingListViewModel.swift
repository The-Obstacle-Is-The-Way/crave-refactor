//
//  CravingListViewModel.swift
//  CRAVE
//

import SwiftUI
import SwiftData

@Observable
final class CravingListViewModel {
    @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext automatically

    // MARK: - Fetch Active Cravings
    @Query(filter: #Predicate { !$0.isArchived }) var cravings: [CravingModel] // ✅ Fetch only active cravings

    // MARK: - Soft Delete a Craving
    func archiveCraving(_ craving: CravingModel) {
        craving.isArchived = true
        saveContext() // ✅ Ensure UI updates
    }

    // MARK: - Save Changes
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
