//
//  View+Extensions.swift
//  CRAVE
//
//  Created by Your Name on 2/12/25.
//

import UIKit
import SwiftUI

extension View {
    /// Quickly wrapsa the view in a background and corner radius defined by the design system.
    func craveCardStyle() -> some View {
        self
            .padding(CRAVEDesignSystem.Layout.standardPadding)
            .background(CRAVEDesignSystem.Colors.secondaryBackground)
            .cornerRadius(CRAVEDesignSystem.Layout.cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    /// Example specialized corner rounding if you ever want more control.
    /// Use SwiftUI's 'clipShape' to mask specific corners.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

/// A helper shape for partial corner rounding. Can be placed within this file.
struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

