//
//  ContentView.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//  Redesigned based on design.js specifications
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: RoadmapViewModel
    
    var body: some View {
        ZStack {
            // Background with subtle texture
            Color.backgroundScreen
                .overlay(
                    DottedPattern(
                        color: Color.accentGreen.opacity(0.03),
                        dotSize: 8,
                        spacing: 15
                    )
                )
            
            VStack(spacing: 0) {
                // Stat Header (Duolingo-style top bar)
                StatHeaderView(viewModel: viewModel)
                
                ScrollView {
                    VStack(spacing: 8) {
                        // Roadmap with decorative background
                        ZStack {
                            // Main content
                            VStack(spacing: DesignSystem.Spacing.lg) {
                                RoadmapView(viewModel: viewModel)
                                    .frame(width: 200)
//                                    .padding(DesignSystem.Spacing.lg)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, DesignSystem.Spacing.lg)
                        .padding(.horizontal, DesignSystem.Spacing.container)
                        .padding(.bottom, DesignSystem.Spacing.xl)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
