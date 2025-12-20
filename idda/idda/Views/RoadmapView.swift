//
//  RoadmapView.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//

import SwiftUI
import Combine
import UIKit

// MARK: - Preference Key for Button Position
struct ButtonPositionKey: PreferenceKey {
    static var defaultValue: CGPoint? = nil
    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        value = nextValue() ?? value
    }
}

// MARK: - Extension for CGRect center
extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

// MARK: - Stat Header View (Duolingo-style top bar)
struct StatHeaderView: View {
    @ObservedObject var viewModel: RoadmapViewModel
    
    var body: some View {
        ZStack {
            // Background
            Color.cardBackgroundDark
//                .overlay(
//                    // Subtle wave pattern at bottom
//                    VStack {
//                        Spacer()
//                        WaveShape(amplitude: 4, frequency: 0.05)
//                            .fill(Color.accentGreen.opacity(0.08))
//                            .frame(height: 8)
//                    }
//                )
            
            HStack(spacing: DesignSystem.Spacing.md) {
                // Total Points (Trust Score)
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ZStack {
                        Circle()
                            .fill(Color.accentGreen.opacity(0.3))
                            .frame(width: 36, height: 36)
                            .glow(color: .accentGreen, radius: 4)
                        
                        Image(systemName: "star.fill")
                            .foregroundColor(.accentGreen)
                            .font(.system(size: 24, weight: .bold))
                    }
                    
                    Text("\(viewModel.totalPoints) XP")
                        .font(DesignSystem.Typography.heading2(size: 16))
                        .foregroundColor(.textPrimaryDark)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // League/Level Indicator
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ZStack {
                        Capsule()
                            .fill(Color.accentGreen.opacity(0.3))
                            .frame(width: 80, height: 28)
                            .glow(color: .accentGreen, radius: 3)
                        
                        Text(viewModel.leagueTier)
                            .font(DesignSystem.Typography.caption(size: 12))
                            .foregroundColor(.textOnAccent)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .frame(height: 60)
    }
}

struct RoadmapView: View {
    @ObservedObject var viewModel: RoadmapViewModel
    
    let levelSize: CGFloat = 50
    let spacing: CGFloat = 80
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
//                // Background with subtle textures - transparent to inherit parent background
//                Color.clear
//                    .overlay(
//                        ZStack {
//                            // Very subtle diagonal stripes
////                            DiagonalStripePattern(
////                                color: Color.accentGreen.opacity(0.04),
////                                lineWidth: 1,
////                                spacing: 24
////                            )
//                            
//                            // Subtle dotted pattern
//                           
//                            
////                            // Very light mesh gradient
////                            MeshGradientBackground(
////                                color1: .accentGreen,
////                                color2: .accentGreen,
////                                opacity: 0.02
////                            )
//                        }
//                    )
                
                ScrollView(.vertical, showsIndicators: false) {
                    // Main roadmap VStack
                    VStack(alignment: .center, spacing: 0) {
                        // Small spacer for top padding
                        Spacer()
                            .frame(height: DesignSystem.Spacing.md)
                            .id("topSpacer")
                        
                        // Draw levels (reversed: level 1 at bottom, level 15 at top)
                        ForEach(0..<viewModel.totalLevels, id: \.self) { index in
                            // Reverse: level 1 at bottom, level 15 at top
                            let reversedIndex = viewModel.totalLevels - 1 - index
                            let levelNumber = reversedIndex + 1
                            
                            // Observe levelProgress changes by accessing it directly
                            LevelRow(
                                levelNumber: levelNumber,
                                viewModel: viewModel,
                                levelSize: levelSize,
                                spacing: spacing,
                                index: index
                            )
                            .id(index)
                        }
                        .onPreferenceChange(ButtonPositionKey.self) { position in
                            if let position = position {
                                viewModel.buttonPosition = position
                            }
                        }
                        
                        // Bottom anchor to scroll to
                        Color.clear
                            .frame(height: 1)
                            .id("bottomAnchor")
                    }
                    .padding(.leading, 30)
                }
                
                // Overlay bubble on top - for levels 1, 2, and 3 (only one at a time)
                if let selectedLevel = viewModel.selectedLevel, selectedLevel <= 3 {
                    let task = LevelTask.taskForLevel(selectedLevel)
                    let isCompleted = selectedLevel <= 2
                    // Find the index for this level
                    let reversedIndex = viewModel.totalLevels - selectedLevel
                    let index = reversedIndex
                    
                    LevelBubbleOverlay(
                        level: selectedLevel,
                        task: task,
                        touchLocation: viewModel.touchLocation,
                        levelIndex: index,
                        isCompleted: isCompleted,
                        viewModel: viewModel,
                        onDismiss: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.selectedLevel = nil
                                viewModel.touchLocation = nil
                            }
                        }
                    )
                    .padding(.bottom, 15)
                    .zIndex(1000)
                }
            }
            .onAppear {
                // Scroll to bottom (level 1) when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        proxy.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                }
            }
            .onTapGesture {
                // Dismiss bubble when tapping outside
                if viewModel.selectedLevel != nil {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectedLevel = nil
                        viewModel.touchLocation = nil
                    }
                }
            }
        }
    }
}

struct LevelRow: View {
    let levelNumber: Int
    @ObservedObject var viewModel: RoadmapViewModel
    let levelSize: CGFloat
    let spacing: CGFloat
    let index: Int
    
