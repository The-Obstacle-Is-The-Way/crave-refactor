// File: AnalyticsCoordinator.swift
// Purpose: Coordinates and orchestrates all analytics operations across the app

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
