//
//  MainTabView.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//

import SwiftUI
import UIKit

struct TabBarIcon: View {
    let imageName: String
    
    var body: some View {
        Image(uiImage: resizedImage(named: imageName, targetSize: CGSize(width: 24, height: 24)))
            .renderingMode(.original)
    }
    
    private func resizedImage(named: String, targetSize: CGSize) -> UIImage {
        guard let originalImage = UIImage(named: named)?.withRenderingMode(.alwaysOriginal) else {
            return UIImage()
        }
        
        // Calculate the aspect ratio
        let widthRatio = targetSize.width / originalImage.size.width
        let heightRatio = targetSize.height / originalImage.size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Calculate the new size maintaining aspect ratio
        let scaledSize = CGSize(
            width: originalImage.size.width * scaleFactor,
            height: originalImage.size.height * scaleFactor
        )
        
        // Create a renderer with the target size
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { context in
            // Draw the image centered in the target size
            let rect = CGRect(
                x: (targetSize.width - scaledSize.width) / 2,
                y: (targetSize.height - scaledSize.height) / 2,
                width: scaledSize.width,
                height: scaledSize.height
            )
            originalImage.draw(in: rect)
        }
        
        // Preserve original rendering mode
        return resized.withRenderingMode(.alwaysOriginal)
    }
}

struct MainTabView: View {
    @StateObject private var roadmapViewModel = RoadmapViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundScreen.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                NavigationView {
                    ContentView(viewModel: roadmapViewModel)
                        .background(Color.backgroundScreen)
                }
                .tabItem {
                    TabBarIcon(imageName: "route")
                    Text("Learning Path")
                }
                .tag(0)
                
                NavigationView {
                    DashboardView()
                        .background(Color.backgroundScreen)
                }
                .tabItem {
                    TabBarIcon(imageName: "dashboard")
                    Text("Dashboard")
                }
                .tag(1)
                
                NavigationView {
                    MarketplaceView()
                        .background(Color.backgroundScreen)
                }
                .tabItem {
                    TabBarIcon(imageName: "marketplace")
                    Text("Offers")
                }
                .tag(2)
                
                NavigationView {
                    CoachView()
                        .background(Color.backgroundScreen)
                }
                .tabItem {
                    TabBarIcon(imageName: "brain")
                    Text("AI Coach")
                }
                .tag(3)
            }
            .accentColor(.accentGreen)
            .overlay(
                // Marketplace notification dot overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if roadmapViewModel.marketplaceHasNotification {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .padding(.trailing, UIScreen.main.bounds.width / 4 - 20)
                                .padding(.bottom, 5)
                        }
                    }
                }
                .allowsHitTesting(false)
            )
            .onAppear {
                // Configure tab bar appearance to prevent icon tinting
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                
                // Set dark background color
                appearance.backgroundColor = UIColor(Color.cardBackgroundLight)
                
                // Set icon colors to nil/clear to prevent tinting - images keep original colors
                appearance.stackedLayoutAppearance.normal.iconColor = nil
                appearance.stackedLayoutAppearance.selected.iconColor = nil
                
                // Only color the text labels
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor(Color.secondaryAccentGray)
                ]
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(Color.accentGreen)
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
                
                // Prevent icon tinting globally
                UITabBar.appearance().tintColor = nil
                UITabBar.appearance().unselectedItemTintColor = nil
            }
        }
    }
}

