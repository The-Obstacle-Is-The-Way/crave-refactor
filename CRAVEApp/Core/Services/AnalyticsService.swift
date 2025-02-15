//
//
// CRAVEApp/Core/Services/AnalyticsService.swift
// Purpose: Central service coordinating all analytics operations and providing a clean public API
//
//

import Foundation
import SwiftData
import Combine

protocol AnalyticsServiceProtocol {
    // Core Operations - Simplified for now. We'll add complexity *after* the basics work.
    func trackEvent(_ event: CravingModel) async throws // Simplified to take CravingModel
    func processAnalytics() async throws
    // State Management
    var currentState: AnalyticsState { get }
    var isProcessing: Bool { get }
    func reset() async throws
}

// MARK: - Analytics Service Implementation
final class AnalyticsService: AnalyticsServiceProtocol, ObservableObject {
    // MARK: - Published State
    @Published private(set) var currentState: AnalyticsState = .idle
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var lastProcessingTime: Date?

    // MARK: - Dependencies
    private let configuration: AnalyticsConfiguration
    private let manager: AnalyticsManager // We'll address this later
    //private let processor: AnalyticsProcessor // Removed, as we are starting simple
    //private let reporter: AnalyticsReporter // Removed, as we are starting simple
    private let storage: AnalyticsStorage

    // MARK: - Internal Components
    //private let queue: AsyncQueue<AnalyticsEvent> // Removed, using simple array
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        configuration: AnalyticsConfiguration = .shared,
        modelContext: ModelContext // Directly inject the context
    ) {
        self.configuration = configuration
        self.storage = AnalyticsStorage(modelContext: modelContext)
        self.manager = AnalyticsManager(modelContext: modelContext) // Pass the context
        //self.processor = AnalyticsProcessor(configuration: configuration, storage: storage)
        //self.reporter = AnalyticsReporter(configuration: configuration, storage: storage)
        //self.queue = AsyncQueue() // Removed.

        setupService() // Keep setup for potential future use.
    }

    // MARK: - Public API (Simplified)
    func trackEvent(_ event: CravingModel) async throws { // Simplified to take CravingModel
        // No feature flags for now. Add back if needed, but keep it simple.
        do {
            let metadata = AnalyticsMetadata(cravingId: event.id)
            event.analyticsMetadata = metadata //connect metadata
            try modelContext.insert(metadata)
            try modelContext.insert(event) // Insert the event (CravingModel).
            try modelContext.save() // Explicit save.

        } catch {
            // TODO: Improve error handling. Don't just print.
            print("Analytics tracking failed: \(error)")
            throw AnalyticsServiceError.trackingFailed(error)
        }
    }

     func processAnalytics() async throws {
        // Placeholder for now.  We'll add more later.
        guard !isProcessing else { return }

        isProcessing = true
        currentState = .processing

        // do {
             //try await storage.fetch()
             // TODO: Add actual processing logic.

             currentState = .completed // Simplified state
             lastProcessingTime = Date()


        // } catch {
        //     currentState = .error(error)
        //     throw AnalyticsServiceError.processingFailed(error)
        // }

        isProcessing = false
    }

    func reset() async throws {
        // Placeholder.  We'll implement this later.
        isProcessing = true
        currentState = .resetting

        do {
            //try await storage.clear() // We'll add a clear method to storage later.
            //queue.clear() // Removed

            currentState = .idle
            isProcessing = false
        } catch {
            currentState = .error(error)
            throw AnalyticsServiceError.resetFailed(error)
        }
    }

    // MARK: - Private Methods (Simplified)
    private func setupService() {
        //setupConfigurationObservers() //Removed
        //setupAutoProcessing() // Removed
    }
}

// MARK: - Supporting Types (Simplified)
enum AnalyticsState: Equatable {
    case idle
    case processing
    case completed // Simplified
    case error(Error) // Keep the error case
    case resetting

    //Equatable for AnalyticsState
    static func == (lhs: AnalyticsState, rhs: AnalyticsState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.processing, .processing),
             (.completed, .completed),
             (.resetting, .resetting):
            return true
        case (.error, .error):
            return true // For simplicity, treat all errors as equal.
        default:
            return false
        }
    }
}



enum AnalyticsServiceError: Error {
    case trackingFailed(Error)
    case processingFailed(Error)
    case resetFailed(Error)
    case configurationError

    var localizedDescription: String {
        switch self {
        case .trackingFailed(let error):
            return "Analytics tracking failed: \(error.localizedDescription)"
        case .processingFailed(let error):
            return "Processing failed: \(error.localizedDescription)"
        case .resetFailed(let error):
            return "Analytics reset failed: \(error.localizedDescription)"
        case .configurationError:
            return "Invalid analytics configuration"
        }
    }
}

// MARK: - Testing Support (Placeholder)
extension AnalyticsService {
     static func preview(modelContext: ModelContext) -> AnalyticsService { //Added modelContext
        AnalyticsService(
            configuration: .preview,
            modelContext: modelContext // Pass the context here
        )
    }
}

