//
//  LogCravingView.swift
//  CRAVE
//
//  Created by John H Jung on 12/12/25
//

import UIKit
import SwiftUI
import SwiftData
import Foundation

struct LogCravingView: View {
    @Environment(\.modelContext) private var context

    // View-specific state and logic
    @State private var viewModel = LogCravingViewModel()
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: CRAVEDesignSystem.Layout.standardPadding) {
                Text("Log a Craving")
                    .font(CRAVEDesignSystem.Typography.titleFont)

                // A custom text editor with placeholder (CraveTextEditor.swift)
                CraveTextEditor(text: $viewModel.cravingText, placeholder: "Describe your craving...")

                // A custom button style (CraveButton.swift)
                CraveButton(title: "Submit") {
                    if viewModel.cravingText.isEmpty {
                        showAlert = true
                    } else {
                        viewModel.submitCraving(context: context) // ✅ Ensured function is called
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
