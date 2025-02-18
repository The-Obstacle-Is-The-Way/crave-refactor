// File: Core/Presentation/Views/Craving/LogCravingView.swift

import SwiftUI

@MainActor
public struct LogCravingView: View {
    @ObservedObject var viewModel: LogCravingViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    public init(viewModel: LogCravingViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    public var body: some View {
        NavigationView {
            Form {
                TextField("Enter craving", text: $viewModel.cravingText)
                    .textInputAutocapitalization(.never)
                
                Button("Log Craving") {
                    Task {
                        // Attempt to log the craving
                        await viewModel.logCraving()
                        // If no alert was triggered, we can assume success and dismiss
                        if !viewModel.showingAlert {
                            dismiss()
                        }
                    }
                }
                // Disable if the text is empty (or you can refine logic as needed)
                .disabled(viewModel.cravingText.isEmpty)
            }
            .navigationTitle("Log Craving")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
            // Present alert if there's an error
            .alert("Error",
                   isPresented: $viewModel.showingAlert,
                   actions: { Button("OK", role: .cancel) {} },
                   message: {
                       Text(viewModel.alertMessage)
                   }
            )
        }
    }
}

// MARK: - Preview
struct LogCravingView_Previews: PreviewProvider {
    static var previews: some View {
        // Supply a mock or real use case as desired:
        let mockUseCase = MockAddCravingUseCase()
        let viewModel = LogCravingViewModel(addCravingUseCase: mockUseCase)
        
        return LogCravingView(viewModel: viewModel)
    }
}

// MARK: - Example MockAddCravingUseCase
final class MockAddCravingUseCase: AddCravingUseCaseProtocol {
    func execute(cravingText: String) async throws -> CravingEntity {
        // For preview, pretend success if text is long enough, else throw:
        guard cravingText.count >= 3 else {
            throw CravingError.invalidInput
        }
        return CravingEntity(text: cravingText)
    }
}
