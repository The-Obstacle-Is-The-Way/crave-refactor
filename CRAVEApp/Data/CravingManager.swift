//
//  CravingManager.swift
//  CRAVE
//

import SwiftData
import Foundation

@MainActor
final class CravingManager {
    static let shared = CravingManager()
    private init() {}

    /// 🚀 Add a new craving to SwiftData
    func addCraving(_ text: String, using context: ModelContext) -> Bool {
        let newCraving = Craving(text)
        context.insert(newCraving)
        return save(context, action: "adding craving")
    }

    /// 🚀 Soft-delete a craving by marking `isDeleted = true`
    func softDeleteCraving(_ craving: Craving, using context: ModelContext) -> Bool {
        print("🔹 Before soft delete: \(craving.text) | isDeleted: \(craving.isDeleted)")

        craving.isDeleted = true
        let success = save(context, action: "soft-deleting craving")

        // 🚀 Force SwiftData to commit changes
        RunLoop.current.run(until: Date().addingTimeInterval(1.0))

        // 🚀 Fetch the craving again to verify if `isDeleted` is really updated
        let refetched = fetchCravings(using: context, includingDeleted: true)
            .first { $0.id == craving.id }

        print("✅ After soft delete: \(refetched?.text ?? "N/A") | isDeleted: \(refetched?.isDeleted ?? false)")

        return success
    }

    /// 🚀 Permanently delete a craving
    func permanentlyDeleteCraving(_ craving: Craving, using context: ModelContext) -> Bool {
        context.delete(craving)
        return save(context, action: "permanently deleting craving")
    }

    /// 🚀 Fetch cravings, optionally including soft-deleted ones
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

    /// 🚀 Save changes and print debugging info
    private func save(_ context: ModelContext, action: String) -> Bool {
        do {
            try context.save()
            let all = try context.fetch(FetchDescriptor<Craving>())
            print("📌 After \(action), total cravings: \(all.count)")
            all.forEach { c in
                print("📝 Craving \(c.id) -> isDeleted: \(c.isDeleted), text: \(c.text)")
            }
            return true
        } catch {
            print("❌ SwiftData save error while \(action): \(error)")
            return false
        }
    }
}
