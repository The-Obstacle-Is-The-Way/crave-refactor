// CRAVEApp/Core/Presentation/Views/Craving/LogCravingView.swift
import SwiftUI

struct LogCravingView: View {
    @ObservedObject var viewModel: LogCravingViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                TextField("Enter craving", text: $viewModel.cravingText)
                Button("Log Craving") {
                    Task {
                        await viewModel.addCraving()
                        dismiss() // Dismiss after adding
                    }
                }
                .disabled(viewModel.cravingText.isEmpty) // Disable button if text is empty
            }
            .navigationTitle("Log Craving")
            .navigationBarItems(trailing: Button("Dismiss") {
                dismiss()
            })
            .alert("Error", isPresented: $viewModel.showingAlert) { // Error Alert
               Button("OK"){}
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

