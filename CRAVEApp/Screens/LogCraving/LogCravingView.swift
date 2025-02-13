// LogCravingView.swift
// UI screen for creating a new craving.

import SwiftUI
import SwiftData

struct LogCravingView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = LogCravingViewModel()
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: CRAVEDesignSystem.Layout.standardPadding) {
                Text("Log a Craving")
                    .font(CRAVEDesignSystem.Typography.titleFont)

                CraveTextEditor(
                    text: $viewModel.cravingText,
                    placeholder: "Describe your craving..."
                )

                CraveButton(title: "Submit") {
                    if viewModel.cravingText.isEmpty {
                        showAlert = true
                    } else {
                        viewModel.submitCraving(context: context)
                    }
                }
                .alert("Please enter a craving", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Log Craving")
        }
    }
}
