//
//
//  🍒
//  CRAVEApp/AnalyticsTransformers.swift
//  Purpose:
//
//

//
//  AnalyticsTransformers.swift
//  CRAVE
//
//

import Foundation
import SwiftData

// Transformer for [UserAction]
final class UserActionsTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let actions = value as? [AnalyticsMetadata.UserAction] else { return nil }
        do {
            let data = try JSONEncoder().encode(actions)
            return data
        } catch {
            print("Failed to transform [UserAction] to Data: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let actions = try JSONDecoder().decode([AnalyticsMetadata.UserAction].self, from: data)
            return actions
        } catch {
            print("Failed to transform Data to [UserAction]: \(error)")
            return nil
        }
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    static func register() {
        let transformer = UserActionsTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: "UserActionsTransformer"))
    }
}

//Register the transformers
extension ValueTransformer {
    static func registerTransformers() {
        UserActionsTransformer.register()
    }
}
