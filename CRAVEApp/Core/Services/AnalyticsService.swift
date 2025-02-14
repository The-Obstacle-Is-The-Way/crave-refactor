//
// File: AnalyticsService.swift
// Purpose: Central service coordinating all analytics operations and providing a clean public API
//

import Foundation
import SwiftData
import Combine

// MARK: - Analytics Service Protocol
protocol AnalyticsServiceProtocol {
    // Core Operations
    func trackEvent(_ event: AnalyticsEvent) async throws
    func processAnalytics() async throws
    func generateInsights() async throws -> [AnalyticsInsight]
    func generatePredictions() async throws -> [AnalyticsPrediction]

    // Reporting
    func generateReport(type: ReportType, timeRange: DateInterval) async throws -> Report

    // State Management
    var currentState: AnalyticsState { get }
    var isProcessing: Bool { get }
    func reset() async throws
}

// MARK: - Analytics Service Implementation
@MainActor
final class AnalyticsService: AnalyticsServiceProtocol, ObservableObject {
    // MARK: - Published State
    @Published private(set) var currentState: AnalyticsState = .idle
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var lastProcessingTime: Date?
    @Published private(set) var processingMetrics: ServiceMetrics = ServiceMetrics()

    // MARK: - Dependencies
    private let configuration: AnalyticsConfiguration
    private let manager: AnalyticsManager
    private let processor: AnalyticsProcessor
    private let reporter: AnalyticsReporter
    private let storage: AnalyticsStorage

    // MARK: - Internal Components
    private let queue: AsyncQueue<AnalyticsEvent>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        configuration: AnalyticsConfiguration = .shared,
        modelContext: ModelContext
    ) {
        self.configuration = configuration
        self.storage = AnalyticsStorage(modelContext: modelContext)
        self.manager = AnalyticsManager(modelContext: modelContext)
        self.processor = AnalyticsProcessor(configuration: configuration, storage: storage)
        self.reporter = AnalyticsReporter(configuration: configuration, storage: storage)
        self.queue = AsyncQueue()

        setupService()
    }

    // MARK: - Public API
    func trackEvent(_ event: AnalyticsEvent) async throws {
        guard configuration.featureFlags.isAnalyticsEnabled else { return }

        do {
            if event.priority == .critical {
                try await processEventImmediately(event)
            } else {
                await queue.enqueue(event)
            }

            updateMetrics(for: .eventTracked)
        } catch {
            updateMetrics(for: .error)
            throw AnalyticsServiceError.trackingFailed(error)
        }
    }

    func processAnalytics() async throws {
        guard !isProcessing else { return }

        isProcessing = true
        currentState = .processing

        do {
            // Process queued events
            try await processQueuedEvents()

            // Generate insights
            let insights = try await generateInsights()

            // Generate predictions
            let predictions = try await generatePredictions()

            // Update state
            currentState = .completed(insights: insights, predictions: predictions)
            lastProcessingTime = Date()

            updateMetrics(for: .processingCompleted)

        } catch {
            currentState = .error(error)
            updateMetrics(for: .error)
            throw AnalyticsServiceError.processingFailed(error)
        }

        isProcessing = false
    }

    func generateInsights() async throws -> [AnalyticsInsight] {
        return try await manager.generateInsights(from: storage.fetchAll()) //Pass in all the craving analytics for insight generation
    }

    func generatePredictions() async throws -> [AnalyticsPrediction] {
        return try await manager.generatePredictions()
    }

    func generateReport(type: ReportType, timeRange: DateInterval) async throws -> Report {
        return try await reporter.generateReport(type: type, timeRange: timeRange)
    }

    func reset() async throws {
        isProcessing = true
        currentState = .resetting

        do {
            try await storage.clear()
            queue.clear()
            processingMetrics = ServiceMetrics()

            currentState = .idle
            isProcessing = false
        } catch {
            currentState = .error(error)
            throw AnalyticsServiceError.resetFailed(error)
        }
    }

    // MARK: - Private Methods
    private func setupService() {
        setupConfigurationObservers()
        setupAutoProcessing()
    }

    private func setupConfigurationObservers() {
        NotificationCenter.default
            .publisher(for: .analyticsConfigurationUpdated)
            .sink { [weak self] _ in
                self?.handleConfigurationUpdate()
            }
            .store(in: &cancellables)
    }

    private func setupAutoProcessing() {
        guard configuration.featureFlags.isAutoProcessingEnabled else { return }

        Timer.publish(every: configuration.processingRules.processingInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    try? await self?.processAnalytics()
                }
            }
            .store(in: &cancellables)
    }

    private func processEventImmediately(_ event: AnalyticsEvent) async throws {
        try await processor.process(event)
    }

    private func processQueuedEvents() async throws {
        let events = await queue.dequeueAll()
        try await processor.processBatch(events)
    }

    private func handleConfigurationUpdate() {
        // Handle configuration changes
    }

    private func updateMetrics(for operation: ServiceOperation) {
        processingMetrics.update(for: operation)
    }
}

// MARK: - Supporting Types
enum AnalyticsState: Equatable {
    case idle
    case processing
    case completed(insights: [AnalyticsInsight], predictions: [AnalyticsPrediction])
    case error(Error)
    case resetting

    static func == (lhs: AnalyticsState, rhs: AnalyticsState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.processing, .processing),
             (.resetting, .resetting):
            return true
        case (.completed(let lhsInsights, let lhsPredictions),
              .completed(let rhsInsights, let rhsPredictions)):
            return lhsInsights.count == rhsInsights.count &&
                   lhsPredictions.count == rhsPredictions.count
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

enum ServiceOperation {
    case eventTracked
    case processingCompleted
    case error
}

struct ServiceMetrics {
    var totalEventsTracked: Int = 0
    var totalProcessingRuns: Int = 0
    var totalErrors: Int = 0
    var averageProcessingTime: TimeInterval = 0

    mutating func update(for operation: ServiceOperation) {
        switch operation {
        case .eventTracked:
            totalEventsTracked += 1
        case .processingCompleted:
            totalProcessingRuns += 1
        case .error:
            totalErrors += 1
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
            return "Analytics processing failed: \(error.localizedDescription)"
        case .resetFailed(let error):
            return "Analytics reset failed: \(error.localizedDescription)"
        case .configurationError:
            return "Invalid analytics configuration"
        }
    }
}

// MARK: - Async Queue
actor AsyncQueue<T> {
    private var items: [T] = []

    func enqueue(_ item: T) {
        items.append(item)
    }

    func dequeue() -> T? {
        guard !items.isEmpty else { return nil }
        return items.removeFirst()
    }

    func dequeueAll() -> [T] {
        let all = items
        items.removeAll()
        return all
    }

    func clear() {
        items.removeAll()
    }
}

// MARK: - Testing Support
extension AnalyticsService {
    static func preview(modelContext: ModelContext) -> AnalyticsService {
        AnalyticsService(
            configuration: .preview,
            modelContext: modelContext
        )
    }
}

