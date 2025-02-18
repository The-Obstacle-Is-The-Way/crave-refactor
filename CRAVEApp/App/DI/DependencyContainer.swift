// App/DI/DependencyContainer.swift
import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
public final class DependencyContainer: ObservableObject {
    @Published private(set) var modelContainer: ModelContainer

    public init() {
        let schema = Schema([
            CravingEntity.self,
            AnalyticsMetadata.self  // Make sure ALL your persistent models are here!
        ])
        do {
            self.modelContainer = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Analytics Dependencies

    private func makeAnalyticsStorage() -> AnalyticsStorage {
        AnalyticsStorage(modelContext: modelContainer.mainContext)
    }

    private func makeAnalyticsMapper() -> AnalyticsMapper {
        return AnalyticsMapper()
    }

    private func makeAnalyticsRepository() -> AnalyticsRepository {
        return AnalyticsRepositoryImpl(storage: makeAnalyticsStorage(), mapper: makeAnalyticsMapper())
    }

    private func makeAnalyticsAggregator() -> AnalyticsAggregator {
        return AnalyticsAggregator(storage: makeAnalyticsStorage())
    }

    private func makePatternDetectionService() -> PatternDetectionService {
        return PatternDetectionService(storage: makeAnalyticsStorage(), configuration: AnalyticsConfiguration.shared)
    }
    
    //Correctly creates the manager with repository
    private func makeAnalyticsManager() -> AnalyticsManager {
        return AnalyticsManager(repository: makeAnalyticsRepository(), aggregator: makeAnalyticsAggregator(), patternDetection: makePatternDetectionService())
    }

    // MARK: - Craving Dependencies (These are fine as they are)
    private func makeCravingManager() -> CravingManager {
        CravingManager(modelContext: modelContainer.mainContext)
    }

    private func makeCravingRepository() -> CravingRepository {
        CravingRepositoryImpl(cravingManager: makeCravingManager())
    }

    private func makeAddCravingUseCase() -> AddCravingUseCaseProtocol {
        AddCravingUseCase(cravingRepository: makeCravingRepository())
    }

    private func makeFetchCravingsUseCase() -> FetchCravingsUseCaseProtocol {
        FetchCravingsUseCase(cravingRepository: makeCravingRepository())
    }

    private func makeArchiveCravingUseCase() -> ArchiveCravingUseCaseProtocol {
        ArchiveCravingUseCase(cravingRepository: makeCravingRepository())
    }

    // MARK: - View Models
    //Correctly creates view models
    public func makeAnalyticsDashboardViewModel() -> AnalyticsDashboardViewModel {
        AnalyticsDashboardViewModel(manager: makeAnalyticsManager()) // Inject the manager
    }

    public func makeCravingListViewModel() -> CravingListViewModel {
        CravingListViewModel(
            fetchCravingsUseCase: makeFetchCravingsUseCase(),
            archiveCravingUseCase: makeArchiveCravingUseCase()
        )
    }

    public func makeLogCravingViewModel() -> LogCravingViewModel {
        LogCravingViewModel(addCravingUseCase: makeAddCravingUseCase())
    }
}

