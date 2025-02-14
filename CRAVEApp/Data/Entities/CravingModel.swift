//
// CravingModel.swift
//

import Foundation
import SwiftData
import NaturalLanguage

@Model
final class CravingModel: Identifiable {
    // MARK: - Core Properties
    @Attribute(.unique) var id: UUID
    var cravingText: String
    var timestamp: Date
    var isArchived: Bool

    // MARK: - Analytics Properties
    var intensity: Int
    var duration: TimeInterval
    var category: CravingCategory
    var triggers: Set<String> // Changed to Set<String> for simplicity

    // MARK: - Metadata
    var location: LocationData?
    var contextualFactors: [ContextualFactor] // Use this for structured context
    var successfulResistance: Bool

    // MARK: - NLP Extracted Entities (NEW)
    var extractedEntities: [String: String] = [:] // e.g., ["food": "chocolate", "place": "home"]

    // MARK: - Tracking
    var createdAt: Date
    var modifiedAt: Date
    var analyticsProcessed: Bool

    // MARK: - Relationships
    @Relationship(.cascade) var analyticsData: CravingAnalyticsData? // You might not need this

    // MARK: - Computed Properties
    var durationInMinutes: Double {
        return duration / 60.0
    }

    var isActive: Bool {
        return !isArchived
    }

    // MARK: - Initialization
    init(cravingText: String,
         intensity: Int = 0,
         category: CravingCategory = .undefined,
         triggers: Set<String> = [],
         location: LocationData? = nil) {
        self.id = UUID()
        self.cravingText = cravingText
        self.timestamp = Date()
        self.isArchived = false
        self.intensity = intensity
        self.category = category
        self.triggers = triggers
        self.location = location
        self.contextualFactors = []
        self.successfulResistance = false
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.analyticsProcessed = false

        // Perform initial NLP analysis (NEW)
        Task {
            await analyzeCravingText()
        }
    }

    // MARK: - Validation
    func validate() throws {
        guard !cravingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CravingModelError.emptyText
        }

        guard intensity >= 0 && intensity <= 10 else {
            throw CravingModelError.invalidIntensity
        }
    }

    // MARK: - Analytics
    func prepareForAnalytics() -> CravingAnalytics {
        return CravingAnalytics(
            id: self.id,
            timestamp: self.timestamp,
            intensity: self.intensity,
            triggers: self.triggers,
            metadata: [:] // Add relevant metadata here
        )
    }

    func updateAnalytics() {
        modifiedAt = Date()
        analyticsProcessed = false
    }

    // MARK: - NLP Analysis (NEW)
    func analyzeCravingText() async {
        let analyzer = CravingAnalyzer()
        let results = await analyzer.analyze(text: cravingText)
        self.extractedEntities = results

        // Extract triggers based on keywords (basic example)
        let triggerKeywords = ["stress", "bored", "sad", "lonely", "tired"]
        self.triggers = Set(results.keys.filter { triggerKeywords.contains($0) })
    }
}

// MARK: - Supporting Types (No changes, but included for completeness)
enum CravingCategory: String, Codable {
    case food
    case drink
    case substance
    case activity
    case undefined
}

//struct CravingTrigger: Hashable, Codable { // Changed to simple String
 //   let id: UUID
 //   let name: String
//    let category: TriggerCategory
//}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let locationName: String?
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

// MARK: - Error Handling
enum CravingModelError: Error {
    case emptyText
    case invalidIntensity
    case invalidDuration
    case invalidCategory
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


