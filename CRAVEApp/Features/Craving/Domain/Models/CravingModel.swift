//
//  🍒
//  CRAVEApp/Data/Entities/CravingModel.swift
//  Purpose: Core SwiftData model for cravings.
//
//

import Foundation
import SwiftData

@Model
final class CravingModel: Identifiable {
    @Attribute(.unique) var id: UUID
    var cravingText: String
    var timestamp: Date
    var isArchived: Bool
    var intensity: Int
    var category: CravingCategory?
    var triggers: [String]
    var location: LocationData?
    var contextualFactors: [ContextualFactor]
    var createdAt: Date
    var modifiedAt: Date
    var analyticsProcessed: Bool = false // ✅ Correct: Default value

    // ✅ CORRECT RELATIONSHIP:  One-to-one (optional) with AnalyticsMetadata
    //     - deleteRule: .cascade means if a CravingModel is deleted,
    //       the associated AnalyticsMetadata is also deleted.
    //     - inverse: \AnalyticsMetadata.craving  <-- This is the CRITICAL part.
    //       It tells SwiftData that the OTHER side of this relationship
    //       is the 'craving' property on the AnalyticsMetadata class.
    @Relationship(deleteRule: .cascade, inverse: \AnalyticsMetadata.craving)
    var analyticsMetadata: AnalyticsMetadata?

    init(
        cravingText: String,
        timestamp: Date = Date(),
        intensity: Int = 0,
        category: CravingCategory? = .undefined,
        triggers: [String] = [],
        location: LocationData? = nil,
        contextualFactors: [ContextualFactor] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        analyticsProcessed: Bool = false // ✅ Default in initializer
    ) {
        self.id = UUID()
        self.cravingText = cravingText
        self.timestamp = timestamp
        self.isArchived = false
        self.intensity = intensity
        self.category = category
        self.triggers = triggers
        self.location = location
        self.contextualFactors = contextualFactors
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.analyticsProcessed = analyticsProcessed
    }

    // Validation (optional, but good practice)
    func validate() throws {
        if cravingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CravingModelError.emptyText
        }
        if intensity < 0 || intensity > 10 {
            throw CravingModelError.invalidIntensity
        }
    }
}

// MARK: - Supporting Types (Enums and Structs)

enum CravingCategory: String, Codable, CaseIterable {
    case food, drink, substance, activity, undefined
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let locationName: String?
}

struct ContextualFactor: Codable {
    let factor: String
    let impact: Impact

    enum Impact: String, Codable {
        case positive, negative, neutral
    }
}

enum CravingModelError: Error {
    case emptyText, invalidIntensity, invalidDuration, invalidCategory, invalidLocation

    var localizedDescription: String {
        switch self {
        case .emptyText:
            return "Craving text cannot be empty"
        case .invalidIntensity:
            return "Intensity must be between 0 and 10"
        case .invalidDuration:
            return "Duration must be positive"
        case .invalidCategory:
            return "Invalid category selected"
        case .invalidLocation:
            return "Invalid location data"
        }
    }
}

