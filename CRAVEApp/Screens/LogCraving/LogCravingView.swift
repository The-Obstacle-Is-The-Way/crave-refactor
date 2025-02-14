//
//  LogCravingView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct LogCravingView: View {
    @Environment(\.modelContext) private var modelContext // Get the ModelContext
    @StateObject private var cravingManager = CravingManager() // Use CravingManager
    @State private var cravingText: String = ""
    @State private var showAlert = false  //for the alert
    @State private var alertMessage = "" //for the alert


    var body: some View {
        NavigationView {
            VStack {
                CraveTextEditor(text: $cravingText, placeholder: "Enter craving...") // Use the custom text editor
                    .padding()

                CraveButton(title: "Log Craving") {
                    logCraving()
                }
                .padding()

                Spacer() // Push content to the top
            }
            .navigationTitle("Log Craving")
            .alert(isPresented: $showAlert) {   //the alert
                Alert(
                    title: Text("Invalid Input"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {  // Set the modelContext for CravingManager
            cravingManager.modelContext = modelContext
        }
    }

    private func logCraving() {
        // 1. Trim whitespace
        let trimmedText = cravingText.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. Validate input
        if trimmedText.isEmpty {
            alertMessage = "Please enter a craving."
            showAlert = true
            CRAVEDesignSystem.Haptics.error()
            return
        }

        if trimmedText.count < 3 {
            alertMessage = "Craving must be at least 3 characters."
            showAlert = true
            CRAVEDesignSystem.Haptics.error()
            return
        }

        // 3. Create and insert the craving using CravingManager
        let newCraving = CravingModel(cravingText: trimmedText, timestamp: Date())
        cravingManager.insert(newCraving) // Use CravingManager to insert!

        // 4. Reset the text field
        cravingText = ""

        // 5. (Optional) Show a success message/haptic - GOOD practice
        CRAVEDesignSystem.Haptics.success()
    }
}

#Preview {
    LogCravingView()
        .modelContainer(for: CravingModel.self)
}

