// CravingListViewModel.swift
// Use if you want specialized logic for a date’s cravings.

import SwiftUI
import SwiftData
import Foundation

@Observable
class CravingListViewModel {
    var cravings: [Craving] = []

    func setData(_ fetchedCravings: [Craving]) {
        cravings = fetchedCravings.filter { !$0.isDeleted }
    }
}
