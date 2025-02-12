// CraveButton.swift

import SwiftUI

struct CraveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: CRAVEDesignSystem.Layout.buttonHeight)
                .foregroundColor(.white)
                .background(CRAVEDesignSystem.Colors.primary)
                .cornerRadius(CRAVEDesignSystem.Layout.cornerRadius)
        }
    }
}
