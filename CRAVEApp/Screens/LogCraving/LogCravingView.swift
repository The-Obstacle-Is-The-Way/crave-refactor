//
//  LogCravingView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct LogCravingView: View {
    @Environment(\.modelContext) private var modelContext // ✅ Inject ModelContext
    @Environment(\.dismiss) private var dismiss // ✅ Allows dismissing the view

    @State private var cravingText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter craving...", text: $cravingText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: saveCraving) {
                    Text("Log Craving")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cravingText.isEmpty ? Color.gray : Color.blue) // ✅ Disable button for empty input
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(cravingText.isEmpty) // ✅ Prevents empty cravings
                .padding()

                Spacer()
            }
            .navigationTitle("Log Craving")
            .padding()
        }
    }

    // MARK: - Save Craving
    private func saveCraving() {
        let newCraving = CravingModel(cravingText: cravingText, timestamp: Date()) // ✅ Create new craving
        modelContext.insert(newCraving) // ✅ Insert into SwiftData
        try? modelContext.save() // ✅ Save immediately
        dismiss() // ✅ Close view after saving
    }
}

// ✅ Preview with sample data
struct LogCravingView_Previews: PreviewProvider {
    static var previews: some View {
        LogCravingView()
            .modelContainer(for: CravingModel.self, inMemory: true)
    }
}
