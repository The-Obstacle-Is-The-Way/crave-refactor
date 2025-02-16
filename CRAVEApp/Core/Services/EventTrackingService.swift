//
//  🍒
//  CRAVEApp/Core/Services/EventTrackingService.swift
//  Purpose: Dedicated service for tracking and managing user and system events
//
//
//

import Foundation
import Combine
import SwiftData

@MainActor // Add @MainActor
class EventTrackingService {
    private let storage: AnalyticsStorage
    private let configuration: AnalyticsConfiguration
    
    private(set) var eventPublisher = PassthroughSubject<AnalyticsEvent, Error>()
    
    init(storage: AnalyticsStorage, configuration: AnalyticsConfiguration) { // Remove Default
        self.storage = storage
        self.configuration = configuration
    }
    
    //Tracks craving as an analytics event
    func trackCravingEvent(_ event: CravingEvent) async throws {
        // Log the event
        print("Tracking craving event: \(event)")
        
        do {
            // Store the event using AnalyticsStorage
            try await storage.store(event)
            
            // Notify subscribers about the new event
            eventPublisher.send(event)
        } catch {
            print("Error storing craving event: \(error)")
            // Send an error through the publisher
            eventPublisher.send(completion: .failure(error))
            throw error // Re-throw the error for higher-level handling
        }
    }
    
    // Generic method to track custom events
    func trackEvent(_ event: AnalyticsEvent) async throws {  // Make async throws
        do {
            try await storage.store(event)
            eventPublisher.send(event)
        } catch {
            eventPublisher.send(completion: .failure(error))
            throw error
        }
    }
}
