//
//  🍒
// CRAVEApp/Data/Entities/ContextualData.swift
//
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
} // End of ContextualData class


// MARK: - Supporting Types (ALL marked Codable)

struct LocationContext: Codable { // MARKED: Codable
    var coordinate: CLLocationCoordinate2D // Using CoreLocation type
    var placeName: String?
    var placeType: PlaceType
    var isFrequentLocation: Bool

    enum PlaceType: String, Codable { // MARKED: Codable, String RawValue
        case home
        case work
        case social
        case transit
        case shopping
        case unknown
    }
    
    // Custom CodingKeys and init(from:) for CLLocationCoordinate2D
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, placeName, placeType, isFrequentLocation
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
    
    //initializer to create location
    init(coordinate: CLLocationCoordinate2D, placeName: String? = nil, placeType: PlaceType, isFrequentLocation: Bool){
        self.coordinate = coordinate
        self.placeName = placeName
        self.placeType = placeType
        self.isFrequentLocation = isFrequentLocation
    }
}


struct WeatherContext: Codable { // MARKED: Codable
    var temperature: Double
    var condition: WeatherCondition
    var humidity: Double
    var pressure: Double

    enum WeatherCondition: String, Codable { // MARKED: Codable, String RawValue
        case clear
        case cloudy
        case rainy
        case snowy
        case stormy
    }
}

struct TimeContext: Codable { // MARKED: Codable
    var timeOfDay: TimeOfDay
    var dayOfWeek: DayOfWeek
    var isWeekend: Bool
    var isHoliday: Bool
    var season: Season

    enum TimeOfDay: String, Codable, CaseIterable { // MARKED: Codable, CaseIterable, String RawValue
        case morning, afternoon, evening, night
    }

    enum DayOfWeek: String, Codable, CaseIterable { // MARKED: Codable, CaseIterable, String RawValue
        case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    }

    enum Season: String, Codable { // MARKED: Codable, String RawValue
        case spring
        case summer
        case fall
        case winter
    }
}

struct EnvironmentalFactor: Codable { // MARKED: Codable
    var type: FactorType
    var intensity: Int // 1-10
    var impact: Impact

    enum FactorType: String, Codable { // MARKED: Codable, String RawValue
        case noise
        case lighting
        case crowding
        case temperature
        case air_quality
    }

    enum Impact: String, Codable { // MARKED: Codable, String RawValue
        case positive
        case negative
        case neutral
    }
}

struct EmotionalState: Codable { // MARKED: Codable
    var primaryEmotion: Emotion
    var intensity: Int // 1-10
    var stress_level: Int // 1-10
    var mood: Mood

    enum Emotion: String, Codable { // MARKED: Codable, String RawValue
        case happy
        case sad
        case angry
        case anxious
        case neutral
    }

    enum Mood: String, Codable { // MARKED: Codable, String RawValue
        case elevated
        case stable
        case depressed
        case mixed
    }
}

struct PhysicalState: Codable { // MARKED: Codable
    var energy_level: Int // 1-10
    var hunger_level: Int // 1-10
    var sleep_quality: Int // 1-10
    var physical_discomfort: [Discomfort]

    struct Discomfort: Codable { // MARKED: Codable
        var type: DiscomfortType
        var intensity: Int // 1-10

        enum DiscomfortType: String, Codable { // MARKED: Codable, String RawValue
            case pain
            case fatigue
            case nausea
            case headache
        }
    }
}

struct SocialContext: Codable { // MARKED: Codable
    var socialSetting: SocialSetting
    var companionship: [Companion]
    var socialPressure: Int // 1-10

    enum SocialSetting: String, Codable { // MARKED: Codable, String RawValue
        case alone
        case family
        case friends
        case colleagues
        case strangers
    }

    struct Companion: Codable { // MARKED: Codable
        var relationship: String
        var influence: Influence

        enum Influence: String, Codable { // MARKED: Codable, String RawValue
            case supportive
            case triggering
            case neutral
        }
    }
}

struct ActivityContext: Codable { // MARKED: Codable
    var currentActivity: String
    var activityType: ActivityType
    var engagement_level: Int // 1-10
    var is_routine: Bool

    enum ActivityType: String, Codable { // MARKED: Codable, String RawValue
        case work
        case leisure
        case exercise
        case social
        case rest
    }
}

struct EventContext: Codable { // MARKED: Codable
    var eventType: String
    var timestamp: Date
    var duration: TimeInterval
    var impact: Impact

    enum Impact: String, Codable { // MARKED: Codable, String RawValue
        case trigger
        case neutral
        case protective
    }
}

struct TriggerPattern: Codable { // MARKED: Codable
    var pattern_type: PatternType
    var frequency: Int
    var strength: Double // 0.0-1.0
    var associated_contexts: [String]

    enum PatternType: String, Codable { // MARKED: Codable, String RawValue
        case time_based
        case location_based
        case social_based
        case emotional_based
        case activity_based
    }
}

struct CopingStrategy: Codable { // MARKED: Codable
    var strategy: String
    var effectiveness: Int // 1-10
    var usage_count: Int
    var success_rate: Double // 0.0-1.0
}
