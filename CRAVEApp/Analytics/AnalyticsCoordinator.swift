//
// CRAVEApp/Analytics/AnalyticsCoordinator.swift
// Purpose: Coordinates and orchestrates all analytics operations across the app
//

import Foundation
import SwiftData
import Combine // Make sure to import Combine

@MainActor
class AnalyticsCoordinator: ObservableObject { // Marked as ObservableObject and @MainActor

    // MARK: - Published Properties (if needed for UI updates)
    // Example: @Published var currentReport: Report?

    // MARK: - Dependencies (Assuming these services exist and are defined elsewhere)
    private let analyticsService: AnalyticsService // Assuming AnalyticsService is defined
    private let eventTrackingService: EventTrackingService // Assuming EventTrackingService is defined
    private let patternDetectionService: PatternDetectionService // Assuming PatternDetectionService is defined
    private let analyticsStorage: AnalyticsStorage // Assuming AnalyticsStorage is defined

    private var cancellables = Set<AnyCancellable>() // For Combine publishers, if used

    // MARK: - Initialization
    init(modelContext: ModelContext) { // Removed storage and configuration from init - Using ModelContext directly
        self.modelContext = modelContext
        self.analyticsStorage = AnalyticsStorage() // Initialize AnalyticsStorage - adjust as needed
        self.analyticsService = AnalyticsService(analyticsStorage: self.analyticsStorage) // Initialize AnalyticsService with storage
        self.eventTrackingService = EventTrackingService(analyticsStorage: self.analyticsStorage) // Initialize EventTrackingService with storage
        self.patternDetectionService = PatternDetectionService(analyticsStorage: self.analyticsStorage) // Initialize PatternDetectionService with storage

        setupObservers()
    }

    private let modelContext: ModelContext // Storing model context


    private func setupObservers() {
        // Example: Observing events from EventTrackingService (if EventTrackingService publishes events)
        eventTrackingService.eventPublisher // Assuming eventPublisher is a PassthroughSubject in EventTrackingService
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error receiving event: \(error)")
                case .finished:
                    print("Event stream finished")
                }
            } receiveValue: { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)

        patternDetectionService.patternsPublisher // Assuming patternsPublisher is a PassthroughSubject in PatternDetectionService
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error receiving patterns: \(error)")
                case .finished:
                    print("Pattern stream finished")
                }
            } receiveValue: { [weak self] patterns in // Explicit type annotation for 'patterns'
                self?.handleDetectedPatterns(patterns: patterns)
            }
            .store(in: &cancellables)
    }

    private func handleEvent(event: any AnalyticsEvent) { // Use 'any AnalyticsEvent'
        Task {
             await analyticsService.processEvent(event: event) // Assuming processEvent is async and defined in AnalyticsService
        }
    }

    private func handleDetectedPatterns(patterns: [any DetectedPattern]) { // Use 'any DetectedPattern'
        Task {
            await analyticsService.analyzeData(patterns: patterns) // Assuming analyzeData is async and defined in AnalyticsService
        }
    }


    func generateReport(for type: ReportType, format: ReportFormat) async throws -> Report { // Assuming ReportType, ReportFormat, Report are defined
        return try await analyticsService.generateReport(for: type, format: format) // Assuming generateReport is async and defined in AnalyticsService
    }

    func fetchInsights() async throws -> [any AnalyticsInsight] { // Use 'any AnalyticsInsight'
        return try await analyticsService.fetchInsights() // Assuming fetchInsights is async and defined in AnalyticsService
    }

    func fetchPredictions() async throws -> [any AnalyticsPrediction] { // Use 'any AnalyticsPrediction'
        return try await analyticsService.fetchPredictions() // Assuming fetchPredictions is async and defined in AnalyticsService
    }
}

// MARK: - Preview (Adjust PreviewProvider as needed for your testing/preview setup)
extension AnalyticsCoordinator {
    static var preview: AnalyticsCoordinator {
        let config = AnalyticsConfiguration.preview // Assuming AnalyticsConfiguration.preview is defined
        let container = try! ModelContainer(for: CravingModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)) // In-memory config for preview
        let context = container.mainContext
        return AnalyticsCoordinator(modelContext: context) // Initialize with context

    }
}

