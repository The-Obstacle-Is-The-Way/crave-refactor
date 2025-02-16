//
//  🍒
//  CRAVEApp/Analytics/Models/ContextualData.swift
//  Purpose: Defines the contextual data model for analytics insights
//

import Foundation
import SwiftData
import CoreLocation

// MARK: - ContextualData Model
@Model
final class ContextualData {
    // MARK: - Core Properties
    @Attribute(.unique) var id: UUID
    var cravingId: UUID
    var timestamp: Date

    // MARK: - Environmental Context
    var location: LocationContext?
    var weather: WeatherContext?
    var timeContext: TimeContext
    var environmentalFactors: [EnvironmentalFactor]

    // MARK: - User Context
    var emotionalState: EmotionalState
    var physicalState: PhysicalState
    var socialContext: SocialContext
    var activityContext: ActivityContext

    // MARK: - Behavioral Patterns
    var precedingEvents: [EventContext]
    var triggerPatterns: [TriggerPattern]
    var copingStrategies: [CopingStrategy]

    // MARK: - Initialization
    init(cravingId: UUID) {
        self.id = UUID()
        self.cravingId = cravingId
        self.timestamp = Date()
        self.timeContext = TimeContext()
        self.environmentalFactors = []
        self.emotionalState = EmotionalState()
        self.physicalState = PhysicalState()
        self.socialContext = SocialContext()
        self.activityContext = ActivityContext()
        self.precedingEvents = []
        self.triggerPatterns = []
        self.copingStrategies = []
    }
}

// MARK: - Supporting Types

struct LocationContext: Codable {
    var coordinate: CLLocationCoordinate2D
    var placeName: String?
    var placeType: PlaceType
    var isFrequentLocation: Bool

    enum PlaceType: String, Codable {
        case home
        case work
        case social
        case transit
        case shopping
        case unknown
    }

    // Custom CodingKeys and init(from:) for CLLocationCoordinate2D
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case placeName
        case placeType
        case isFrequentLocation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.placeName = try container.decodeIfPresent(String.self, forKey: .placeName)
        self.placeType = try container.decode(PlaceType.self, forKey: .placeType)
        self.isFrequentLocation = try container.decode(Bool.self, forKey: .isFrequentLocation)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(placeName, forKey: .placeName)
        try container.encode(placeType, forKey: .placeType)
        try container.encode(isFrequentLocation, forKey: .isFrequentLocation)
    }

    // Initializer to create LocationContext
    init(coordinate: CLLocationCoordinate2D, placeName: String? = nil, placeType: PlaceType, isFrequentLocation: Bool) {
        self.coordinate = coordinate
        self.placeName = placeName
        self.placeType = placeType
        self.isFrequentLocation = isFrequentLocation
    }
}

struct WeatherContext: Codable {
    var temperature: Double
    var condition: WeatherCondition
    var humidity: Double
    var pressure: Double

    enum WeatherCondition: String, Codable {
        case clear
        case cloudy
        case rainy
        case snowy
        case stormy
    }
}

struct TimeContext: Codable {
    var timeOfDay: TimeOfDay
    var dayOfWeek: DayOfWeek
    var isWeekend: Bool
    var isHoliday: Bool
    var season: Season

    enum TimeOfDay: String, Codable, CaseIterable {
        case morning, afternoon, evening, night
    }

    enum DayOfWeek: String, Codable, CaseIterable {
        case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    }

    enum Season: String, Codable {
        case spring
        case summer
        case fall
        case winter
    }

    init() {
        // Initialize with default values or logic
        self.timeOfDay = .morning
        self.dayOfWeek = .monday
        self.isWeekend = false
        self.isHoliday = false
        self.season = .spring
    }
}

struct EnvironmentalFactor: Codable {
    var type: FactorType
    var intensity: Int // 1-10
    var impact: Impact

    enum FactorType: String, Codable {
        case noise
        case lighting
        case crowding
        case temperature
        case air_quality
    }

    enum Impact: String, Codable {
        case positive
        case negative
        case neutral
    }
}

struct EmotionalState: Codable {
    var primaryEmotion: Emotion
    var intensity: Int // 1-10
    var stressLevel: Int // 1-10
    var mood: Mood

    enum Emotion: String, Codable {
        case happy
        case sad
        case angry
        case anxious
        case neutral
    }

    enum Mood: String, Codable {
        case elevated
        case stable
        case depressed
        case mixed
    }

    init() {
        // Initialize with default values or logic
        self.primaryEmotion = .neutral
        self.intensity = 5
        self.stressLevel = 5
        self.mood = .stable
    }
}

struct PhysicalState: Codable {
    var energyLevel: Int // 1-10
    var hungerLevel: Int // 1-10
    var sleepQuality: Int // 1-10
    var physicalDiscomfort: [Discomfort]

    struct Discomfort: Codable {
        var type: DiscomfortType
        var intensity: Int // 1-10

        enum DiscomfortType: String, Codable {
            case pain
            case fatigue
            case nausea
            case headache
        }
    }

    init() {
        // Initialize with default values or logic
        self.energyLevel = 5
        self.hungerLevel = 5
        self.sleepQuality = 5
        self.physicalDiscomfort = []
    }
}

struct SocialContext: Codable {
    var socialSetting: SocialSetting
    var companionship: [Companion]
    var socialPressure: Int // 1-10

    enum SocialSetting: String, Codable {
        case alone
        case family
        case friends
        case colleagues
        case strangers
    }

    struct Companion: Codable {
        var relationship: String
        var influence: Influence

        enum Influence: String, Codable {
            case supportive
            case triggering
            case neutral
        }
    }

    init() {
        // Initialize with default values or logic
        self.socialSetting = .alone
        self.companionship = []
        self.socialPressure = 5
    }
}

struct ActivityContext: Codable {
    var currentActivity: String
    var activityType: ActivityType
    var engagementLevel: Int // 1-10
    var isRoutine: Bool

    enum ActivityType: String, Codable {
        case work
        case leisure
        case exercise
        case social
        case rest
    }

    init() {
        // Initialize with default values or logic
        self.currentActivity = "Unknown"
        self.activityType = .rest
        self.engagementLevel = 5
        self.isRoutine = false
    }
}

struct EventContext: Codable {
    var eventType: String
    var timestamp: Date
    var duration: TimeInterval
    var impact: Impact

    enum Impact: String, Codable {
        case trigger
        case neutral
        case protective
    }
}

struct TriggerPattern: Codable {
    var patternType: PatternType
    var frequency: Int
    var strength: Double // 0.0-1.0
    var associatedContexts: [String]

    enum PatternType: String, Codable {
        case time_based
        case location_based
        case social_based
        case emotional_based
        case activity_based
    }
}

struct CopingStrategy: Codable {
    var strategy: String
    var effectiveness: Int // 1-10
    var usageCount: Int
    var successRate: Double // 0.0-1.0
}

