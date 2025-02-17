import Foundation
import Combine

public class EventTrackingService {
    public let eventPublisher = PassthroughSubject<AnalyticsEvent, Error>()
    
    public init(storage: AnalyticsStorage, configuration: AnalyticsConfiguration) {}
    
    public func trackCravingEvent(_ event: CravingEvent) async throws {
        // Track the event.
        eventPublisher.send(event)
    }
}

