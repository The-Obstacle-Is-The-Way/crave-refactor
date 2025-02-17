import Foundation

public final class CravingListViewModel: ObservableObject {
    @Published public var cravings: [CravingEntity] = []
    private let cravingRepository: CravingRepository

    public init(cravingRepository: CravingRepository) {
        self.cravingRepository = cravingRepository
    }

    public func loadCravings() async {
        do {
            cravings = try await cravingRepository.fetchAllActiveCravings()
        } catch {
            print("Error loading cravings: \(error)")
        }
    }
}

