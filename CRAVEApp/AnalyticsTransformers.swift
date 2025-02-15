//
//
//  🍒
//  CRAVEApp/AnalyticsTransformers.swift
//  Purpose:
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
}
  
// Transformer for [String] (PatternIdentifiers)
final class PatternIdentifiersTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let stringArray = value as? [String] else { return nil }
        do{
            let data = try JSONEncoder().encode(stringArray)
            return data
        } catch {
            print("Failed to transform [String] to Data: \(error)")
            return nil
        }
    }
  
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let stringArray = try JSONDecoder().decode([String].self, from: data)
            return stringArray
        } catch {
            print("Failed to transform Data to [String]: \(error)")
            return nil
        }
    }
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
}
  
// Transformer for [CorrelationFactor]
final class CorrelationFactorsTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let factors = value as? [AnalyticsMetadata.CorrelationFactor] else { return nil }
        do {
            let data = try JSONEncoder().encode(factors)
            return data
        } catch {
            print("Failed to transform [CorrelationFactor] to Data: \(error)")
            return nil
        }
    }
  
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let factors = try JSONDecoder().decode([AnalyticsMetadata.CorrelationFactor].self, from: data)
            return factors
        } catch {
            print("Failed to transform Data to [CorrelationFactor]: \(error)")
            return nil
        }
    }
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
}
  
// Transformer for StreakData
final class StreakDataTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let streakData = value as? AnalyticsMetadata.StreakData else { return nil }
        do {
            let data = try JSONEncoder().encode(streakData)
            return data
        } catch {
            print("Failed to transform StreakData to Data: \(error)")
            return nil
        }
    }
  
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let streakData = try JSONDecoder().decode(AnalyticsMetadata.StreakData.self, from: data)
            return streakData
        } catch {
            print("Failed to transform Data to StreakData: \(error)")
            return nil
        }
    }
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
}
  
//Register the transformers
extension ValueTransformer {
    static var userActionsTransformer: UserActionsTransformer  { UserActionsTransformer() }
    static var patternIdentifiersTransformer: PatternIdentifiersTransformer  { PatternIdentifiersTransformer() }
    static var correlationFactorsTransformer: CorrelationFactorsTransformer  { CorrelationFactorsTransformer() }
    static var streakDataTransformer: StreakDataTransformer { StreakDataTransformer() }
    static func registerTransformers() {
        ValueTransformer.setValueTransformer(UserActionsTransformer(), forName: NSValueTransformerName("UserActionsTransformer"))
        ValueTransformer.setValueTransformer(PatternIdentifiersTransformer(), forName: NSValueTransformerName("PatternIdentifiersTransformer"))
        ValueTransformer.setValueTransformer(CorrelationFactorsTransformer(), forName: NSValueTransformerName("CorrelationFactorsTransformer"))
        ValueTransformer.setValueTransformer(StreakDataTransformer(), forName: NSValueTransformerName("StreakDataTransformer"))
    }
}
