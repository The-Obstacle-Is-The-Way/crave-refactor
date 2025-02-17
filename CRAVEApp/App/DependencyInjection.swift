// CRAVEApp/App/DependencyInjection.swift

import Foundation
import SwiftData

// This is a container for all the services our app uses
// Think of it like a toolbox where we keep all the essential tools
struct DependencyContainer {

    // Our database context, which lets us talk to our database
    let modelContext: ModelContext

    // Services related to cravings
    let cravingManager: CravingManager
    let cravingAnalyzer: CravingAnalyzer

    // Services related to analytics
    let analyticsStorage: AnalyticsStorage
    let analyticsAggregator: AnalyticsAggregator
    let analyticsProcessor: AnalyticsProcessor
    let patternDetectionService: PatternDetectionService
    let analyticsReporter: AnalyticsReporter
    let analyticsCoordinator: AnalyticsCoordinator
    let eventTrackingService: EventTrackingService

    // ViewModels for our UI
    let cravingListViewModel: CravingListViewModel
    let dateListViewModel: DateListViewModel
    let logCravingViewModel: LogCravingViewModel
    let analyticsDashboardViewModel: AnalyticsDashboardViewModel
    let analyticsViewModel: AnalyticsViewModel

    // This is how we create our toolbox - we need the database context to start
    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Create instances of all our services, passing in any dependencies they need
        analyticsStorage = AnalyticsStorage(modelContext: modelContext)
        cravingManager = CravingManager(modelContext: modelContext)
        cravingAnalyzer = CravingAnalyzer()

        // Initialize AnalyticsAggregator with the AnalyticsStorage dependency
        analyticsAggregator = AnalyticsAggregator(storage: analyticsStorage)
        analyticsProcessor = AnalyticsProcessor(configuration:.shared, storage: analyticsStorage)
        patternDetectionService = PatternDetectionService(storage: analyticsStorage, configuration:.shared)
        analyticsReporter = AnalyticsReporter(analyticsStorage: analyticsStorage)
        eventTrackingService = EventTrackingService(storage: analyticsStorage, configuration:.shared)
        analyticsCoordinator = AnalyticsCoordinator(
            eventTrackingService: eventTrackingService,
            patternDetectionService: patternDetectionService,
            configuration:.shared,
            storage: analyticsStorage,
            aggregator: analyticsAggregator,
            processor: analyticsProcessor,
            reporter: analyticsReporter
        )
        cravingListViewModel = CravingListViewModel(cravingRepository: CravingRepositoryImpl(cravingManager: cravingManager, mapper: CravingMapper()))
        dateListViewModel = DateListViewModel(cravingRepository: CravingRepositoryImpl(cravingManager: cravingManager, mapper: CravingMapper()))
        logCravingViewModel = LogCravingViewModel(cravingRepository: CravingRepositoryImpl(cravingManager: cravingManager, mapper: CravingMapper()))
        analyticsDashboardViewModel = AnalyticsDashboardViewModel(analyticsManager: AnalyticsManager(modelContext: modelContext))
        analyticsViewModel = AnalyticsViewModel(analyticsManager: AnalyticsManager(modelContext: modelContext))
    }
}
