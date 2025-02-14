/// CravingModel.swift
///
/// The core data model representing a craving event in the CRAVE application.
/// This model includes both basic craving information and analytics-related data.
///
/// Usage:
/// ```
/// let craving = CravingModel(
///     cravingText: "Chocolate",
///     intensity: 7,
///     category: .food
/// )
/// try craving.validate()
/// ```

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
    var triggers: Set<CravingTrigger>
    
    // MARK: - Metadata
    var location: LocationData?
    var contextualFactors: [ContextualFactor]
    var successfulResistance: Bool
    
    // MARK: - Tracking
    var createdAt: Date
    var modifiedAt: Date
    var analyticsProcessed: Bool
    
    // MARK: - Relationships
    @Relationship(.cascade) var analyticsData: CravingAnalyticsData?
    
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
         triggers: Set<CravingTrigger> = [],
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
    }
}

// MARK: - Supporting Types
enum CravingCategory: String, Codable {
    case food
    case drink
    case substance
    case activity
    case undefined
}

struct CravingTrigger: Hashable, Codable {
    let id: UUID
    let name: String
    let category: TriggerCategory
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
        case positive
        case negative
        case neutral
    }
}

// MARK: - Analytics Integration
extension CravingModel {
    func prepareForAnalytics() -> CravingAnalyticsData {
        return CravingAnalyticsData(
            cravingId: id,
            intensity: intensity,
            duration: duration,
            category: category,
            triggers: Array(triggers),
            locationData: location,
            contextualFactors: contextualFactors,
            timestamp: timestamp,
            successfulResistance: successfulResistance
        )
    }
    
    func updateAnalytics() {
        modifiedAt = Date()
        analyticsProcessed = false
    }
}

// MARK: - Validation
extension CravingModel {
    func validate() throws {
        guard !cravingText.isEmpty else {
            throw CravingModelError.emptyText
        }
        
        guard intensity >= 0 && intensity <= 10 else {
            throw CravingModelError.invalidIntensity
        }
        
        // Additional validation as needed
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
