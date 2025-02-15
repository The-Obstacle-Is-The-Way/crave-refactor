//
//
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
}

// MARK: - Supporting Types
extension ContextualData {
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
        
        enum Season: String, Codable {
            case spring
            case summer
            case fall
            case winter
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
        var stress_level: Int // 1-10
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
    }
    
    struct PhysicalState: Codable {
        var energy_level: Int // 1-10
        var hunger_level: Int // 1-10
        var sleep_quality: Int // 1-10
        var physical_discomfort: [Discomfort]
        
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
    }
    
    struct ActivityContext: Codable {
        var currentActivity: String
        var activityType: ActivityType
        var engagement_level: Int // 1-10
        var is_routine: Bool
        
        enum ActivityType: String, Codable {
            case work
            case leisure
            case exercise
            case social
            case rest
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
        var pattern_type: PatternType
        var frequency: Int
        var strength: Double // 0.0-1.0
        var associated_contexts: [String]
        
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
        var usage_count: Int
        var success_rate: Double // 0.0-1.0
    }
}

// MARK: - Context Analysis
extension ContextualData {
    func analyzeContext() -> ContextualAnalysis {
        return ContextualAnalysis(
            locationTrigger: analyzeLocationTrigger(),
            timeTrigger: analyzeTimeTrigger(),
            environmentalTrigger: analyzeEnvironmentalTrigger(),
            socialTrigger: analyzeSocialTrigger(),
            emotionalTrigger: analyzeEmotionalTrigger()
        )
    }
    
    private func analyzeLocationTrigger() -> TriggerStrength {
        // Implement location analysis
        return .medium
    }
    
    private func analyzeTimeTrigger() -> TriggerStrength {
        // Implement time analysis
        return .medium
    }
    
    private func analyzeEnvironmentalTrigger() -> TriggerStrength {
        // Implement environmental analysis
        return .medium
    }
    
    private func analyzeSocialTrigger() -> TriggerStrength {
        // Implement social analysis
        return .medium
    }
    
    private func analyzeEmotionalTrigger() -> TriggerStrength {
        // Implement emotional analysis
        return .medium
    }
}

// MARK: - Analysis Types
enum TriggerStrength: String, Codable {
    case low
    case medium
    case high
    
    var value: Double {
        switch self {
        case .low: return 0.3
        case .medium: return 0.6
        case .high: return 0.9
        }
    }
}

struct ContextualAnalysis: Codable {
    let locationTrigger: TriggerStrength
    let timeTrigger: TriggerStrength
    let environmentalTrigger: TriggerStrength
    let socialTrigger: TriggerStrength
    let emotionalTrigger: TriggerStrength
    
    var overallRisk: Double {
        let triggers = [locationTrigger, timeTrigger, environmentalTrigger,
                       socialTrigger, emotionalTrigger]
        return triggers.reduce(0.0) { $0 + $1.value } / Double(triggers.count)
    }
}

// MARK: - Testing Support
extension ContextualData {
    static func mock(cravingId: UUID = UUID()) -> ContextualData {
        let contextData = ContextualData(cravingId: cravingId)
        // Add mock data here
        return contextData
    }
}
