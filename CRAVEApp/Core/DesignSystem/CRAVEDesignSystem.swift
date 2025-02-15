//
//  CRAVEDesignSystem.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

/* A simple, centralized design system for CRAVE.
Keeps brand colors, typography, layout metrics, and haptics in one place
so the UI stays consistent across the entire app. */

import UIKit
import SwiftUI

enum CRAVEDesignSystem {
    
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    }

    enum Typography {
        static let titleFont    = Font.system(size: 20, weight: .bold)
        static let headingFont  = Font.system(size: 17, weight: .semibold)
        static let bodyFont     = Font.system(size: 16, weight: .regular)
        static let captionFont  = Font.system(size: 14, weight: .regular)
    }

    enum Layout {
        static let standardPadding: CGFloat = 16
        static let compactPadding: CGFloat  = 8
        static let buttonHeight: CGFloat    = 50
        static let textFieldHeight: CGFloat = 40
        static let cornerRadius: CGFloat    = 8
    }

    enum Animation {
        static let standardDuration = 0.3
        static let quickDuration    = 0.2
    }
}
