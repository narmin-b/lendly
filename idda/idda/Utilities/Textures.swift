//
//  Textures.swift
//  idda
//
//  Created for unique visual textures and patterns
//

import SwiftUI

// MARK: - Diagonal Stripe Pattern
struct DiagonalStripePattern: View {
    var color: Color = Color.neutralLightGray
    var lineWidth: CGFloat = 2
    var spacing: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let diagonal = sqrt(width * width + height * height)
                let step = spacing + lineWidth
                
                var x: CGFloat = -diagonal
                while x < diagonal {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + height, y: height))
                    x += step
                }
            }
            .stroke(color, lineWidth: lineWidth)
        }
    }
}

// MARK: - Dotted Pattern
struct DottedPattern: View {
    var color: Color = Color.textSecondaryDark.opacity(0.3)
    var dotSize: CGFloat = 2
    var spacing: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            let rows = Int(geometry.size.height / spacing)
            let cols = Int(geometry.size.width / spacing)
            
            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<cols, id: \.self) { col in
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .position(
                            x: CGFloat(col) * spacing + spacing / 2,
                            y: CGFloat(row) * spacing + spacing / 2
                        )
                }
            }
        }
    }
}

// MARK: - Mesh Gradient Background
struct MeshGradientBackground: View {
    var color1: Color
    var color2: Color
    var opacity: Double = 0.1
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [color1.opacity(opacity), color2.opacity(opacity)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            LinearGradient(
                colors: [color2.opacity(opacity * 0.5), color1.opacity(opacity * 0.5)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
    }
}

// MARK: - Decorative Wave Shape
struct WaveShape: Shape {
    var amplitude: CGFloat = 10
    var frequency: CGFloat = 0.1
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let y = rect.midY + amplitude * sin(frequency * x)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Organic Blob Shape
struct OrganicBlob: Shape {
    var seed: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        let points = 8
        for i in 0..<points {
            let angle = Double(i) * 2 * .pi / Double(points) + seed
            let variation = sin(seed * 2 + Double(i)) * 0.3 + 1.0
            let r = radius * CGFloat(variation)
            let x = center.x + r * cos(angle)
            let y = center.y + r * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Glow Effect
struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
}

extension View {
    func glow(color: Color, radius: CGFloat = 10) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
}

// MARK: - Animated Gradient Overlay
struct AnimatedGradientOverlay: View {
    @State private var startAngle: Double = 0
    @State private var timer: Timer?
    var colors: [Color]
    
    private func pointForAngle(_ angle: Double) -> UnitPoint {
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 2 * .pi)
        let x = 0.5 + 0.35 * cos(normalizedAngle)
        let y = 0.5 + 0.35 * sin(normalizedAngle)
        return UnitPoint(x: max(0, min(1, x)), y: max(0, min(1, y)))
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: pointForAngle(startAngle),
            endPoint: pointForAngle(startAngle + .pi)
        )
        .opacity(0.1)
        .onAppear {
            // Smooth continuous animation using timer
            timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
                withAnimation(.linear(duration: 0.03)) {
                    startAngle += 0.02
                    if startAngle >= 2 * .pi {
                        startAngle = 0
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}


