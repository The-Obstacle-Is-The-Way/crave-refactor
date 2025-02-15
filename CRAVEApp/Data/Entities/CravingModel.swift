//
//
//
//  CRAVEApp/Data/Entities/CravingModel.swift
//  Purpose:
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
    var category: CravingCategory? // Made optional
    var triggers: [String] // Changed to [String]

    // Metadata (Optional, consider if really needed)
    var location: LocationData?  // Keep this optional
    var contextualFactors: [ContextualFactor] //keep

    var createdAt: Date
    var modifiedAt: Date
    var analyticsProcessed: Bool

    @Relationship(deleteRule: .cascade, inverse: \AnalyticsMetadata.craving)
    var analyticsMetadata: AnalyticsMetadata?

    init(cravingText: String,
         intensity: Int = 0, //Default value
         category: CravingCategory? = .undefined, // Made optional
         triggers: [String] = [],
         location: LocationData? = nil) { //location is now optional
        self.id = UUID()
        self.cravingText = cravingText
        self.timestamp = Date()
        self.isArchived = false
        self.intensity = intensity
        self.category = category
        self.triggers = triggers
        self.location = location
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.analyticsProcessed = false
    }

    // Validation (Example)
    func validate() throws {
        if cravingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CravingModelError.emptyText
        }
        if intensity < 0 || intensity > 10 {
            throw CravingModelError.invalidIntensity
        }
    }
}

enum CravingCategory: String, Codable, CaseIterable {
    case food
    case drink
    case substance
    case activity
    case undefined
}

// Consider moving LocationData and ContextualFactor to separate files if they grow.
struct LocationData: Codable { // Added struct for location
    let latitude: Double
    let longitude: Double
    let locationName: String? // Optional
}

struct ContextualFactor: Codable { //Added struct for contextual factors
    let factor: String
    let impact: Impact

    enum Impact: String, Codable {
        case positive
        case negative
        case neutral
    }
}

enum CravingModelError: Error {
    case emptyText
    case invalidIntensity
    case invalidDuration // No longer used, but kept in case you add duration back
    case invalidCategory // No longer used, but kept in case you add category back
    case invalidLocation

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
