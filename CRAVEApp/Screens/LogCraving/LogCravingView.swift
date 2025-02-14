// CRAVEApp/Screens/LogCraving/LogCravingView.swift
import SwiftUI
import SwiftData

struct LogCravingView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var cravingManager = CravingManager() // Create the manager here
    @State private var cravingText: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        // NavigationView removed: Already inside a NavigationStack
        VStack {
            CraveTextEditor(text: $cravingText, placeholder: "Enter craving...")
                .padding()

            CraveButton(title: "Log Craving") {
                logCraving()
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
        .onAppear {
            cravingManager.modelContext = modelContext // Inject the context
        }
    }

    private func logCraving() {
        let trimmedText = cravingText.trimmingCharacters(in: .whitespacesAndNewlines)

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

        let newCraving = CravingModel(cravingText: trimmedText, timestamp: Date())
        cravingManager.insert(newCraving) // Use CravingManager

        cravingText = "" // Clear the text field
        CRAVEDesignSystem.Haptics.success() // Success haptic
    }
}

