//
//
// CraveTextEditor.swift
//
//

import SwiftUI

struct CraveTextEditor: View {
    @Binding var text: String
    var placeholder: String = "Enter craving..."

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8) //  increased padding
                    .padding(.vertical, 12)  //  Ensures placeholder aligns better
            }
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .padding(4)
                .background(Color(UIColor.secondarySystemBackground)) // Consistent background
                .cornerRadius(8)
                .font(.body)  // Consistent font
                .accessibilityIdentifier("CravingTextEditor")
        }
    }
}
