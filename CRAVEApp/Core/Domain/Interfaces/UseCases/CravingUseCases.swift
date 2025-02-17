//cravingusecases

import Foundation

public protocol AddCravingUseCaseProtocol {
    func execute(cravingText: String) async throws -> CravingEntity
}

public final class AddCravingUseCase: AddCravingUseCaseProtocol {
    private let cravingRepository: CravingRepository

    public init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    public func execute(cravingText: String) async throws -> CravingEntity {
        let trimmed = cravingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count >= 3 else {
            throw NSError(domain: "CravingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
        }
        let newCraving = CravingEntity(text: trimmed)
        cravingRepository.addCraving(newCraving)
        return newCraving
    }
}
