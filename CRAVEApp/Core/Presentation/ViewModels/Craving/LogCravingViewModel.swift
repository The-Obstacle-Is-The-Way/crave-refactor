// Core/Presentation/ViewModels/Craving/LogCravingViewModel.swift
import Foundation

@MainActor
public final class LogCravingViewModel: ObservableObject {
    @Published public var cravingText = ""
    @Published public var errorMessage: String?
    @Published public var isLoading = false
    
    private let addCravingUseCase: AddCravingUseCaseProtocol
    
    public init(addCravingUseCase: AddCravingUseCaseProtocol) {
        self.addCravingUseCase = addCravingUseCase
    }
    
    public func logCraving() async -> Bool {
        isLoading = true
        do {
            _ = try await addCravingUseCase.execute(cravingText: cravingText)
            cravingText = ""
            errorMessage = nil
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
