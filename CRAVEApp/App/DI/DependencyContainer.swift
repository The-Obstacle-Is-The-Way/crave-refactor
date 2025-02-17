// App/DI/DependencyContainer.swift
import Foundation
import SwiftUI
import SwiftData
import Combine


public typealias ModelContainer = SwiftData.ModelContainer
public typealias ModelContext = SwiftData.ModelContext


@MainActor
public final class DependencyContainer: ObservableObject {
    @Published private(set) var modelContainer: ModelContainer


    public init() {
        let schema = Schema([
            CravingEntity.self,
            AnalyticsMetadata.self
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


    public func makeAnalyticsDashboardView() -> AnalyticsDashboardView {
        let viewModel = makeAnalyticsDashboardViewModel()
        return AnalyticsDashboardView(viewModel: viewModel)
    }


    private func makeAnalyticsDashboardViewModel() -> AnalyticsDashboardViewModel {
        AnalyticsDashboardViewModel(manager: makeAnalyticsManager())
    }


    // MARK: - Craving Dependencies
    private func makeCravingManager() -> CravingManager {
        CravingManager(modelContext: modelContainer.mainContext)
    }


    private func makeCravingRepository() -> CravingRepository {
        CravingRepositoryImpl(cravingManager: makeCravingManager())
    }


    public func makeCravingListViewModel() -> CravingListViewModel {
        CravingListViewModel(
            fetchCravingsUseCase: makeFetchCravingsUseCase(),
            archiveCravingUseCase: makeArchiveCravingUseCase()
        )
    }


    public func makeAddCravingUseCase() -> AddCravingUseCaseProtocol {
        AddCravingUseCase(cravingRepository: makeCravingRepository())
    }


    public func makeFetchCravingsUseCase() -> FetchCravingsUseCaseProtocol {
        FetchCravingsUseCase(cravingRepository: makeCravingRepository())
    }


    public func makeArchiveCravingUseCase() -> ArchiveCravingUseCaseProtocol {
        ArchiveCravingUseCase(cravingRepository: makeCravingRepository())
    }


    public func makeLogCravingViewModel() -> LogCravingViewModel {
        LogCravingViewModel(addCravingUseCase: makeAddCravingUseCase())
    }
}

