//
//
//  🍒
//  CRAVEApp/Core/DesignSystem/Components/CraveButton.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import SwiftUI

struct CraveButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false // Track pressed state

    var body: some View {
        Button(action: {
            // Haptic feedback on tap *before* the action
            CRAVEDesignSystem.Haptics.lightImpact()
            self.isPressed = true // Set pressed state
            
            // Use a DispatchQueue to reset isPressed after a short delay,
            // even if the action takes some time to complete.
            DispatchQueue.main.asyncAfter(deadline: .now() + CRAVEDesignSystem.Animation.quickDuration) {
                self.isPressed = false
                self.action() // Perform the button's action
            }
        }) {
            Text(title)
                .font(CRAVEDesignSystem.Typography.headline) // Use headline font
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: CRAVEDesignSystem.Layout.buttonHeight)
                .foregroundColor(CRAVEDesignSystem.Colors.textOnPrimary) // Use textOnPrimary
                .background(CRAVEDesignSystem.Colors.primary) // Use primary color
                .cornerRadius(CRAVEDesignSystem.Layout.cornerRadius)
                // Apply a subtle scale effect while pressed
                .scaleEffect(isPressed ? 0.95 : 1.0)
                // Animate the scale change
                .animation(Animation.easeInOut(duration: CRAVEDesignSystem.Animation.quickDuration), value: isPressed)
        }
        .accessibilityIdentifier(title == "Submit" ? "SubmitButton" : "CraveButton_\(title)")
    }
}

