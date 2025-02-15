//
//
// CRAVEApp/Core/Services/AnalyticsService.swift
// Purpose: Central service coordinating all analytics operations and providing a clean public API
//
//

import Foundation
import SwiftData
import Combine

@MainActor
final class AnalyticsService: ObservableObject {
    // MARK: - Published State
    @Published private(set) var currentState: AnalyticsState = .idle
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var lastProcessingTime: Date?

    // MARK: - Dependencies
    private let configuration: AnalyticsConfiguration
    private let manager: AnalyticsManager
    private let storage: AnalyticsStorage

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()

    init(
        configuration: AnalyticsConfiguration = .shared,
        modelContext: ModelContext
    ) {
        self.configuration = configuration
        self.storage = AnalyticsStorage(modelContext: modelContext)
        self.manager = AnalyticsManager(modelContext: modelContext)
    }

    func trackEvent(_ event: CravingModel) async throws {
        do {
            let metadata = AnalyticsMetadata(cravingId: event.id)
            event.analyticsMetadata = metadata
            
            storage.modelContext.insert(metadata)
            storage.modelContext.insert(event)
            try storage.modelContext.save()

        } catch {
            print("Analytics tracking failed: \(error)")
            throw AnalyticsServiceError.trackingFailed(error)
        }
    }

    func processAnalytics() async throws {
        guard !isProcessing else { return }

        isProcessing = true
        currentState = .processing

        do {
            let stats = try await manager.getBasicStats()
            currentState = .completed
            lastProcessingTime = Date()
            return stats
        } catch {
            currentState = .error(error)
            throw AnalyticsServiceError.processingFailed(error)
        } finally {
            isProcessing = false
        }
    }

    func generateReport(type: ReportType, timeRange: DateInterval) async throws -> Report {
        let reportData = ReportData(
            title: "\(type.rawValue) Report",
            content: "Analysis for period: \(timeRange.start) to \(timeRange.end)"
        )
        
        return Report(
            metadata: ReportMetadata(
                reportType: type,
                format: .pdf,
                creationDate: .now
            ),
            data: reportData,
            format: .pdf,
            generationDate: .now,
            state: .completed
        )
    }
}

// MARK: - Supporting Types
enum AnalyticsState: Equatable {
    case idle
    case processing
    case completed
    case error(Error)
    case resetting

    static func == (lhs: AnalyticsState, rhs: AnalyticsState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.processing, .processing),
             (.completed, .completed),
             (.resetting, .resetting):
            return true
        case (.error, .error):
            return true // For simplicity, treat all errors as equal
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
}
