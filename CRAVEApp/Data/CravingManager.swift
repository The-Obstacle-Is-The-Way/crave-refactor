// CravingManager.swift
// CRAVE

import SwiftData
import Foundation

@MainActor
final class CravingManager {
    static let shared = CravingManager()
    private init() {}

    func addCraving(_ text: String, using context: ModelContext) -> Bool {
        let newCraving = Craving(text)
        context.insert(newCraving)
        return save(context, action: "adding craving")
    }

    func softDeleteCraving(_ craving: Craving, using context: ModelContext) -> Bool {
        craving.isDeleted = true
        let success = save(context, action: "soft-deleting craving")
        RunLoop.current.run(until: Date().addingTimeInterval(0.5)) // Ensure sufficient delay
        return success
    }

    func permanentlyDeleteCraving(_ craving: Craving, using context: ModelContext) -> Bool {
        context.delete(craving)
        return save(context, action: "permanently deleting craving")
    }

    func fetchCravings(using context: ModelContext, includingDeleted: Bool = false) -> [Craving] {
        let descriptor: FetchDescriptor<Craving>
        if includingDeleted {
            descriptor = FetchDescriptor<Craving>()
        } else {
            descriptor = FetchDescriptor<Craving>(predicate: #Predicate { !$0.isDeleted })
        }
        do {
            return try context.fetch(descriptor)
        } catch {
            print("SwiftData fetch error: \(error)")
            return []
        }
    }

    private func save(_ context: ModelContext, action: String) -> Bool {
        do {
            try context.save()
            let all = try context.fetch(FetchDescriptor<Craving>())
            print("After \(action), total cravings: \(all.count)")
            all.forEach { c in
                print("Craving \(c.id) -> isDeleted: \(c.isDeleted), text: \(c.text)")
            }
            return true
        } catch {
            print("SwiftData save error while \(action): \(error)")
            return false
        }
    }
}
