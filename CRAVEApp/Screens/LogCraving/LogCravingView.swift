//
//  🍒
//  CRAVEApp/Screens/LogCraving/LogCravingView.swift
//  Purpose: A view for logging a craving.
//

import SwiftUI
import SwiftData

struct LogCravingView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext // Correct usage
    @StateObject private var viewModel = LogCravingViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                CraveTextEditor(text: $viewModel.cravingText, placeholder: "Enter craving...")
                    .padding()

                CraveButton(title: "Log Craving") {
                    viewModel.addCraving(modelContext: modelContext) { success in // Corrected: Pass modelContext
                        if success {
                            // Success
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
