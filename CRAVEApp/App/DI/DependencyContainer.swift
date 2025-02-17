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
    
    public func makeAnalyticsDashboardView() -> AnalyticsDashboardView {
        let viewModel = makeAnalyticsDashboardViewModel()
        return AnalyticsDashboardView(viewModel: viewModel)
    }
    
    private func makeAnalyticsDashboardViewModel() -> AnalyticsDashboardViewModel {
        AnalyticsDashboardViewModel(modelContext: modelContainer.mainContext)
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
    
    private func makeAddCravingUseCase() -> AddCravingUseCaseProtocol {
        AddCravingUseCase(cravingRepository: makeCravingRepository())
    }
    
    private func makeFetchCravingsUseCase() -> FetchCravingsUseCaseProtocol {
        FetchCravingsUseCase(cravingRepository: makeCravingRepository())
    }
    
    private func makeArchiveCravingUseCase() -> ArchiveCravingUseCaseProtocol {
        ArchiveCravingUseCase(cravingRepository: makeCravingRepository())
    }
    
    public func makeLogCravingViewModel() -> LogCravingViewModel {
        LogCravingViewModel(addCravingUseCase: makeAddCravingUseCase())
    }
}
