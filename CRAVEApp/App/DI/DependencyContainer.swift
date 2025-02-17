import SwiftUI
import SwiftData

@Observable
@MainActor
final class DependencyContainer {
    let modelContext: ModelContext
    
    // Repositories
    let cravingRepository: any CravingRepository
    
    // Services
    let cravingManager: CravingManager
    let cravingAnalyzer: CravingAnalyzer
    let analyticsStorage: AnalyticsStorage
    let analyticsAggregator: AnalyticsAggregator
    let analyticsProcessor: AnalyticsProcessor
    let patternDetectionService: PatternDetectionService
    let analyticsReporter: AnalyticsReporter
    let eventTrackingService: EventTrackingService
    let analyticsCoordinator: AnalyticsCoordinator

    // ViewModels
    let cravingListViewModel: CravingListViewModel
    let dateListViewModel: DateListViewModel
    let logCravingViewModel: LogCravingViewModel
    let analyticsDashboardViewModel: AnalyticsDashboardViewModel
    let analyticsViewModel: AnalyticsViewModel

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Initialize managers and services
        self.cravingManager = CravingManager(modelContext: modelContext)
        self.analyticsStorage = AnalyticsStorage(modelContext: modelContext)
        
        // Initialize repository
        let cravingMapper = CravingMapper()
        self.cravingRepository = CravingRepositoryImpl(cravingManager: cravingManager, mapper: cravingMapper)
        
        // Initialize other services
        self.cravingAnalyzer = CravingAnalyzer()
        self.analyticsAggregator = AnalyticsAggregator(storage: analyticsStorage)
        self.analyticsProcessor = AnalyticsProcessor(configuration: AnalyticsConfiguration.shared, storage: analyticsStorage)
        self.patternDetectionService = PatternDetectionService(storage: analyticsStorage, configuration: AnalyticsConfiguration.shared)
        self.analyticsReporter = AnalyticsReporter(analyticsStorage: analyticsStorage)
        self.eventTrackingService = EventTrackingService(storage: analyticsStorage, configuration: AnalyticsConfiguration.shared)
        
        // Initialize coordinators
        self.analyticsCoordinator = AnalyticsCoordinator(
            eventTrackingService: eventTrackingService,
            patternDetectionService: patternDetectionService,
            configuration: AnalyticsConfiguration.shared,
            storage: analyticsStorage,
            aggregator: analyticsAggregator,
            processor: analyticsProcessor,
            reporter: analyticsReporter
        )
        
        // Initialize ViewModels
        self.cravingListViewModel = CravingListViewModel(cravingRepository: cravingRepository)
        self.dateListViewModel = DateListViewModel(cravingRepository: cravingRepository)
        self.logCravingViewModel = LogCravingViewModel(addCravingUseCase: AddCravingUseCase(cravingRepository: cravingRepository))
        self.analyticsDashboardViewModel = AnalyticsDashboardViewModel(analyticsManager: AnalyticsManager(analyticsCoordinator: analyticsCoordinator))
        self.analyticsViewModel = AnalyticsViewModel(analyticsManager: AnalyticsManager(analyticsCoordinator: analyticsCoordinator))
    }
}

