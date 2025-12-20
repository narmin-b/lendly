//
//  DesignSystem.swift
//  idda
//
//  Created based on design.js specifications
//

import SwiftUI

// MARK: - Design System
// Based on design.js - "Modern Serenity with Playful Data"

struct DesignSystem {
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 6      // 4-8px average
        static let sm: CGFloat = 10    // 8-12px average
        static let md: CGFloat = 20    // 16-24px average
        static let lg: CGFloat = 28    // 24-32px average
        static let xl: CGFloat = 40     // 32-48px average
        static let container: CGFloat = 25  // 20-30px average
    }
    
    // MARK: - Border Radius
    struct BorderRadius {
        static let card: CGFloat = 20      // 16-24px average
        static let element: CGFloat = 10   // 8-12px average
        static let button: CGFloat = 10    // 8-12px average
        static let xs: CGFloat = 4         // Small corner radius
    }
    
    // MARK: - Typography
    struct Typography {
        // Hero: 36-48px, Bold
        static func hero(size: CGFloat = 42) -> Font {
            .system(size: size, weight: .bold, design: .default)
        }
        
        // Heading1: 24-28px, Semi-Bold/Bold
        static func heading1(size: CGFloat = 26) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        
        // Heading2: 18-20px, Semi-Bold
        static func heading2(size: CGFloat = 19) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        
        // Body: 16-18px, Regular
        static func body(size: CGFloat = 17) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }
        
        // Caption: 12-14px, Regular
        static func caption(size: CGFloat = 13) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let card = Color.black.opacity(0.05)
        static let cardRadius: CGFloat = 12
        static let cardOffset = CGSize(width: 0, height: 4)
    }
}

// MARK: - Card Modifier
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackgroundLight)
            .cornerRadius(DesignSystem.BorderRadius.card)
            .shadow(
                color: DesignSystem.Shadow.card,
                radius: DesignSystem.Shadow.cardRadius,
                x: DesignSystem.Shadow.cardOffset.width,
                y: DesignSystem.Shadow.cardOffset.height
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}


