//  CRAVEApp/Core/Presentation/Views/Craving/Logging/LogCravingView.swift

import SwiftUI
import SwiftData

struct LogCravingView: View {
    @Environment(DependencyContainer.self) private var container
    @StateObject private var viewModel: LogCravingViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""

    init(viewModel: LogCravingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack {
                CraveTextEditor(text: $viewModel.cravingText, placeholder: "Enter craving...")
                  .padding()

                CraveButton(title: "Log Craving") {
                    viewModel.addCraving { success in
                        if success {
                            // TODO: Handle success (e.g., navigate to another view)
                        } else {
                            alertMessage = "Please enter a valid craving (at least 3 characters)."
                            showAlert = true
                        }
                    }
                }
              .padding()

                Spacer()
            }
          .navigationTitle("Log Craving")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
                ToolbarItem(placement:.principal) {
                    Text("Log Craving")
                      .font(CRAVEDesignSystem.Typography.headline)
                      .foregroundColor(CRAVEDesignSystem.Colors.textPrimary)
                }
            }
          .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text(alertMessage),
                    dismissButton:.default(Text("OK"))
                )
            }
        }
    }
}
