// Core/Presentation/ViewModels/Craving/CravingListViewModel.swift
import Foundation
import SwiftUI
import SwiftData

@MainActor
public final class CravingListViewModel: ObservableObject {
    @Published var cravings: [CravingEntity] = [] // Add this line
    private let fetchCravingsUseCase: FetchCravingsUseCaseProtocol
    private let archiveCravingUseCase: ArchiveCravingUseCaseProtocol

    public init(fetchCravingsUseCase: FetchCravingsUseCaseProtocol, archiveCravingUseCase: ArchiveCravingUseCaseProtocol) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
        self.archiveCravingUseCase = archiveCravingUseCase
    }

    func fetchCravings() async {
        do {
            cravings = try await fetchCravingsUseCase.execute()
        } catch {
            // Handle errors appropriately (e.g., show an alert)
            print("Error fetching cravings: \(error)")
        }
    }

    func archiveCraving(_ craving: CravingEntity) async {
        do {
            try await archiveCravingUseCase.execute(craving)
             //Refetch after archiving to update the list
            await fetchCravings()
        } catch {
            // Handle errors appropriately
            print("Error archiving craving: \(error)")
        }
    }
}

