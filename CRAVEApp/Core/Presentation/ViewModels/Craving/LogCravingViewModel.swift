import Foundation

public final class LogCravingViewModel: ObservableObject {
    @Published public var cravingText: String = ""
    private let addCravingUseCase: AddCravingUseCaseProtocol

    public init(addCravingUseCase: AddCravingUseCaseProtocol) {
        self.addCravingUseCase = addCravingUseCase
    }

    public func addCraving() {
        Task {
            do {
                _ = try await addCravingUseCase.execute(cravingText: cravingText)
                cravingText = ""
            } catch {
                print("Error adding craving: \(error)")
            }
        }
    }
}

