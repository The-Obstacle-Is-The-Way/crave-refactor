//
//
//  🍒
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
    var category: CravingCategory?
    var triggers: [String]

    var location: LocationData?
    var contextualFactors: [ContextualFactor]

    var createdAt: Date
    var modifiedAt: Date
    var analyticsProcessed: Bool

    @Relationship(deleteRule: .cascade, inverse: \AnalyticsMetadata.craving)
    var analyticsMetadata: AnalyticsMetadata?

    init(cravingText: String,
         timestamp: Date = Date(),
         intensity: Int = 0,
         category: CravingCategory? = .undefined,
         triggers: [String] = [],
         location: LocationData? = nil,
         contextualFactors: [ContextualFactor] = [], // Initialize here
         createdAt: Date = Date(),
         modifiedAt: Date = Date(),
         analyticsProcessed: Bool = false) {
        
        self.id = UUID()
        self.cravingText = cravingText
        self.timestamp = timestamp
        self.isArchived = false
        self.intensity = intensity
        self.category = category
        self.triggers = triggers
        self.location = location
        self.contextualFactors = contextualFactors // Assign to property
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.analyticsProcessed = analyticsProcessed
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

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let locationName: String? // Optional
}

struct ContextualFactor: Codable {
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
