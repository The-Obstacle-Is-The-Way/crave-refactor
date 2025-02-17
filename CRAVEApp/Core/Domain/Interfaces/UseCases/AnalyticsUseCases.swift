// Core/Domain/UseCases/AnalyticsUseCases.swift

import Foundation

// MARK: - Protocols

protocol GetBasicAnalyticsUseCaseProtocol {
    func execute() async throws -> BasicAnalyticsResult
}

// Add other analytics-related use case protocols here
// (e.g., FetchInsightsUseCase, DetectPatternsUseCase, etc.)

// MARK: - Use Case Implementations

final class GetBasicAnalyticsUseCase: GetBasicAnalyticsUseCaseProtocol {
    private let analyticsManager: AnalyticsManager

    init(analyticsManager: AnalyticsManager) {
        self.analyticsManager = analyticsManager
    }

    func execute() async throws -> BasicAnalyticsResult {
        return try await analyticsManager.getBasicStats()
    }
}

// Add other analytics use case implementations here

// MARK: - Error Handling (if needed)

// You might have analytics-specific errors, or you could reuse
// errors from a more general location (e.g., a shared 'AppError' enum).

// MARK: - Dependency Injection (Add to DependencyContainer)
/*
    //In Dependency Container
    let getBasicAnalyticsUseCase: GetBasicAnalyticsUseCase(analyticsManager: analyticsManager)

    //Add properties to access the use cases:
     let getBasicAnalyticsUseCase: GetBasicAnalyticsUseCaseProtocol
*/

// MARK: - Usage in ViewModel (Example)
/*
 class AnalyticsViewModel: ObservableObject {
     @Published var basicAnalytics: BasicAnalyticsResult?
     private let getBasicAnalyticsUseCase: GetBasicAnalyticsUseCaseProtocol

     init(getBasicAnalyticsUseCase: GetBasicAnalyticsUseCaseProtocol) {
         self.getBasicAnalyticsUseCase = getBasicAnalyticsUseCase
     }

     func loadAnalytics() {
         Task {
             do {
                 basicAnalytics = try await getBasicAnalyticsUseCase.execute()
             } catch {
                 // Handle error
                 print("Error loading analytics: \(error)")
             }
         }
     }
 }
 */