    var body: some View {
        // Determine level state: first 2 completed, third active, rest locked
        let isCompleted = levelNumber <= 2
        let isLocked = levelNumber > 3
        // Initialize progress: levels 1-2 start at 1.0, level 3 starts at 0.3 (30%), others stay at 0.0
        let defaultProgress = isCompleted ? 1.0 : (levelNumber == 3 ? 0.3 : 0.0)
        let progress = viewModel.levelProgress[levelNumber] ?? defaultProgress
        
        HStack {
            if index % 2 == 0 {
                Spacer()
                LevelButton(
                    levelNumber: levelNumber,
                    isCompleted: isCompleted,
                    progress: progress,
                    levelSize: levelSize,
                    viewModel: viewModel,
                    onTap: {
                        // Allow bubble for levels 1, 2, and 3
                        guard levelNumber <= 3 else { return }
                        // Toggle bubble - if already selected, close it; otherwise open it
                        if viewModel.selectedLevel == levelNumber {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.selectedLevel = nil
                                viewModel.touchLocation = nil
                            }
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                viewModel.selectedLevel = levelNumber
                            }
                        }
                    }
                )
                .padding(.trailing, spacing / 2)
            } else {
                LevelButton(
                    levelNumber: levelNumber,
                    isCompleted: isCompleted,
                    progress: progress,
                    levelSize: levelSize,
                    viewModel: viewModel,
                    onTap: {
                        // Allow bubble for levels 1, 2, and 3
                        guard levelNumber <= 3 else { return }
                        // Toggle bubble - if already selected, close it; otherwise open it
                        if viewModel.selectedLevel == levelNumber {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.selectedLevel = nil
                                viewModel.touchLocation = nil
                            }
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                viewModel.selectedLevel = levelNumber
                            }
                        }
                    }
                )
                .padding(.leading, spacing / 2)
                Spacer()
            }
        }
        .frame(height: 120)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            // Track row position for levels 1, 2, and 3 during scroll - updates continuously
            Group {
                if levelNumber <= 3 {
                    GeometryReader { rowGeometry in
                        Color.clear
                            .preference(
                                key: ButtonPositionKey.self,
                                value: levelNumber == viewModel.selectedLevel ? rowGeometry.frame(in: .global).center : nil
                            )
                            .onAppear {
                                // Initial position if this is the selected level
                                if levelNumber == viewModel.selectedLevel {
                                    viewModel.buttonPosition = rowGeometry.frame(in: .global).center
                                }
                            }
                            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
                                // Update position periodically during scroll if this is the selected level
                                if levelNumber == viewModel.selectedLevel {
                                    viewModel.buttonPosition = rowGeometry.frame(in: .global).center
                                }
                            }
                    }
                }
            }
        )
    }
}

struct LevelButton: View {
    let levelNumber: Int
    let isCompleted: Bool
    let progress: Double
    let levelSize: CGFloat
    @ObservedObject var viewModel: RoadmapViewModel
    let onTap: () -> Void
    @State private var showConfetti = false
    @State private var hasShownConfetti = false
    
    var task: LevelTask {
        LevelTask.taskForLevel(levelNumber)
    }
    
    var isLocked: Bool {
        levelNumber > 3
    }
    
    var domainIcon: String {
        switch task.category {
        case .liquidity:
            return "dollarsign.circle.fill"
        case .growth:
            return "chart.line.uptrend.xyaxis"
        case .operations:
            return "basket.fill"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Progress ring for level 3 (active level) - show even if progress is 0
                if !isCompleted && !isLocked {
                    Circle()
                        .stroke(Color.neutralLightGray, lineWidth: 8)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    task.category.color,
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 100, height: 100)
                        )
                }
                
                // Button image - maintains fixed size
                Image(isCompleted ? "doneButton" : "button")
                    .resizable()
                    .frame(width: 80, height: 75)
                    .scaledToFit()
                    .opacity(isLocked ? 0.5 : 1.0)
                    .overlay(
                        // Domain-specific icon overlay on the button (only for level 3)
                        Group {
                            if !isCompleted && !isLocked {
                                // Level 3: show category icon
                                Image(systemName: domainIcon)
                                    .foregroundColor(task.category.color)
                                    .font(.system(size: 24, weight: .semibold))
                                    .shadow(radius: 2)
                            } else if isLocked {
                                // Locked levels: show dark gray lock icon
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.textSecondaryDark)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }
                            .padding(.bottom, 16)
                    )
                
                // Confetti effect when task is completed
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }
            .frame(width: 80, height: 75) // Fixed frame ensures button doesn't shift
            .background(
                GeometryReader { buttonGeometry in
                    Color.clear
                        .preference(
                            key: ButtonPositionKey.self,
                            value: (levelNumber <= 3 && levelNumber == viewModel.selectedLevel) ? buttonGeometry.frame(in: .global).center : nil
                        )
                        .onAppear {
                            if levelNumber <= 3 && levelNumber == viewModel.selectedLevel {
                                viewModel.buttonPosition = buttonGeometry.frame(in: .global).center
                            }
                        }
                        .onChange(of: viewModel.selectedLevel) { newLevel in
                            if levelNumber <= 3 && levelNumber == newLevel {
                                viewModel.buttonPosition = buttonGeometry.frame(in: .global).center
                            }
                        }
                        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
                            if levelNumber <= 3 && levelNumber == viewModel.selectedLevel {
                                viewModel.buttonPosition = buttonGeometry.frame(in: .global).center
                            }
                        }
                }
            )
            .shadow(
                color: isCompleted ? DesignSystem.Shadow.card : Color.clear,
                radius: isCompleted ? DesignSystem.Shadow.cardRadius : 0,
                x: DesignSystem.Shadow.cardOffset.width,
                y: DesignSystem.Shadow.cardOffset.height
            )
            .scaleEffect(isCompleted ? 1.0 : (isLocked ? 0.85 : 0.9))
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onEnded { value in
                        if !isLocked {
                            // Store touch location in global screen coordinates
                            viewModel.touchLocation = value.location
                            onTap() // Always allow tap to show bubble
                        }
                    }
            )
            .onChange(of: isCompleted) { newValue in
                if newValue && !hasShownConfetti {
                    hasShownConfetti = true
                    // Trigger confetti animation
                    withAnimation {
                        showConfetti = true
                    }
                    // Hide confetti after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showConfetti = false
                        }
                    }
                }
            }
            .animation(
                .spring(response: 0.8, dampingFraction: 0.7),
                value: isCompleted
            )
            .animation(
                .easeInOut(duration: 0.3),
                value: progress
            )
        }
    }
    
    // MARK: - Confetti View for Completion Animation
    struct ConfettiView: View {
        @State private var particles: [ConfettiParticle] = []
        
        struct ConfettiParticle: Identifiable {
            let id = UUID()
            var position: CGPoint
            var color: Color
            var rotation: Double
            var opacity: Double = 1.0
        }
        
        var body: some View {
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .position(particle.position)
                        .rotationEffect(.degrees(particle.rotation))
                        .opacity(particle.opacity)
                }
            }
            .frame(width: 200, height: 200)
            .onAppear {
                generateParticles()
                animateParticles()
            }
        }
        
        private func generateParticles() {
            let colors: [Color] = [.accentGreen, .accentGold, .orange, .yellow, .accentRed]
            let center = CGPoint(x: 100, y: 100)
            
            for i in 0..<25 {
                let angle = Double(i) * (2 * .pi / 25)
                let distance = 30.0
                let x = center.x + CGFloat(cos(angle) * distance)
                let y = center.y + CGFloat(sin(angle) * distance)
                
                particles.append(ConfettiParticle(
                    position: center,
                    color: colors.randomElement() ?? .accentGreen,
                    rotation: Double.random(in: 0...360),
                    opacity: 1.0
                ))
            }
        }
        
        private func animateParticles() {
            let colors: [Color] = [.accentGreen, .accentGold, .orange, .yellow, .accentRed]
            let center = CGPoint(x: 100, y: 100)
            
            for i in particles.indices {
                let angle = Double(i) * (2 * .pi / 25)
                let distance = CGFloat.random(in: 80...120)
                let finalX = center.x + CGFloat(cos(angle) * Double(distance))
                let finalY = center.y + CGFloat(sin(angle) * Double(distance))
                
                withAnimation(.easeOut(duration: Double.random(in: 1.0...1.5))) {
                    particles[i].position = CGPoint(x: finalX, y: finalY)
                    particles[i].rotation += Double.random(in: 180...540)
                    particles[i].opacity = 0.0
                }
            }
        }
    }
}

