//
//  🍒
//  CRAVEApp/Data/Entities/CravingModel.swift
//  Purpose: Defines what a craving is and how it's stored in our database
//

import Foundation
import SwiftData

// @Model tells SwiftData "this is something we want to save in our database"
// Think of this like designing a form that collects specific information
@Model
final class CravingModel: Identifiable {
    // Every craving has a unique ID (like a social security number)
    // @Attribute(.unique) means "make sure no two cravings have the same ID"
    @Attribute(.unique) var id: UUID
    
    // Basic information about the craving
    var cravingText: String      // What the craving was for
    var timestamp: Date          // When it happened
    var isArchived: Bool         // Whether it's archived or not
    var intensity: Int           // How strong the craving was (1-10)
    var category: CravingCategory?  // What kind of craving (food, drink, etc.)
    var triggers: [String]       // What caused the craving
    var location: LocationData?  // Where you were
    var contextualFactors: [ContextualFactor]  // What was happening when you had the craving
    
    // Timestamps for tracking
    var createdAt: Date        // When the craving was first created
    var modifiedAt: Date       // When it was last changed
    var analyticsProcessed: Bool = false  // Whether we've analyzed this craving yet

    // This is how we create a new craving
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
        analyticsProcessed: Bool = false
    ) {
        self.id = UUID()  // Create a new unique ID
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

    // Make sure the craving data is valid
    func validate() throws {
        // Make sure the craving text isn't empty
        if cravingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CravingModelError.emptyText
        }
        // Make sure intensity is between 0 and 10
        if intensity < 0 || intensity > 10 {
            throw CravingModelError.invalidIntensity
        }
    }
}

// Different types of cravings we can track
enum CravingCategory: String, Codable, CaseIterable {
    case food, drink, substance, activity, undefined
}

// Information about where a craving happened
struct LocationData: Codable {
    var latitude: Double
    var longitude: Double
    var locationName: String?

    // Special keys for saving/loading location data
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, locationName
    }

    // Create location data from saved information
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        locationName = try container.decodeIfPresent(String.self, forKey: .locationName)
    }

    // Save location data
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(locationName, forKey: .locationName)
    }
    
    // Create a new location
    init(latitude: Double, longitude: Double, locationName: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
    }
}

// Information about what was happening during a craving
struct ContextualFactor: Codable {
    let factor: String
    let impact: Impact

    enum Impact: String, Codable {
        case positive, negative, neutral
    }
}

// Possible errors when creating or modifying a craving
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
