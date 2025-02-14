//
//  LogCravingView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct LogCravingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var cravingText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                CraveTextEditor(text: $cravingText, placeholder: "Enter craving...") // ✅ Using custom text editor

                CraveButton(title: "Log Craving") { // ✅ Using custom button
                    if !cravingText.isEmpty {
                        saveCraving()
                    }
                }
                .disabled(cravingText.isEmpty) // Disable button for empty input
                .padding()

                Spacer()
            }
            .navigationTitle("Log Craving")
            .padding()
        }
    }

    // MARK: - Save Craving
    private func saveCraving() {
        let newCraving = CravingModel(cravingText: cravingText, timestamp: Date())
        modelContext.insert(newCraving)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving craving: \(error)")
        }
    }
}

// ✅ Preview with sample data
struct LogCravingView_Previews: PreviewProvider {
    static var previews: some View {
        LogCravingView()
            .modelContainer(for: CravingModel.self, inMemory: true)
    }
}


