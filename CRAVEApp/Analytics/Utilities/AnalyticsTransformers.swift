//
//
//  🍒
//  CRAVEApp/Analytics/Utilities/AnalyticsTransformers.swift
//  Purpose:
//
//

import Foundation
import SwiftData

// Transformer for [UserAction]
final class UserActionsTransformer: NSSecureUnarchiveFromDataTransformer { // Inherit from NSSecureUnarchiveFromDataTransformer

    // Define the allowed class for transformation
    override class var allowedTopLevelClasses: [AnyClass] {
        return [[AnalyticsMetadata.UserAction].self]
    }

    // No need for transformedValue and reverseTransformedValue, NSSecureUnarchiveFromDataTransformer handles it

    static func register() {
        let transformerName = NSValueTransformerName(String(describing: UserActionsTransformer.self))
        let transformer = UserActionsTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: transformerName)
    }
}

//Register the transformers
extension ValueTransformer {
    static func registerTransformers() {
        UserActionsTransformer.register()
    }
}
