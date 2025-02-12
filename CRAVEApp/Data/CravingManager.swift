//
//  ContentManager.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import UIKit
import SwiftUI
import Foundation
import SwiftData

final class CravingManager {
    static let shared = CravingManager()

    private init() {}

    func addCraving(_ text: String, using context: ModelContext) {
        let newCraving = Craving(text: text)
        context.insert(newCraving)
        do {
            try context.save()
        } catch {
            print("SwiftData save error: \(error)")
        }
    }

    func softDeleteCraving(_ craving: Craving, using context: ModelContext) {
        craving.isDeleted = true
        do {
            try context.save()
        } catch {
            print("SwiftData save error: \(error)")
        }
    }
}
