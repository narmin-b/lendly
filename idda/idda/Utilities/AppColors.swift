//
//  AppColors.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//  Updated based on design.js specifications
//

import SwiftUI

extension Color {
    // MARK: - Base Colors
    // Background Screen: Main app background
    static let backgroundScreen = Color(hex: "1C1D22")
    
    // Card Background / Container Background: Primary card background
    static let cardBackgroundLight = Color(hex: "282930")
    
    // Card Background Dark: Secondary card background
    static let cardBackgroundDark = Color(hex: "232528")
    
    // Third Background: Small detail backgrounds
    static let thirdBackground = Color(hex: "32363F")
    
    // Neutral Light Gray: For inputs, dropdowns, secondary containers
    static let neutralLightGray = Color(hex: "32363F")
    
    // MARK: - Accent Colors
    // Accent Green: Primary accent color
    static let accentGreen = Color(hex: "A4EE6F")
    
    // Secondary Accent Gray: Secondary accent
    static let secondaryAccentGray = Color(hex: "939498")
    
    // Popping Colors: For special highlights
    static let accentRed = Color(hex: "FF4444")
    static let accentGold = Color(hex: "FFD700")
    static let accentSilver = Color(hex: "C0C0C0")
    
    // Legacy Purple (mapped to green for compatibility)
    static let accentPurple = accentGreen
    
    // MARK: - Text Colors (for dark background contrast)
    // Text Primary: White for primary text
    static let textPrimaryDark = Color(hex: "FFFFFF")
    
    // Text Secondary: Secondary accent gray for secondary text
    static let textSecondaryDark = Color(hex: "939498")
    
    // Text On Accent: Dark text on light accent backgrounds
    static let textOnAccent = Color(hex: "1C1D22")
    
    // MARK: - Legacy Support (mapped to new colors)
    static let appPink = accentGreen
    static let appRed = accentGreen
    static let darkHeader = cardBackgroundDark
    static let lightBackground = backgroundScreen
    
    // MARK: - Gradients
    static var appGradient: LinearGradient {
        LinearGradient(
            colors: [accentGreen, accentPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var greenGradient: LinearGradient {
        LinearGradient(
            colors: [accentGreen.opacity(0.8), accentGreen],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var purpleGradient: LinearGradient {
        LinearGradient(
            colors: [accentPurple.opacity(0.8), accentPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

