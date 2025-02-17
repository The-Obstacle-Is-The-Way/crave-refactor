import Foundation

public protocol AnalyticsEvent {
    var id: UUID { get }
    var timestamp: Date { get }
    var eventType: EventType { get }
    var priority: EventPriority { get }
    var metadata: [String: Any] { get }
}

public enum EventType: String {
    case cravingLogged = "craving_logged"
    case cravingResisted = "craving_resisted"
    case cravingUpdated = "craving_updated"
    case patternDetected = "pattern_detected"
    case insightGenerated = "insight_generated"
    case viewedAnalytics = "viewed_analytics"
    case viewedInsight = "viewed_insight"
    case processingStarted = "processing_started"
    case processingCompleted = "processing_completed"
    case error = "error"
    case unknown = "unknown"
}

public enum EventPriority: Int {
    case critical = 0
    case high = 1
    case normal = 2
    case low = 3
    
    public var processingDelay: TimeInterval {
        switch self {
        case .critical: return 0
        case .high: return 30
        case .normal: return 60
        case .low: return 300
        }
    }
}

public struct CravingEvent: AnalyticsEvent {
    public let id: UUID
    public let timestamp: Date
    public let eventType: EventType = .cravingLogged
    public let priority: EventPriority = .high
    public let metadata: [String: Any]
    
    public let cravingId: UUID
    public let cravingText: String
    public let intensity: Int?
    public let triggers: Set<String>
    
    public init(cravingId: UUID, cravingText: String, intensity: Int? = nil, triggers: Set<String> = []) {
        self.id = UUID()
        self.timestamp = Date()
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

