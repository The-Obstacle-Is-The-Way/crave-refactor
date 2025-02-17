
// Core/Domain/UseCases/CravingUseCases.swift

import Foundation

// MARK: - Protocols

protocol AddCravingUseCaseProtocol {
    func execute(cravingText: String) async throws -> CravingEntity
}

protocol FetchCravingsUseCaseProtocol {
    func execute() async throws -> [CravingEntity]
}

protocol ArchiveCravingUseCaseProtocol {
    func execute(craving: CravingEntity) async throws
}
protocol DeleteCravingUseCaseProtocol {
    func execute(craving: CravingEntity) async throws
}

// MARK: - Use Case Implementations

final class AddCravingUseCase: AddCravingUseCaseProtocol {
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    func execute(cravingText: String) async throws -> CravingEntity {
        let trimmedText = cravingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, trimmedText.count >= 3 else {
            throw CravingError.invalidInput // Define this error
        }

        let newCraving = CravingEntity(id: UUID(), text: trimmedText, timestamp: Date(), isArchived: false)
        cravingRepository.addCraving(newCraving)
        return newCraving
    }
}

final class FetchCravingsUseCase: FetchCravingsUseCaseProtocol {
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    func execute() async throws -> [CravingEntity] {
        return try await cravingRepository.fetchAllActiveCravings()
    }
}

final class ArchiveCravingUseCase: ArchiveCravingUseCaseProtocol {
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    func execute(craving: CravingEntity) async throws {
        cravingRepository.archiveCraving(craving)
    }
}

final class DeleteCravingUseCase: DeleteCravingUseCaseProtocol{
    private let cravingRepository: CravingRepository

    init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    func execute(craving: CravingEntity) async throws {
        cravingRepository.deleteCraving(craving)
    }
}

// MARK: - Error Handling (Example)

enum CravingError: Error {
    case invalidInput
    case storageError(Error) // Wrap underlying storage errors
    // Add other specific errors as needed
}

// MARK: - Dependency Injection (Add to DependencyContainer)

// In your DependencyContainer.swift:
/*
    ...
    // Inside init:
    let addCravingUseCase = AddCravingUseCase(cravingRepository: cravingRepository)
    let fetchCravingsUseCase = FetchCravingsUseCase(cravingRepository: cravingRepository)
    let archiveCravingUseCase = ArchiveCravingUseCase(cravingRepository: cravingRepository)
    ...

    // Add properties to access the use cases:
    let addCravingUseCase: AddCravingUseCaseProtocol
    let fetchCravingsUseCase: FetchCravingsUseCaseProtocol
    let archiveCravingUseCase: ArchiveCravingUseCaseProtocol
*/

// MARK: - Usage in ViewModel (Example)
/*
 class LogCravingViewModel: ObservableObject {
     @Published var cravingText: String = ""
     private let addCravingUseCase: AddCravingUseCaseProtocol

     init(addCravingUseCase: AddCravingUseCaseProtocol) {
         self.addCravingUseCase = addCravingUseCase
     }

     func addCraving() {
         Task {
             do {
                 let newCraving = try await addCravingUseCase.execute(cravingText: cravingText)
                 // Handle success (e.g., clear the text field, navigate)
                 cravingText = ""
             } catch {
                 // Handle error (e.g., show an alert)
                 print("Error adding craving: \(error)")
             }
         }
     }
 }
 */
