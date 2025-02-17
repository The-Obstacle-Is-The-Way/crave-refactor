// Core/Domain/Entities/Analytics/AnalyticsEvent.swift

import Foundation

// MARK: - Analytics Event Protocol
protocol AnalyticsEvent {
    var id: UUID { get }
    var timestamp: Date { get }
    var eventType: EventType { get }
    var priority: EventPriority { get }
    var metadata: [String: Any] { get }
}

// MARK: - Event Type
enum EventType: String {
    // Craving Events
    case cravingLogged = "craving_logged"
    case cravingResisted = "craving_resisted"
    case cravingUpdated = "craving_updated"
    
    // Analytics Events
    case patternDetected = "pattern_detected"
    case insightGenerated = "insight_generated"
    
    // User Interaction Events
    case viewedAnalytics = "viewed_analytics"
    case viewedInsight = "viewed_insight"
    
    // System Events
    case processingStarted = "processing_started"
    case processingCompleted = "processing_completed"
    case error = "error"
}

// MARK: - Event Priority
enum EventPriority: Int {
    case critical = 0
    case high = 1
    case normal = 2
    case low = 3
    
    var processingDelay: TimeInterval {
        switch self {
        case .critical: return 0
        case .high: return 30
        case .normal: return 60
        case .low: return 300
        }
    }
}

// MARK: - Concrete Event Types
struct CravingEvent: AnalyticsEvent {
    let id: UUID
    let timestamp: Date
    let eventType: EventType
    let priority: EventPriority
    let metadata: [String: Any]
    
    // Craving-specific properties
    let cravingId: UUID
    let cravingText: String
    let intensity: Int?
    let triggers: Set<String>
    
    init(cravingId: UUID, cravingText: String, intensity: Int? = nil, triggers: Set<String> = []) {
        self.id = UUID()
        self.timestamp = Date()
        self.eventType = .cravingLogged
        self.priority = .high
        self.cravingId = cravingId
        self.cravingText = cravingText
        self.intensity = intensity
        self.triggers = triggers
        
        self.metadata = [
            "craving_id": cravingId.uuidString,
            "text": cravingText,
            "intensity": intensity as Any,
            "triggers": Array(triggers)
        ]
    }
}

struct PatternEvent: AnalyticsEvent {
    let id: UUID
    let timestamp: Date
    let eventType: EventType
    let priority: EventPriority
    let metadata: [String: Any]
    
    // Pattern-specific properties
    let patternType: String
    let confidence: Double
    let detectionData: [String: Any]
    
    init(patternType: String, confidence: Double, detectionData: [String: Any]) {
        self.id = UUID()
        self.timestamp = Date()
        self.eventType = .patternDetected
        self.priority = .normal
        self.patternType = patternType
        self.confidence = confidence
        self.detectionData = detectionData
        
        self.metadata = [
            "pattern_type": patternType,
            "confidence": confidence,
            "detection_data": detectionData
        ]
    }
}

struct SystemEvent: AnalyticsEvent {
    let id: UUID
    let timestamp: Date
    let eventType: EventType
    let priority: EventPriority
    let metadata: [String: Any]
    
    init(eventType: EventType, metadata: [String: Any] = [:]) {
        self.id = UUID()
        self.timestamp = Date()
        self.eventType = eventType
        self.priority = .low
        self.metadata = metadata
    }
}

// MARK: - Event Validation
extension AnalyticsEvent {
    func validate() -> Bool {
        guard !metadata.isEmpty else { return false }
        
        switch eventType {
        case .cravingLogged:
            return validateCravingEvent()
        case .patternDetected:
            return validatePatternEvent()
        default:
            return true
        }
    }
    
    private func validateCravingEvent() -> Bool {
        guard let cravingEvent = self as? CravingEvent else { return false }
        return !cravingEvent.cravingText.isEmpty
    }
    
    private func validatePatternEvent() -> Bool {
        guard let patternEvent = self as? PatternEvent else { return false }
        return patternEvent.confidence >= 0 && patternEvent.confidence <= 1
    }
}
