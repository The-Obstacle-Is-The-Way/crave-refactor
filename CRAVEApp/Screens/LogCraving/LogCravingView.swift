//
//  🍒
//  CRAVEApp/Screens/LogCraving/LogCravingView.swift
//
//

import SwiftUI
import SwiftData

struct LogCravingView: View {
    @Environment(\.modelContext) private var modelContext // Get context from environment
    @StateObject private var viewModel = LogCravingViewModel() // Create ViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView { // Wrap in NavigationView
            VStack {
                CraveTextEditor(text: $viewModel.cravingText, placeholder: "Enter craving...")
                    .padding()

                CraveButton(title: "Log Craving") {
                    viewModel.addCraving(modelContext: modelContext) { success in // Pass modelContext
                        if success {
                            //CRAVEDesignSystem.Haptics.success() // Removed haptics, as it is not defined
                        } else {
                            alertMessage = "Please enter a valid craving (at least 3 characters)."
                            showAlert = true
                            //CRAVEDesignSystem.Haptics.error() // Removed haptics
                        }
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Log Craving") // Keep navigationTitle
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
