// File: AnalyticsCoordinator.swift
// Purpose: Coordinates and orchestrates all analytics operations across the app
import Combine
import Foundation
import SwiftData

@MainActor
final class AnalyticsCoordinator: ObservableObject {
    
    // MARK: - Dependencies

    private let analyticsService: AnalyticsService
    private let eventTrackingService: EventTrackingService
    private let patternDetectionService: PatternDetectionService
    private let configuration: AnalyticsConfiguration

    // MARK: - Published State

    @Published private(set) var coordinatorState: CoordinatorState = .inactive
    @Published private(set) var processingMetrics: CoordinationMetrics = CoordinationMetrics()
    @Published private(set) var lastProcessingTime: Date?

    // MARK: - Internal

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        analyticsService: AnalyticsService,
        eventTrackingService: EventTrackingService,
        patternDetectionService: PatternDetectionService,
        configuration: AnalyticsConfiguration
    ) {
        self.analyticsService = analyticsService
        self.eventTrackingService = eventTrackingService
        self.patternDetectionService = patternDetectionService
        self.configuration = configuration
        
        setupCoordination()
    }

    // MARK: - Public Interface
    func start() {
        guard coordinatorState != .active else { return }
        
        coordinatorState = .starting
        // Start services, setup subscriptions, etc.
        setupSubscriptions()
        
        coordinatorState = .active
    }
    
    func stop() {
        guard coordinatorState == .active else { return }
        
        coordinatorState = .stopping
        // Stop services, cancel subscriptions, etc.
        cancellables.removeAll()
        
        coordinatorState = .inactive
    }
    
    func processAnalytics() async throws {
        guard coordinatorState == .active else {
            throw CoordinatorError.notActive
        }
        
        coordinatorState = .processing
        let startTime = Date()
        
        do {
            try await analyticsService.processAnalytics()
            // Trigger pattern detection
            let _ = try await patternDetectionService.detectPatterns()
            // Generate reports (optional)
            
            // Update metrics
            processingMetrics.update(for: .processed)
            processingMetrics.updateProcessingTime(Date().timeIntervalSince(startTime))
            lastProcessingTime = Date()
            
            // Notify completion (optional)
            NotificationCenter.default.post(name: .analyticsProcessingCompleted, object: nil)
            
            coordinatorState = .active
            
        } catch {
            processingMetrics.update(for: .error)
            coordinatorState = .error(error)
            throw CoordinatorError.processingFailed(error)
        }
    }
    
    func generateReport(type: AnalyticsService.ReportType) async throws -> AnalyticsService.Report { //Added ReportType and Report to AnalyticsService
        return try await analyticsService.generateReport(type: type, timeRange: .day(Date()))
    }
    
    func resetAnalytics() async throws {
        guard coordinatorState == .active else {
            throw CoordinatorError.notActive
        }
        
        coordinatorState = .resetting
        
        do {
            try await analyticsService.reset()
            // Additional reset logic if needed
            
            coordinatorState = .active
        } catch {
            coordinatorState = .error(error)
            throw CoordinatorError.resetFailed(error)
        }
    }
    
    // MARK: - Private Methods
    private func setupCoordination() {
        // Setup initial state, load configurations, etc.
    }
    
    private func setupSubscriptions() {
        // Setup Combine subscriptions to react to events,
        // configuration changes, etc.
    }
}

// MARK: - Supporting Types
enum CoordinatorState: Equatable {
    case inactive
    case starting
    case active
    case processing
    case stopping
    case resetting
    case error(Error)
    
    static func == (lhs: CoordinatorState, rhs: CoordinatorState) -> Bool {
        switch (lhs, rhs) {
        case (.inactive, .inactive),
             (.starting, .starting),
             (.active, .active),
             (.processing, .processing),
             (.stopping, .stopping),
             (.resetting, .resetting):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

enum CoordinationOperation {
    case started
    case stopped
    case processed
    case reportGenerated
    case reset
    case error
}

struct CoordinationMetrics {
    private(set) var totalProcessingRuns: Int = 0
    private(set) var totalReportsGenerated: Int = 0
    private(set) var totalErrors: Int = 0
    private(set) var averageProcessingTime: TimeInterval = 0
    private(set) var lastOperationTime: Date?
    
    mutating func update(for operation: CoordinationOperation) {
        lastOperationTime = Date()
        
        switch operation {
        case .processed:
            totalProcessingRuns += 1
        case .reportGenerated:
            totalReportsGenerated += 1
        case .error:
            totalErrors += 1
        default:
            break
        }
    }
    
    mutating func updateProcessingTime(_ time: TimeInterval) {
        let totalTime = averageProcessingTime * Double(totalProcessingRuns)
        averageProcessingTime = (totalTime + time) / Double(totalProcessingRuns + 1)
    }
}

enum CoordinatorError: Error {
    case notActive
    case alreadyActive
    case processingFailed(Error)
    case reportGenerationFailed(Error)
    case resetFailed(Error)
    case serviceInitializationFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .notActive:
            return "Coordinator is not active"
        case .alreadyActive:
            return "Coordinator is already active"
        case .processingFailed(let error):
            return "Processing failed: \(error.localizedDescription)"
        case .reportGenerationFailed(let error):
            return "Report generation failed: \(error.localizedDescription)"
        case .resetFailed(let error):
            return "Reset failed: \(error.localizedDescription)"
        case .serviceInitializationFailed(let error):
            return "Service initialization failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let analyticsProcessingCompleted = Notification.Name("analyticsProcessingCompleted")
}

// MARK: - Testing Support
extension AnalyticsCoordinator {
    static func preview() -> AnalyticsCoordinator {
        AnalyticsCoordinator(
            analyticsService: .preview(modelContext: PreviewContainer.modelContext),
            eventTrackingService: .preview(),
            patternDetectionService: .preview(),
            configuration: .preview
        )
    }
}

