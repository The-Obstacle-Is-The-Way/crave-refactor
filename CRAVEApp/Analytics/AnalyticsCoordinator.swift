//
//
//  🍒
//  CRAVEApp/Analytics/AnalyticsCoordinator.swift
//  Purpose: Coordinates and orchestrates all analytics operations across the app
//
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class AnalyticsCoordinator: ObservableObject {

    // MARK: - Published Properties (if needed for UI updates)
    // Example: @Published var currentReport: Report?

    // MARK: - Dependencies (Assuming these services exist and are defined elsewhere)
    private let analyticsService: AnalyticsService
    private let eventTrackingService: EventTrackingService
    private let patternDetectionService: PatternDetectionService
    private let analyticsStorage: AnalyticsStorage

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.analyticsStorage = AnalyticsStorage(modelContext: modelContext)
        self.analyticsService = AnalyticsService(modelContext: modelContext)
        self.eventTrackingService = EventTrackingService(storage: self.analyticsStorage, configuration: .shared) // ✅ Corrected access to shared
        self.patternDetectionService = PatternDetectionService(storage: self.analyticsStorage)

        setupObservers()
    }

    private let modelContext: ModelContext // Storing model context

    private func setupObservers() {
        eventTrackingService.eventPublisher
            .sink { [weak self] completion in // Add [weak self]
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    print("Error receiving event: \(error)")
                case .finished:
                    print("Event stream finished")
                }
            } receiveValue: { [weak self] event in // And here
                guard let self = self else { return }
                self.handleEvent(event: event)
            }
            .store(in: &cancellables)

        patternDetectionService.patternsPublisher
            .sink { [weak self] completion in // And here
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    print("Error receiving patterns: \(error)")
                case .finished:
                    print("Pattern stream finished")
                }
            } receiveValue: { [weak self] patterns in // And here
                guard let self = self else { return }
                self.handleDetectedPatterns(patterns: patterns)
            }
            .store(in: &cancellables)
    }

    private func handleEvent(event: any AnalyticsEvent) { // ✅ Explicit type annotation
        Task {
             await analyticsService.processEvent(event: event) // ✅ Method should now exist in AnalyticsService
        }
    }

    private func handleDetectedPatterns(patterns: [any DetectedPattern]) { // ✅ Explicit type annotation
        Task {
            await analyticsService.analyzeData(patterns: patterns) // ✅ Method should now exist in AnalyticsService
        }
    }


    func generateReport(for type: ReportType, format: ReportFormat) async throws -> Report {
        return try await analyticsService.generateReport(type: type, timeRange: DateInterval()) // ✅ Corrected call to generateReport - placeholder DateInterval
    }

    func fetchInsights() async throws -> [any AnalyticsInsight] { // ✅ Explicit type annotation
        return try await analyticsService.fetchInsights() // ✅ Method should now exist in AnalyticsService
    }

    func fetchPredictions() async throws -> [any AnalyticsPrediction] { // ✅ Explicit type annotation
        return try await analyticsService.fetchPredictions() // ✅ Method should now exist in AnalyticsService
    }
}

// MARK: - Preview (Adjust PreviewProvider as needed for your testing/preview setup)
extension AnalyticsCoordinator {
    static var preview: AnalyticsCoordinator {
        let config = AnalyticsConfiguration.preview
        let container = try! ModelContainer(for: CravingModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        return AnalyticsCoordinator(modelContext: context)
    }
}

