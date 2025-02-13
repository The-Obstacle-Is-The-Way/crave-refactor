//
//  CraveButton.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import SwiftUI

struct CraveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            #if DEBUG
            print("CraveButton tapped with title: \(title)")
            #endif
            action()
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: CRAVEDesignSystem.Layout.buttonHeight)
                .foregroundColor(.white)
                .background(CRAVEDesignSystem.Colors.primary)
                .cornerRadius(CRAVEDesignSystem.Layout.cornerRadius)
        }
        // Provide a stable accessibility identifier for UI tests
        // If the button's title is "Submit", we'll use "SubmitButton" specifically
        .accessibilityIdentifier(title == "Submit" ? "SubmitButton" : "CraveButton_\(title)")
    }
}
