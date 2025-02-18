//  App/DI/DependencyContainer.swift
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
            AnalyticsMetadata.self  // Ensure all your entities are here
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
    
    private func makeAnalyticsManager() -> AnalyticsManager {
        let storage = makeAnalyticsStorage()
        let aggregator = AnalyticsAggregator(storage: storage)
        let patternDetection = PatternDetectionService(
            storage: storage,
            configuration: AnalyticsConfiguration.shared
        )
        return AnalyticsManager(
            storage: storage,
            aggregator: aggregator,
            patternDetection: patternDetection
        )
    }
    
    // MARK: - Craving Dependencies
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
    
    //Corrected reference
    public func makeAnalyticsDashboardViewModel() -> AnalyticsDashboardViewModel {
        AnalyticsDashboardViewModel(modelContext: modelContainer.mainContext)
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

