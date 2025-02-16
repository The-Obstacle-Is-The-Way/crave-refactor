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
    var analyticsProcessed: Bool = false

    // NO relationship to AnalyticsMetadata here.

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

// Supporting enums and structs - kept for completeness, made Codable
enum CravingCategory: String, Codable, CaseIterable {
    case food, drink, substance, activity, undefined
}

struct LocationData: Codable {
    var latitude: Double
    var longitude: Double
    var locationName: String?

    // Custom CodingKeys and init(from:) for CLLocationCoordinate2D
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, locationName
    }

     // Implement the required initializer for Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        locationName = try container.decodeIfPresent(String.self, forKey: .locationName)
    }

    // Implement the required encode(to:) method for Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(locationName, forKey: .locationName)
    }
    
    //initializer to create location
    init(latitude: Double, longitude: Double, locationName: String? = nil){ //provided reasonable defaults
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
    }
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
