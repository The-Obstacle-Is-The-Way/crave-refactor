//
//
//  🍒
//  CRAVEApp/Core/DesignSystem/Components/CraveTextEditor.swift
//  Purpose: A custom TextEditor with a placeholder and character limit.
//
//

import SwiftUI

struct CraveTextEditor: View {
    @Binding var text: String
    var placeholder: String = "Enter craving..."
    var characterLimit: Int? = 280 // Add an optional character limit

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder Text (only visible when text is empty)
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(CRAVEDesignSystem.Colors.textSecondary)
                    .font(CRAVEDesignSystem.Typography.body) // Use Design System
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12) // Vertical padding for alignment
            }

            // The actual TextEditor
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .padding(4)
                .background(CRAVEDesignSystem.Colors.tertiaryBackground) // Use Design System
                .cornerRadius(CRAVEDesignSystem.Layout.cornerRadius)      // Use Design System
                .font(CRAVEDesignSystem.Typography.body)             // Use Design System
                .foregroundColor(CRAVEDesignSystem.Colors.textPrimary)    // Use Design System
                .scrollContentBackground(.hidden) // Hides the default opaque background on newer iOS versions
                .accessibilityIdentifier("CravingTextEditor")
                .overlay( // Display character count, if a limit is set
                    characterLimit.map { limit in
                        HStack {
                            Spacer()
                            Text("\(text.count) / \(limit)")
                                .font(CRAVEDesignSystem.Typography.caption2)
                                .foregroundColor(text.count > limit ? CRAVEDesignSystem.Colors.danger : CRAVEDesignSystem.Colors.textSecondary)
                                .padding(.trailing, 8)
                                .padding(.bottom, 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .background(Color.clear) // Important: make the overlay background clear
                    },
                    alignment: .bottomTrailing // Align to bottom-trailing corner
                )
        }
        //FIXED onChange
        .onChange(of: text) { oldValue, newValue in
            if let limit = characterLimit, newValue.count > limit {
                text = String(newValue.prefix(limit))
                CRAVEDesignSystem.Haptics.notification(type: .warning)
            }
        }
    }
}
