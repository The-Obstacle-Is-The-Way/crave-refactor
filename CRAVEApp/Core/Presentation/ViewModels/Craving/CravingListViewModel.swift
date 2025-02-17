// Core/Presentation/ViewModels/Craving/CravingListViewModel.swift
import Foundation
import SwiftUI

@MainActor
public final class CravingListViewModel: ObservableObject {
    @Published public var cravings: [CravingEntity] = []
    @Published public var errorMessage: String?
    @Published public var isLoading = false
    
    private let fetchCravingsUseCase: FetchCravingsUseCaseProtocol
    private let archiveCravingUseCase: ArchiveCravingUseCaseProtocol
    
    public init(
        fetchCravingsUseCase: FetchCravingsUseCaseProtocol,
        archiveCravingUseCase: ArchiveCravingUseCaseProtocol
    ) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
        self.archiveCravingUseCase = archiveCravingUseCase
    }
    
    public func loadCravings() async {
        isLoading = true
        do {
            cravings = try await fetchCravingsUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func archiveCraving(_ craving: CravingEntity) async {
        do {
            try await archiveCravingUseCase.execute(craving)
            await loadCravings()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