// MARK: - Bounce Button with Animation
struct BounceButton<Content: View>: View {
        let action: () -> Void
        let content: Content
        @State private var isPressed = false
        
        init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
            self.action = action
            self.content = content()
        }
        
        var body: some View {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        isPressed = false
                    }
                    action()
                }
            }) {
                content
                    .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }


// MARK: - Level Bubble Overlay (Square bubble)
struct LevelBubbleOverlay: View {
    let level: Int
    let task: LevelTask
    let touchLocation: CGPoint?
    let levelIndex: Int
    let isCompleted: Bool
    @ObservedObject var viewModel: RoadmapViewModel
    let onDismiss: () -> Void
    @State private var showTaskDetail = false
        
        var body: some View {
            GeometryReader { geometry in
                let visibleScreenHeight = geometry.size.height
                let visibleScreenMiddle = visibleScreenHeight / 2
                // Adjust bubble height if showing completion badge
                let bubbleHeight: CGFloat = isCompleted ? 220 : 200
                let bubbleHalfHeight = bubbleHeight / 2
                
                ZStack {
                    // Transparent background to catch taps outside
                    Color.black.opacity(0.01)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onDismiss()
                        }
                    
                    // Use preference to get this view's frame in global coordinates
                    let viewGlobalFrame = geometry.frame(in: .global)
                    let viewTopInGlobal = viewGlobalFrame.minY
                    
                    // Use button position from view model (tracks button as it scrolls)
                    let buttonPosition = viewModel.buttonPosition ?? touchLocation
                    
                    // Determine bubble direction based on button position relative to visible screen middle
                    let buttonBelowMiddle = buttonPosition.map { buttonPoint in
                        let buttonYInView = buttonPoint.y - viewTopInGlobal
                        return buttonYInView > visibleScreenMiddle
                    } ?? false
                    
                    // Position bubble so its edge (top or bottom) is at button position
                    let bubbleX = geometry.size.width / 2
                    
                    // Calculate bubbleY based on button position in this view's coordinate space
                    let bubbleY: CGFloat = {
                        if let buttonPosition = buttonPosition {
                            // Convert global button position to this view's coordinate space
                            let buttonYInView = buttonPosition.y - viewTopInGlobal
                            
                            return buttonBelowMiddle
                            ? buttonYInView - bubbleHalfHeight  // Bottom edge at button (bubble above, points down)
                            : buttonYInView + bubbleHalfHeight  // Top edge at button (bubble below, points up)
                        } else {
                            // Fallback: position relative to button
                            let rowHeight: CGFloat = 120
                            let topOffset: CGFloat = 20
                            let buttonCenterY = topOffset + CGFloat(levelIndex) * rowHeight + rowHeight / 2
                            return buttonCenterY + (buttonBelowMiddle ? -140 : 80)
                        }
                    }()
                    
                    
                    // Info pop-up bubble (Step 1: Quick Glance)
                    ZStack {
                        // Square bubble with pointer
                        BubbleShape(pointerPosition: buttonBelowMiddle ? .bottom : .top, cornerRadius: 20)
                            .fill(
                                task.category == .liquidity ? Color.accentGreen : task.category.color
                            )
                            .frame(width: 280, height: bubbleHeight)
                            .shadow(
                                color: Color.black.opacity(0.2),
                                radius: 12,
                                x: 0,
                                y: 4
                            )
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            // Title with completion badge if completed
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Text(task.title)
                                    .font(DesignSystem.Typography.heading2(size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(.textOnAccent)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                
                                if isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.textOnAccent)
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            
                            // Completion status for levels 1 and 2
                            if isCompleted {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.textOnAccent)
                                        .font(.system(size: 12, weight: .bold))
                                    Text("Task Completed")
                                        .font(DesignSystem.Typography.caption(size: 12))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.textOnAccent)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.textOnAccent.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            // Reward Value
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.textOnAccent)
                                    .font(.system(size: 14, weight: .bold))
                                    .shadow(color: .white, radius: 1)
                                Text("+\(task.trustScoreImpact) Points")
                                    .font(DesignSystem.Typography.heading2(size: 14))
                                    .fontWeight(.bold)
                                    .foregroundColor(.textOnAccent)
                            }
                            
                            // Short Teaser
                            Text(task.simpleExplanation)
                                .font(DesignSystem.Typography.caption(size: 13))
                                .foregroundColor(.textOnAccent)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            
                            // Primary Button: "Open Task" with bounce animation
                            BounceButton(action: {
                                showTaskDetail = true
                            }) {
                                Text("Open Task")
                                    .font(DesignSystem.Typography.heading2(size: 14))
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimaryDark)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.cardBackgroundDark)
                                    .cornerRadius(DesignSystem.BorderRadius.button)
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(DesignSystem.Spacing.md)
                        .frame(width: 280, height: bubbleHeight)
                    }
                    .position(x: bubbleX-20, y: bubbleY-20)
                }
            }
            .sheet(isPresented: $showTaskDetail) {
                TaskDetailView(task: task, level: level, viewModel: viewModel)
            }
        }
}

