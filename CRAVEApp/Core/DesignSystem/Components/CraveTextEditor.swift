// CraveTextEditor.swift
import SwiftUI

struct CraveTextEditor: View {
    @Binding var text: String
    var placeholder: String = "Enter something..."

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
            }
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .padding(4)
                .background(CRAVEDesignSystem.Colors.secondaryBackground)
                .cornerRadius(CRAVEDesignSystem.Layout.cornerRadius)
                .font(CRAVEDesignSystem.Typography.bodyFont)
        }
    }
}
