//
//  CravingListViewModel.swift
//  CRAVE
//

import SwiftUI
import Foundation

@Observable
class CravingListViewModel {
    var cravings: [Craving] = []

    func setData(_ fetchedCravings: [Craving]) {
        cravings = fetchedCravings.filter { !$0.isDeleted }
    }
}
