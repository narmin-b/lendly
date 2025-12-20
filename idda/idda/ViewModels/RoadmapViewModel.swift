//
//  RoadmapViewModel.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//

import SwiftUI
import Combine

class RoadmapViewModel: ObservableObject {
    @Published var completedLevels: Int = 0
    @Published var totalLevels: Int = 15
    @Published var levelProgress: [Int: Double] = [:] // Level number -> progress (0.0 to 1.0)
    @Published var selectedLevel: Int? = nil // Track which level's bubble is open
    @Published var touchLocation: CGPoint? = nil // Track touch location for bubble positioning
    @Published var buttonPosition: CGPoint? = nil // Track button's position for bubble attachment
    
    // Stat Header Data
    @Published var totalPoints: Int = 850 // Trust Score / XP
    @Published var streakDays: Int = 7
    @Published var leagueTier: String = "Silver"
    @Published var hasStreakFreeze: Bool = true
    @Published var marketplaceHasNotification: Bool = false
    
    func incrementProgress(for levelNumber: Int) {
        // Only allow progress on levels that aren't completed yet
        let currentProgress = levelProgress[levelNumber] ?? 0.0
        if currentProgress < 1.0 {
            let newProgress = min(1.0, currentProgress + 0.25)
            // Create a new dictionary instance to trigger @Published
            var updatedProgress = levelProgress
            updatedProgress[levelNumber] = newProgress
            
            // Explicitly trigger update
            objectWillChange.send()
            levelProgress = updatedProgress
            
            // Update completedLevels count if this level just reached 100%
            if newProgress >= 1.0 {
                let reversedIndex = totalLevels - levelNumber
                let newCompletedLevels = totalLevels - reversedIndex
                if newCompletedLevels > completedLevels {
                    completedLevels = newCompletedLevels
                    // Award points when level completes
                    let task = LevelTask.taskForLevel(levelNumber)
                    totalPoints += task.trustScoreImpact
                    // Check if this unlocks marketplace offers
                    if task.financingUnlock != nil {
                        marketplaceHasNotification = true
                    }
                }
            }
        }
    }
    
    func getProgress(for levelNumber: Int) -> Double {
        return levelProgress[levelNumber] ?? 0.0
    }
    
    func completeNextLevel() {
        // Find the next uncompleted level and increment its progress by 25%
        // Levels 1-2 are pre-completed, level 3 is active, levels 4+ are locked
        // Only work on level 3 (the active level)
        let targetLevel = 3
        let currentProgress = levelProgress[targetLevel] ?? 0.0
        if currentProgress < 1.0 {
            incrementProgress(for: targetLevel)
        }
    }
    
    func allLevelsCompleted() -> Bool {
        // Check if level 3 (the active level) is completed
        // Levels 1-2 are pre-completed, levels 4+ are locked
        let level3Progress = levelProgress[3] ?? 0.0
        return level3Progress >= 1.0
    }
    
    func reset() {
        completedLevels = 0
        levelProgress = [:]
    }
}