// MARK: - Task Detail View
struct TaskDetailView: View {
        let task: LevelTask
        let level: Int
        @ObservedObject var viewModel: RoadmapViewModel
        @Environment(\.dismiss) var dismiss
        @State private var isCompleted: Bool = false
        @State private var showAIQuestion = false
        
        var progress: Double {
            // Get progress from view model, default to 0.3 (30%) for level 3, 1.0 for completed levels
            // Progress ranges from 0.0 (0%) to 1.0 (100%)
            let defaultProgress = level <= 2 ? 1.0 : (level == 3 ? 0.3 : 0.0)
            let currentProgress = viewModel.levelProgress[level] ?? defaultProgress
            // Ensure progress is clamped between 0.0 and 1.0 (0% to 100%)
            return min(max(currentProgress, 0.0), 1.0)
        }
        
        var body: some View {
            NavigationView {
                ZStack {
                    // Colorful animated background
                    ZStack {
                        Color.backgroundScreen
                        
                        // Decorative gradient blobs
                        HStack {
                            OrganicBlob(seed: 0.3)
                                .fill(Color.accentGreen.opacity(0.15))
                                .frame(width: 200, height: 200)
                                .offset(x: -100, y: -200)
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            OrganicBlob(seed: 0.7)
                                .fill(Color.accentGreen.opacity(0.15))
                                .frame(width: 250, height: 250)
                                .offset(x: 100, y: 300)
                        }
                        
                        // Animated mesh gradient overlay
                        AnimatedGradientOverlay(
                            colors: [
                                task.category == .liquidity ? Color.accentGreen : task.category.color,
                                task.category == .growth ? task.category.color : Color.accentGreen
                            ]
                        )
                    }
                    .ignoresSafeArea()
                    
                    if isCompleted {
                        CompletionView(task: task, onDismiss: { dismiss() })
                    } else {
                        ScrollView {
                            VStack(spacing: DesignSystem.Spacing.xl) {
                                // 1. Task Header
                                TaskHeaderSection(task: task, level: level)
                                
                                TaskDescriptionSection(task: task)

                                CreditImpactSection(task: task)
                                
                                // 4. Live Progress Tracker
                                ProgressTrackerSection(
                                    task: task,
                                    progress: progress,
                                    currentValue: task.currentValue,
                                    targetValue: task.targetValue
                                )
                                
                                // 5. AI Strategic Coach Section
                                AICoachSection(
                                    task: task,
                                    onAskAI: { showAIQuestion = true }
                                )
//                                
//                                // 6. Reward & Unlock Preview
//                                RewardPreviewSection(task: task)
//                                
//                                // 7. Bank Transparency Panel
//                                BankTransparencySection(task: task)
//                                
                                // 8. Task Actions
                                TaskActionsSection(
                                    task: task,
                                    onStart: {
                                        // Start task logic
                                    }
                                )
                            }
                            .padding(.bottom, DesignSystem.Spacing.xl)
                        }
                    }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(task.category.color)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.cardBackgroundDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                // Configure navigation bar appearance to prevent color changes during scroll
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.cardBackgroundDark)
                appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.textPrimaryDark)]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.textPrimaryDark)]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
                .sheet(isPresented: $showAIQuestion) {
                    CoachViewWithQuestion(initialQuestion: "How to improve progress on task - \(task.title)?")
                }
            }
        }
    }
    
    // MARK: - 1. Task Header Section
    struct TaskHeaderSection: View {
        let task: LevelTask
        let level: Int
        
        var body: some View {
            ZStack {
                // Decorative background blob
                HStack {
                    Spacer()
                    OrganicBlob(seed: Double(level) * 0.1)
                        .fill(
                            Color.accentGreen.opacity(0.12)
                        )
                        .frame(width: 150, height: 150)
                        .offset(x: 50, y: -30)
                }
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Level badge with glow
                    ZStack {
                        Circle()
                            .fill(
                                Color.accentGreen
                            )
                            .frame(width: 70, height: 70)
                            .glow(
                                color: task.category.color,
                                radius: 15
                            )
                        
                        Text("\(level)")
                            .font(DesignSystem.Typography.hero(size: 32))
                            .foregroundColor(.textOnAccent)
                    }
                    
                    // Title with gradient
                    Text(task.title)
                        .font(DesignSystem.Typography.hero(size: 32))
                        .foregroundStyle(
                            Color.accentGreen
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.container)
                    
                    // Tags Row - Status first, then combined features
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        // Status Tag - shown first
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Circle()
                                .fill(task.status.color)
                                .frame(width: 8, height: 8)
                                .glow(color: task.status.color, radius: 3)
                            Text(task.status.rawValue)
                                .font(DesignSystem.Typography.caption())
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.textPrimaryDark)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    task.status.color.opacity(0.25)
                                )
                        )
                        
                        // Combined features component
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            // Category
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: task.category.icon)
                                    .font(.system(size: 10, weight: .bold))
                                Text(task.category.rawValue)
                                    .font(DesignSystem.Typography.caption(size: 11))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.textPrimaryDark)
                            
                            // Divider
                            Rectangle()
                                .fill(Color.textSecondaryDark.opacity(0.3))
                                .frame(width: 1, height: 12)
                            
                            // Difficulty
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: difficultyIcon(task.difficulty))
                                    .font(.system(size: 10, weight: .bold))
                                Text(task.difficulty.rawValue)
                                    .font(DesignSystem.Typography.caption(size: 11))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.textPrimaryDark)
                            
                            // Divider
                            Rectangle()
                                .fill(Color.textSecondaryDark.opacity(0.3))
                                .frame(width: 1, height: 12)
                            
                            // Time
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10, weight: .bold))
                                Text(task.estimatedTime)
                                    .font(DesignSystem.Typography.caption(size: 11))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.textPrimaryDark)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    Color.neutralLightGray.opacity(0.6)
                                )
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.container)
                }
            }
            .padding(.top, DesignSystem.Spacing.lg)
        }
        
        private func difficultyIcon(_ difficulty: TaskDifficulty) -> String {
            switch difficulty {
            case .easy: return "star.fill"
            case .medium: return "star.fill"
            case .advanced: return "star.fill"
            }
        }
    }
    
    // MARK: - 2. Credit Impact Summary
    struct CreditImpactSection: View {
        let task: LevelTask
        
        var body: some View {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Credit Impact")
                    .font(DesignSystem.Typography.heading1())
                    .foregroundColor(.textPrimaryDark)
                
                ZStack {
                    // Gradient background with pattern overlay
                    Color.cardBackgroundLight
                        .overlay(
                            ZStack {
                                MeshGradientBackground(
                                    color1: task.category == .liquidity ? .accentGreen : task.category.color,
                                    color2: task.category == .growth ? task.category.color : .accentGreen,
                                    opacity: 0.08
                                )
                                
                            }
                        )
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        // Trust Score Impact
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("XP Score Impact")
                                    .font(DesignSystem.Typography.caption())
                                    .foregroundColor(.textSecondaryDark)
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Text("+\(task.trustScoreImpact)")
                                        .font(DesignSystem.Typography.hero(size: 32))
                                        .foregroundColor(task.category.color)
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(task.category.color)
                                }
                            }
                            Spacer()
                        }
                        
                        // Risk Area
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Risk Area Improved")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                            Text(task.riskArea)
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textPrimaryDark)
                        }
                        
                        // Bank Interpretation
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Bank Interpretation")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                            Text(task.bankInterpretation)
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textPrimaryDark)
                                .lineSpacing(4)
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .cornerRadius(DesignSystem.BorderRadius.card)
                .shadow(
                    color: DesignSystem.Shadow.card,
                    radius: DesignSystem.Shadow.cardRadius,
                    x: DesignSystem.Shadow.cardOffset.width,
                    y: DesignSystem.Shadow.cardOffset.height
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.container)
        }
    }
    
    // MARK: - 3. Task Description Section
    struct TaskDescriptionSection: View {
        let task: LevelTask
        
        var body: some View {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("What is this task?")
                    .font(DesignSystem.Typography.heading1())
                    .foregroundColor(.textPrimaryDark)
                
                ZStack {
                    // Gradient background with multiple pattern layers
                    Color.cardBackgroundLight
                        .overlay(
                            ZStack {
                                // Dotted pattern
                                DottedPattern(
                                    color: task.category.color.opacity(0.06),
                                    dotSize: 1.5,
                                    spacing: 10
                                )
                                
                                // Subtle diagonal stripes
                                DiagonalStripePattern(
                                    color: Color.textSecondaryDark.opacity(0.03),
                                    lineWidth: 1,
                                    spacing: 16
                                )
                            }
                        )
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        // Simple Explanation
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Simple Explanation")
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textPrimaryDark)
                            Text(task.simpleExplanation)
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textSecondaryDark)
                                .lineSpacing(4)
                        }
                        
                        Divider()
                            .background(Color.neutralLightGray)
                        
                        // Success Condition
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentGreen)
                                Text("Success Condition")
                                    .font(DesignSystem.Typography.heading2())
                                    .foregroundColor(.textPrimaryDark)
                            }
                            Text(task.successCondition)
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textSecondaryDark)
                                .lineSpacing(4)
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .cornerRadius(DesignSystem.BorderRadius.card)
                .shadow(
                    color: DesignSystem.Shadow.card,
                    radius: DesignSystem.Shadow.cardRadius,
                    x: DesignSystem.Shadow.cardOffset.width,
                    y: DesignSystem.Shadow.cardOffset.height
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.container)
        }
    }
    
    // MARK: - 4. Live Progress Tracker
    struct ProgressTrackerSection: View {
        let task: LevelTask
        let progress: Double
        let currentValue: String
        let targetValue: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Progress Tracker")
                        .font(DesignSystem.Typography.heading1())
                        .foregroundColor(.textPrimaryDark)
                    Spacer()
                    // Animated progress indicator
                    ZStack {
                        Circle()
                            .stroke(Color.neutralLightGray, lineWidth: 3)
                            .frame(width: 32, height: 32)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color.accentGreen,
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 32, height: 32)
                    }
                }
                
                ZStack {
                    // Solid background
                    Color.cardBackgroundLight
                        .overlay(
                            ZStack {
                                DiagonalStripePattern(
                                    color: task.category.color.opacity(0.06),
                                    lineWidth: 1.5,
                                    spacing: 14
                                )
                                
                                // Decorative dots
                                DottedPattern(
                                    color: task.category.color.opacity(0.05),
                                    dotSize: 1.5,
                                    spacing: 15
                                )
                            }
                        )
                    
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Progress Bar with enhanced design
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            HStack {
                                Text("\(Int(progress * 100))% Complete")
                                    .font(DesignSystem.Typography.heading2())
                                    .foregroundColor(.textPrimaryDark)
                                Spacer()
                                // Progress percentage badge
                                //                            Text("\(Int(progress * 100))%")
                                //                                .font(DesignSystem.Typography.caption())
                                //                                .fontWeight(.bold)
                                //                                .foregroundColor(.textOnAccent)
                                //                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                //                                .padding(.vertical, 4)
                                //                                .background(
                                //                                    Capsule()
                                //                                        .fill(
                                //Color.accentGreen
                                //                                        )
                                //                                )
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background with texture
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.neutralLightGray)
                                        .overlay(
                                            DiagonalStripePattern(
                                                color: Color.textSecondaryDark.opacity(0.1),
                                                lineWidth: 1,
                                                spacing: 8
                                            )
                                        )
                                        .frame(height: 16)
                                    
                                    // Progress with gradient and glow
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            Color.accentGreen
                                        )
                                        .frame(width: geometry.size.width * progress, height: 16)
                                        .glow(color: .accentGreen, radius: 4)
                                    
                                    // Progress indicator dot
                                    if progress > 0 {
                                        Circle()
                                            .fill(Color.cardBackgroundLight)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .fill(Color.accentGreen)
                                                    .frame(width: 12, height: 12)
                                            )
                                            .glow(color: .accentGreen, radius: 3)
                                            .offset(x: geometry.size.width * progress - 10)
                                    }
                                }
                            }
                            .frame(height: 16)
                        }
                        
                        Divider()
                            .background(Color.neutralLightGray)
                        
                        // Current vs Target with enhanced design
                        HStack(spacing: DesignSystem.Spacing.md) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.textSecondaryDark)
                                        .font(.system(size: 8))
                                    Text("Current")
                                        .font(DesignSystem.Typography.caption())
                                        .foregroundColor(.textSecondaryDark)
                                }
                                Text(currentValue)
                                    .font(DesignSystem.Typography.hero(size: 28))
                                    .foregroundColor(.textPrimaryDark)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(DesignSystem.Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                    .fill(Color.accentGreen.opacity(0.1))
                            )
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(task.category.color)
                                .font(.system(size: 24))
                                .glow(color: task.category.color, radius: 4)
                            
                            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                                HStack {
                                    Text("Target")
                                        .font(DesignSystem.Typography.caption())
                                        .foregroundColor(.textSecondaryDark)
                                    Image(systemName: "target")
                                        .foregroundColor(.accentGreen)
                                        .font(.system(size: 10))
                                }
                                Text(targetValue)
                                    .font(DesignSystem.Typography.hero(size: 28))
                                    .foregroundColor(.accentGreen)
                                    .shadow(color: Color.accentGreen.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(DesignSystem.Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                    .fill(Color.accentGreen.opacity(0.15))
                            )
                        }
                        
                        Divider()
                            .background(Color.neutralLightGray)
                        
                        // Data Source & Last Sync with icons
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Data Source")
                                    .font(DesignSystem.Typography.caption())
                                    .foregroundColor(.textSecondaryDark)
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentGreen.opacity(0.2))
                                            .frame(width: 28, height: 28)
                                        
                                        Image(systemName: "link.circle.fill")
                                            .foregroundColor(.accentGreen)
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    Text(task.dataSource)
                                        .font(DesignSystem.Typography.body())
                                        .foregroundColor(.textPrimaryDark)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                                Text("Last Updated")
                                    .font(DesignSystem.Typography.caption())
                                    .foregroundColor(.textSecondaryDark)
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.accentGreen)
                                        .font(.system(size: 12))
                                    Text("2 hours ago")
                                        .font(DesignSystem.Typography.body())
                                        .foregroundColor(.textSecondaryDark)
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .cornerRadius(DesignSystem.BorderRadius.card)
                .shadow(
                    color: DesignSystem.Shadow.card,
                    radius: DesignSystem.Shadow.cardRadius,
                    x: DesignSystem.Shadow.cardOffset.width,
                    y: DesignSystem.Shadow.cardOffset.height
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.container)
        }
    }
    
    // MARK: - 5. AI Strategic Coach Section
    struct AICoachSection: View {
        let task: LevelTask
        let onAskAI: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("AI Strategic Coach")
                        .font(DesignSystem.Typography.heading1())
                        .foregroundColor(.textPrimaryDark)
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(
                                Color.accentGreen.opacity(0.3)
                            )
                            .frame(width: 40, height: 40)
                            .glow(color: .accentGreen, radius: 6)
                        
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.accentGreen)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                
                ZStack {
                    // Solid background
                    Color.cardBackgroundLight
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        // AI Insight Card with enhanced design
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentGreen)
                                        .frame(width: 40, height: 40)
                                        .glow(color: .accentGreen, radius: 5)
                                    
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.textOnAccent)
                                }
                                
                                Text("AI Insight")
                                    .font(DesignSystem.Typography.heading2())
                                    .foregroundColor(.textPrimaryDark)
                            }
                            
                            Text(task.aiInsight)
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textPrimaryDark)
                                .lineSpacing(4)
                                .padding(DesignSystem.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                        .fill(Color.accentGreen.opacity(0.1))
                                )
                        }
                        
                        Divider()
                            .background(Color.neutralLightGray)
                        
                        // Actionable Suggestions with colorful checkboxes
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Actionable Steps")
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textPrimaryDark)
                            
                            ForEach(Array(task.actionableSuggestions.enumerated()), id: \.offset) { index, suggestion in
                                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentGreen.opacity(0.2))
                                            .frame(width: 24, height: 24)
                                        
                                        Image(systemName: "circle")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.accentGreen)
                                    }
                                    
                                    Text(suggestion)
                                        .font(DesignSystem.Typography.body())
                                        .foregroundColor(.textPrimaryDark)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Ask AI Button with gradient
                        Button(action: onAskAI) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.textOnAccent.opacity(0.2))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "message.fill")
                                        .foregroundColor(.textOnAccent)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                
                                Text("Ask how to complete this faster")
                                    .font(DesignSystem.Typography.body())
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.textOnAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(Color.accentGreen)
                            )
                            .glow(color: .accentGreen, radius: 6)
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .cornerRadius(DesignSystem.BorderRadius.card)
                .shadow(
                    color: DesignSystem.Shadow.card,
                    radius: DesignSystem.Shadow.cardRadius,
                    x: DesignSystem.Shadow.cardOffset.width,
                    y: DesignSystem.Shadow.cardOffset.height
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.container)
        }
    }
    
    // MARK: - 6. Reward & Unlock Preview
    struct RewardPreviewSection: View {
        let task: LevelTask
        
        var body: some View {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Rewards & Unlocks")
                        .font(DesignSystem.Typography.heading1())
                        .foregroundColor(.textPrimaryDark)
                    Spacer()
                    Image(systemName: "gift.fill")
                        .foregroundColor(.accentGreen)
                        .font(.system(size: 24))
                }
                
                ZStack {
                    // Vibrant animated gradient background
                    AnimatedGradientOverlay(
                        colors: [Color.accentGreen, Color.accentGreen]
                    )
                    .overlay(
                        ZStack {
                            Color.cardBackgroundLight.opacity(0.95)
                            
                            // Decorative elements
                            HStack {
                                OrganicBlob(seed: 0.6)
                                    .fill(Color.accentGreen.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                    .offset(x: -20, y: 20)
                                Spacer()
                            }
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        // Immediate Rewards with enhanced design
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Immediate Rewards")
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textPrimaryDark)
                            
                            HStack(spacing: DesignSystem.Spacing.md) {
                                // Trust Score reward
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentGreen.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                            .glow(color: .accentGreen, radius: 4)
                                        
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.accentGreen)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    
                                    Text("+\(task.trustScoreImpact) XP Score")
                                        .font(DesignSystem.Typography.body())
                                        .fontWeight(.semibold)
                                        .foregroundColor(.textPrimaryDark)
                                }
                                .padding(DesignSystem.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                        .fill(Color.accentGreen.opacity(0.15))
                                )
                                
                                if let badge = task.badgeName {
                                    // Badge reward
                                    HStack(spacing: DesignSystem.Spacing.xs) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    Color.accentGreen.opacity(0.3)
                                                )
                                                .frame(width: 32, height: 32)
                                                .glow(color: .accentGreen, radius: 4)
                                            
                                            Image(systemName: "trophy.fill")
                                                .foregroundColor(.accentGreen)
                                                .font(.system(size: 16, weight: .bold))
                                        }
                                        
                                        Text("Badge: \(badge)")
                                            .font(DesignSystem.Typography.body())
                                            .fontWeight(.semibold)
                                            .foregroundColor(.textPrimaryDark)
                                    }
                                    .padding(DesignSystem.Spacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                            .fill(Color.accentGreen.opacity(0.15))
                                    )
                                }
                            }
                        }
                        
                        if let unlock = task.financingUnlock {
                            Divider()
                                .background(Color.neutralLightGray)
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentGreen.opacity(0.3))
                                            .frame(width: 36, height: 36)
                                            .glow(color: .accentGreen, radius: 5)
                                        
                                        Image(systemName: "lock.open.fill")
                                            .foregroundColor(.accentGreen)
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                    
                                    Text("Financing Unlock")
                                        .font(DesignSystem.Typography.heading2())
                                        .foregroundColor(.textPrimaryDark)
                                }
                                
                                Text(unlock)
                                    .font(DesignSystem.Typography.body())
                                    .foregroundColor(.textPrimaryDark)
                                    .lineSpacing(4)
                                    .padding(DesignSystem.Spacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                            .fill(Color.accentGreen.opacity(0.12))
                                    )
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .cornerRadius(DesignSystem.BorderRadius.card)
                .shadow(
                    color: DesignSystem.Shadow.card,
                    radius: DesignSystem.Shadow.cardRadius,
                    x: DesignSystem.Shadow.cardOffset.width,
                    y: DesignSystem.Shadow.cardOffset.height
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.container)
        }
    }
    
    // MARK: - 7. Bank Transparency Panel
    struct BankTransparencySection: View {
        let task: LevelTask
        
        var body: some View {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Bank Transparency")
                        .font(DesignSystem.Typography.heading1())
                        .foregroundColor(.textPrimaryDark)
                    Spacer()
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.accentGreen)
                        .font(.system(size: 24))
                }
                
                ZStack {
                    // Solid dark background
                    Color.cardBackgroundDark
                        .overlay(
                            ZStack {
                                // Wave pattern
                                VStack {
                                    Spacer()
                                    WaveShape(amplitude: 8, frequency: 0.05)
                                        .fill(Color.accentGreen.opacity(0.2))
                                        .frame(height: 25)
                                }
                                
                                // Decorative blob
                                HStack {
                                    Spacer()
                                    OrganicBlob(seed: 0.9)
                                        .fill(Color.accentGreen.opacity(0.15))
                                        .frame(width: 90, height: 90)
                                        .offset(x: 25, y: -15)
                                }
                                
                                // Diagonal stripes
                                DiagonalStripePattern(
                                    color: Color.accentGreen.opacity(0.08),
                                    lineWidth: 1,
                                    spacing: 18
                                )
                            }
                        )
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        // How Banks Use This with enhanced design
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentGreen.opacity(0.4))
                                        .frame(width: 36, height: 36)
                                        .glow(color: .accentGreen, radius: 6)
                                    
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(.accentGreen)
                                        .font(.system(size: 18, weight: .bold))
                                }
                                
                                Text("How Banks Use This Task")
                                    .font(DesignSystem.Typography.heading2())
                                    .foregroundColor(.textPrimaryDark)
                            }
                            
                            Text(task.bankUsage)
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textPrimaryDark.opacity(0.9))
                                .lineSpacing(4)
                                .padding(DesignSystem.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                        .fill(Color.accentGreen.opacity(0.15))
                                )
                        }
                        
                        Divider()
                            .background(Color.textOnAccent.opacity(0.3))
                        
                        // Verification Status with enhanced icons
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Verification Status")
                                    .font(DesignSystem.Typography.caption())
                                    .foregroundColor(.textPrimaryDark.opacity(0.7))
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentGreen.opacity(0.3))
                                            .frame(width: 28, height: 28)
                                        
                                        Image(systemName: "checkmark.shield.fill")
                                            .foregroundColor(.accentGreen)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .glow(color: .accentGreen, radius: 3)
                                    
                                    Text(task.verificationStatus)
                                        .font(DesignSystem.Typography.body())
                                        .foregroundColor(.textPrimaryDark)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                                Text("Audit Trail")
                                    .font(DesignSystem.Typography.caption())
                                    .foregroundColor(.textPrimaryDark.opacity(0.7))
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentGreen.opacity(0.3))
                                            .frame(width: 28, height: 28)
                                        
                                        Image(systemName: "doc.text.fill")
                                            .foregroundColor(.accentGreen)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .glow(color: .accentGreen, radius: 3)
                                    
                                    Text("Logged & Shareable")
                                        .font(DesignSystem.Typography.body())
                                        .foregroundColor(.textPrimaryDark)
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .cornerRadius(DesignSystem.BorderRadius.card)
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 15,
                    x: 0,
                    y: 6
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.container)
        }
    }
    
    // MARK: - 8. Task Actions Section
    struct TaskActionsSection: View {
        let task: LevelTask
        let onStart: () -> Void
        
        var body: some View {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Primary CTA with enhanced glow
                ZStack {
                    // Glow layer - extends beyond button
                    if task.status != .locked {
                        RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                            .fill(Color.accentGreen)
                            .blur(radius: 15)
                            .opacity(0.7)
                            .padding(-12) // Extend glow beyond button
                    }
                    
                    Button(action: onStart) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(Color.textOnAccent.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: task.status == .active ? "play.circle.fill" : "arrow.right.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.textOnAccent)
                            }
                            
                            Text(task.status == .active ? "Continue Task" : "Start Task")
                                .font(DesignSystem.Typography.heading2())
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.textOnAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(
                            ZStack {
                                Color.accentGreen
                                
                                // Pattern overlay
                                DottedPattern(
                                    color: Color.textOnAccent.opacity(0.15),
                                    dotSize: 1.5,
                                    spacing: 8
                                )
                            }
                        )
                        .cornerRadius(DesignSystem.BorderRadius.button)
                    }
                    .disabled(task.status == .locked)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.container)
        }
    }
    
    // MARK: - 9. Completion State
    struct CompletionView: View {
        let task: LevelTask
        let onDismiss: () -> Void
        
        var body: some View {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Completion Animation
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("🎉")
                            .font(.system(size: 80))
                        
                        Text("Task Completed!")
                            .font(DesignSystem.Typography.hero(size: 36))
                            .foregroundColor(.textPrimaryDark)
                    }
                    .padding(.top, DesignSystem.Spacing.xl)
                    
                    // Impact Summary
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Impact Summary")
                            .font(DesignSystem.Typography.heading1())
                            .foregroundColor(.textPrimaryDark)
                        
                        ZStack {
                            // Solid background
                            Color.cardBackgroundLight
                                .overlay(
                                    ZStack {
                                        // Subtle dotted pattern
                                        DottedPattern(
                                            color: Color.accentGreen.opacity(0.04),
                                            dotSize: 1.5,
                                            spacing: 12
                                        )
                                        
                                        // Decorative corner element
                                        VStack {
                                            HStack {
                                                Spacer()
                                                OrganicBlob(seed: 0.5)
                                                    .fill(Color.accentGreen.opacity(0.08))
                                                    .frame(width: 80, height: 80)
                                                    .offset(x: 20, y: -20)
                                            }
                                            Spacer()
                                        }
                                    }
                                )
                            
                            VStack(spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Text("Trust Score")
                                        .font(DesignSystem.Typography.heading2())
                                        .foregroundColor(.textPrimaryDark)
                                    Spacer()
                                    HStack(spacing: DesignSystem.Spacing.sm) {
                                        Text("72")
                                            .font(DesignSystem.Typography.hero(size: 32))
                                            .foregroundColor(.textSecondaryDark)
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.textSecondaryDark)
                                        Text("\(72 + task.trustScoreImpact)")
                                            .font(DesignSystem.Typography.hero(size: 32))
                                            .foregroundColor(.accentGreen)
                                    }
                                }
                            }
                            .padding(DesignSystem.Spacing.lg)
                        }
                        .cornerRadius(DesignSystem.BorderRadius.card)
                        .shadow(
                            color: DesignSystem.Shadow.card,
                            radius: DesignSystem.Shadow.cardRadius,
                            x: DesignSystem.Shadow.cardOffset.width,
                            y: DesignSystem.Shadow.cardOffset.height
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.container)
                    
                    // Unlocked Offers
                    if let unlock = task.financingUnlock {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Unlocked Offers")
                                .font(DesignSystem.Typography.heading1())
                                .foregroundColor(.textPrimaryDark)
                            
                            ZStack {
                                // Solid background with decorative elements
                                Color.cardBackgroundLight
                                    .overlay(
                                        ZStack {
                                            // Decorative patterns
                                            DottedPattern(
                                                color: Color.accentGreen.opacity(0.05),
                                                dotSize: 1.5,
                                                spacing: 12
                                            )
                                            
                                            // Organic blob decoration
                                            HStack {
                                                Spacer()
                                                OrganicBlob(seed: 0.65)
                                                    .fill(Color.accentGreen.opacity(0.1))
                                                    .frame(width: 100, height: 100)
                                                    .offset(x: 25, y: -15)
                                            }
                                        }
                                    )
                                
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                    Text(unlock)
                                        .font(DesignSystem.Typography.heading2())
                                        .foregroundColor(.textPrimaryDark)
                                    
                                    Button(action: {}) {
                                        Text("View Financing Offer")
                                            .font(DesignSystem.Typography.heading2())
                                            .foregroundColor(.textOnAccent)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, DesignSystem.Spacing.md)
                                            .background(
                                                Color.accentGreen
                                            )
                                            .cornerRadius(DesignSystem.BorderRadius.button)
                                    }
                                }
                                .padding(DesignSystem.Spacing.lg)
                            }
                            .cornerRadius(DesignSystem.BorderRadius.card)
                            .shadow(
                                color: DesignSystem.Shadow.card,
                                radius: DesignSystem.Shadow.cardRadius,
                                x: DesignSystem.Shadow.cardOffset.width,
                                y: DesignSystem.Shadow.cardOffset.height
                            )
                        }
                        .padding(.horizontal, DesignSystem.Spacing.container)
                    }
                    
                    // Suggested Next Task
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Suggested Next Task")
                            .font(DesignSystem.Typography.heading1())
                            .foregroundColor(.textPrimaryDark)
                        
                        ZStack {
                            // Solid background with pattern overlay
                            Color.cardBackgroundLight
                                .overlay(
                                    ZStack {
                                        // Diagonal stripe pattern
                                        DiagonalStripePattern(
                                            color: Color.accentGreen.opacity(0.04),
                                            lineWidth: 1.5,
                                            spacing: 14
                                        )
                                        
                                        // Decorative blob
                                        VStack {
                                            HStack {
                                                OrganicBlob(seed: 0.75)
                                                    .fill(Color.accentGreen.opacity(0.08))
                                                    .frame(width: 90, height: 90)
                                                    .offset(x: -15, y: -15)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                )
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Build Emergency Fund")
                                    .font(DesignSystem.Typography.heading2())
                                    .foregroundColor(.textPrimaryDark)
                                Text("Continue improving your financial resilience")
                                    .font(DesignSystem.Typography.body())
                                    .foregroundColor(.textSecondaryDark)
                            }
                            .padding(DesignSystem.Spacing.lg)
                        }
                        .cornerRadius(DesignSystem.BorderRadius.card)
                        .shadow(
                            color: DesignSystem.Shadow.card,
                            radius: DesignSystem.Shadow.cardRadius,
                            x: DesignSystem.Shadow.cardOffset.width,
                            y: DesignSystem.Shadow.cardOffset.height
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.container)
                    
                    // Close Button
                    Button(action: onDismiss) {
                        Text("Close")
                            .font(DesignSystem.Typography.heading2())
                            .foregroundColor(.textOnAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(
                                Color.accentGreen
                            )
                            .cornerRadius(DesignSystem.BorderRadius.button)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.container)
                }
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
    }
