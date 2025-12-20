//
//  BusinessModels.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//

import SwiftUI

// MARK: - Trust Score & Business Health
struct TrustScore: Identifiable {
    let id = UUID()
    var score: Double // 0-100
    var velocity: Double // Change rate
    var lastUpdated: Date
    var category: BusinessCategory
}

enum BusinessCategory: String, CaseIterable {
    case liquidity = "Leverage"
    case growth = "Growth"
    case operations = "Operations"
    
    var icon: String {
        switch self {
        case .liquidity: return "dollarsign.circle.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        case .operations: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .liquidity: return .accentGreen
        case .growth: return .accentGreen
        case .operations: return .accentGreen
        }
    }
}

// MARK: - KPI Data
struct KPI: Identifiable {
    let id = UUID()
    var name: String
    var value: Double
    var unit: String
    var trend: Trend
    var category: BusinessCategory
}

enum Trend {
    case up, down, stable
    
    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .accentGreen
        case .down: return .red
        case .stable: return .textSecondaryDark
        }
    }
}

// MARK: - Financial Offer
struct FinancialOffer: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var amount: Double
    var minAmount: Double
    var maxAmount: Double
    var interestRate: Double
    var duration: Int // months
    var minDuration: Int
    var maxDuration: Int
    var requiredLevel: Int
    var isUnlocked: Bool
    var type: OfferType
}

enum OfferType: String {
    case workingCapital = "Working Capital"
    case equipment = "Equipment Financing"
    case invoice = "Invoice Factoring"
    case lineOfCredit = "Line of Credit"
    
    var icon: String {
        switch self {
        case .workingCapital: return "briefcase.fill"
        case .equipment: return "wrench.and.screwdriver.fill"
        case .invoice: return "doc.text.fill"
        case .lineOfCredit: return "creditcard.fill"
        }
    }
}

// MARK: - Quest/Task
struct Quest: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var category: BusinessCategory
    var isCompleted: Bool
    var progress: Double
    var reward: QuestReward
    var level: Int
}

struct QuestReward {
    var trustScoreIncrease: Double
    var unlocksOffer: FinancialOffer?
}

// MARK: - Streak Data
struct StreakData {
    var currentStreak: Int
    var longestStreak: Int
    var lastCheckIn: Date?
    var freezeAvailable: Bool
}

