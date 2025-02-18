// Core/Presentation/ViewModels/Craving/LogCravingViewModel.swift
import Foundation
import SwiftUI // Import SwiftUI

@MainActor
 class LogCravingViewModel: ObservableObject {
    @Published var cravingText: String = ""
    @Published var showingAlert = false // Alert presentation
    @Published var alertMessage = ""

    private let addCravingUseCase: AddCravingUseCaseProtocol

    init(addCravingUseCase: AddCravingUseCaseProtocol) {
        self.addCravingUseCase = addCravingUseCase
    }


     func addCraving() async {
         do {
             let craving = try await addCravingUseCase.execute(cravingText: cravingText)
             // Handle success, maybe clear the text field.
             cravingText = ""
         } catch let error as CravingError {
             //Present the error to the user
             alertMessage = error.localizedDescription
             showingAlert = true
             
         } catch {
             // Handle other errors
             alertMessage = error.localizedDescription
             showingAlert = true
         }
     }
}

