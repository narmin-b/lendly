//
//  BubbleShape.swift
//  idda
//
//  Created for Duolingo-style bubble with pointer
//

import SwiftUI

// MARK: - Bubble Shape with Pointer
struct BubbleShape: Shape {
    var pointerPosition: PointerPosition
    var cornerRadius: CGFloat = 20
    
    enum PointerPosition {
        case top
        case bottom
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = cornerRadius
        let pointerSize: CGFloat = 12
        let pointerWidth: CGFloat = 20
        
        switch pointerPosition {
        case .top:
            // Start from top-left corner (after pointer)
            path.move(to: CGPoint(x: rect.midX - pointerWidth / 2, y: radius))
            
            // Draw pointer (triangle pointing up)
            path.addLine(to: CGPoint(x: rect.midX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX + pointerWidth / 2, y: radius))
            
            // Top-right corner
            path.addLine(to: CGPoint(x: rect.width - radius, y: radius))
            path.addArc(
                center: CGPoint(x: rect.width - radius, y: radius),
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
            
            // Right edge
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
            
            // Bottom-right corner
            path.addArc(
                center: CGPoint(x: rect.width - radius, y: rect.height - radius),
                radius: radius,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
            
            // Bottom edge
            path.addLine(to: CGPoint(x: radius, y: rect.height))
            
            // Bottom-left corner
            path.addArc(
                center: CGPoint(x: radius, y: rect.height - radius),
                radius: radius,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
            
            // Left edge
            path.addLine(to: CGPoint(x: 0, y: radius))
            
            // Top-left corner
            path.addArc(
                center: CGPoint(x: radius, y: radius),
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
            
        case .bottom:
            // Start from top-left corner
            path.move(to: CGPoint(x: radius, y: 0))
            
            // Top-left corner
            path.addArc(
                center: CGPoint(x: radius, y: radius),
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
            
            // Top edge
            path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
            
            // Top-right corner
            path.addArc(
                center: CGPoint(x: rect.width - radius, y: radius),
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
            
            // Right edge
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius - pointerSize))
            
            // Bottom-right corner
            path.addArc(
                center: CGPoint(x: rect.width - radius, y: rect.height - radius - pointerSize),
                radius: radius,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
            
            // Draw pointer (triangle pointing down)
            path.addLine(to: CGPoint(x: rect.midX + pointerWidth / 2, y: rect.height - pointerSize))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
            path.addLine(to: CGPoint(x: rect.midX - pointerWidth / 2, y: rect.height - pointerSize))
            
            // Bottom-left corner
            path.addArc(
                center: CGPoint(x: radius, y: rect.height - radius - pointerSize),
                radius: radius,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
            
            // Left edge
            path.addLine(to: CGPoint(x: 0, y: radius))
        }
        
        path.closeSubpath()
        return path
    }
}


