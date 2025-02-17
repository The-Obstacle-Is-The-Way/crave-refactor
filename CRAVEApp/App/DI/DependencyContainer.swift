import Foundation
import SwiftData

public struct DependencyContainer {
    public let modelContext: ModelContext

    // Craving services
    public let cravingManager: CravingManager
    public let cravingAnalyzer: CravingAnalyzer

    // Analytics services
    public let analyticsStorage: AnalyticsStorage
    public let analyticsAggregator: AnalyticsAggregator
    public let analyticsProcessor: AnalyticsProcessor
    public let patternDetectionService: PatternDetectionService
    public let analyticsReporter: AnalyticsReporter
    public let eventTrackingService: EventTrackingService

    // ViewModels
    public let cravingListViewModel: CravingListViewModel
    public let dateListViewModel: DateListViewModel
    public let logCravingViewModel: LogCravingViewModel
    public let analyticsDashboardViewModel: AnalyticsDashboardViewModel
    public let analyticsViewModel: AnalyticsViewModel

    // Analytics Coordinator
    public let analyticsCoordinator: AnalyticsCoordinator

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Create services
        analyticsStorage = AnalyticsStorage(modelContext: modelContext)
        cravingManager = CravingManager(modelContext: modelContext)
        cravingAnalyzer = CravingAnalyzer()

        analyticsAggregator = AnalyticsAggregator(storage: analyticsStorage)
        analyticsProcessor = AnalyticsProcessor(configuration: AnalyticsConfiguration.shared, storage: analyticsStorage)
        patternDetectionService = PatternDetectionService(storage: analyticsStorage, configuration: AnalyticsConfiguration.shared)
        analyticsReporter = AnalyticsReporter(analyticsStorage: analyticsStorage)
        eventTrackingService = EventTrackingService(storage: analyticsStorage, configuration: AnalyticsConfiguration.shared)

        analyticsCoordinator = AnalyticsCoordinator(
            eventTrackingService: eventTrackingService,
            patternDetectionService: patternDetectionService,
            configuration: AnalyticsConfiguration.shared,
            storage: analyticsStorage,
            aggregator: analyticsAggregator,
            processor: analyticsProcessor,
            reporter: analyticsReporter
        )

        let cravingRepo = CravingRepositoryImpl(cravingManager: cravingManager, mapper: CravingMapper())
        cravingListViewModel = CravingListViewModel(cravingRepository: cravingRepo)
        dateListViewModel = DateListViewModel(cravingRepository: cravingRepo)
        logCravingViewModel = LogCravingViewModel(addCravingUseCase: AddCravingUseCase(cravingRepository: cravingRepo))
        analyticsDashboardViewModel = AnalyticsDashboardViewModel(analyticsManager: AnalyticsManager(modelContext: modelContext))
        analyticsViewModel = AnalyticsViewModel(analyticsManager: AnalyticsManager(modelContext: modelContext))
    }
}

