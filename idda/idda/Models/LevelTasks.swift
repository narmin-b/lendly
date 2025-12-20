//
//  LevelTasks.swift
//  idda
//
//  Created for level task definitions
//

import SwiftUI

enum TaskDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .easy: return .accentGreen
        case .medium: return .secondaryAccentGray
        case .advanced: return .orange
        }
    }
}

enum TaskStatus: String {
    case locked = "Locked"
    case active = "Active"
    case completed = "Completed"
    case expired = "Expired"
    
    var color: Color {
        switch self {
        case .locked: return .textSecondaryDark
        case .active: return .accentGreen
        case .completed: return .accentGold
        case .expired: return .accentRed
        }
    }
}

struct LevelTask {
    let level: Int
    let title: String
    let description: String
    let category: BusinessCategory
    let difficulty: TaskDifficulty
    let estimatedTime: String
    let status: TaskStatus
    let trustScoreImpact: Int
    let riskArea: String
    let bankInterpretation: String
    let simpleExplanation: String
    let successCondition: String
    let currentValue: String
    let targetValue: String
    let dataSource: String
    let aiInsight: String
    let actionableSuggestions: [String]
    let badgeName: String?
    let financingUnlock: String?
    let bankUsage: String
    let verificationStatus: String
}
//216007
extension LevelTask {
    static func taskForLevel(_ level: Int) -> LevelTask {
        let tasks: [LevelTask] = [
            LevelTask(
                level: 1,
                title: "Increase Monthly Revenue by 5%",
                description: "Boost your monthly revenue through improved sales and customer retention",
                category: .growth,
                difficulty: .easy,
                estimatedTime: "~30 days",
                status: .active,
                trustScoreImpact: 100,
                riskArea: "Revenue Growth",
                bankInterpretation: "Increasing revenue demonstrates business growth potential and improves your ability to service debt.",
                simpleExplanation: "Growing revenue shows banks that your business is expanding and can handle larger financial commitments.",
                successCondition: "Increase monthly revenue from current baseline by 5% or more.",
                currentValue: "105%",
                targetValue: "105%",
                dataSource: "Banking API",
                aiInsight: "Focus on your top 3 revenue streams. Small improvements there will have the biggest impact.",
                actionableSuggestions: [
                    "Identify your best-selling products or services",
                    "Reach out to top 5 customers for repeat business",
                    "Offer limited-time promotions to boost sales",
                    "Track daily revenue to spot trends"
                ],
                badgeName: "Revenue Grower",
                financingUnlock: nil,
                bankUsage: "Banks use revenue trends to assess your business's growth trajectory and repayment capacity.",
                verificationStatus: "Data verified via banking API"
            ),
            LevelTask(
                level: 2,
                title: "Reduce Debt-to-Income Ratio by 0.5%",
                description: "Improve your financial health by lowering your debt-to-income ratio",
                category: .liquidity,
                difficulty: .medium,
                estimatedTime: "~30 days",
                status: .active,
                trustScoreImpact: 100,
                riskArea: "Debt Management",
                bankInterpretation: "A lower debt-to-income ratio indicates better financial stability and reduces default risk.",
                simpleExplanation: "Lowering your debt-to-income ratio shows banks you're managing debt responsibly and have room for new credit.",
                successCondition: "Reduce debt-to-income ratio by 0.5 percentage points (e.g., from 35% to 34.5%).",
                currentValue: "34.5%",
                targetValue: "34.5%",
                dataSource: "Banking API",
                aiInsight: "Pay down high-interest debt first. Even small payments can make a difference when combined with revenue growth.",
                actionableSuggestions: [
                    "Review all outstanding debts and interest rates",
                    "Make extra payments on highest interest loans",
                    "Avoid taking on new debt this month",
                    "Consider consolidating high-interest debts"
                ],
                badgeName: "Debt Manager",
                financingUnlock: nil,
                bankUsage: "Banks monitor this ratio closely as it directly impacts your creditworthiness and loan eligibility.",
                verificationStatus: "Data verified via banking API"
            ),
            LevelTask(
                level: 3,
                title: "Decrease Inventory Turnover Days by 1 Day",
                description: "Improve inventory efficiency by reducing the number of days inventory sits before being sold",
                category: .operations,
                difficulty: .medium,
                estimatedTime: "~30 days",
                status: .active,
                trustScoreImpact: 150,
                riskArea: "Inventory Efficiency",
                bankInterpretation: "Faster inventory turnover indicates better cash flow management and operational efficiency.",
                simpleExplanation: "Selling inventory faster means cash comes in quicker, which improves your liquidity and shows efficient operations.",
                successCondition: "Reduce inventory turnover days by 1 day (e.g., from 4.5 days to 3.5 days) within one month.",
                currentValue: "4.5 days",
                targetValue: "3.5 days",
                dataSource: "Banking API",
                aiInsight: "Focus on your slowest-moving items. Consider promotions or bundle deals to move them faster.",
                actionableSuggestions: [
                    "Identify slow-moving inventory items",
                    "Run promotions on older stock",
                    "Optimize reorder points to reduce excess inventory",
                    "Improve demand forecasting"
                ],
                badgeName: "Inventory Optimizer",
                financingUnlock: nil,
                bankUsage: "Banks view inventory turnover as a key indicator of operational efficiency and cash flow health.",
                verificationStatus: "Data verified via banking API"
            ),
            LevelTask(
                level: 6,
                title: "Reduce Overdue Invoices by 5%",
                description: "Improve cash flow by reducing overdue invoices",
                category: .liquidity,
                difficulty: .medium,
                estimatedTime: "~7 days",
                status: .active,
                trustScoreImpact: 12,
                riskArea: "Cash Flow Stability",
                bankInterpretation: "Completing this task reduces short-term liquidity risk and improves your repayment reliability.",
                simpleExplanation: "Too many overdue invoices signal unstable cash flow. Reducing them makes your business more predictable and lowers lending risk.",
                successCondition: "Reduce overdue invoices from 18% → 13% or lower.",
                currentValue: "18%",
                targetValue: "13%",
                dataSource: "Banking API",
                aiInsight: "Most of your overdue invoices come from 2 clients. Consider offering early-payment discounts or tightening payment terms.",
                actionableSuggestions: [
                    "Send reminders to top 3 late payers",
                    "Enable automatic invoicing",
                    "Adjust payment terms for Client X",
                    "Offer early payment discounts"
                ],
                badgeName: "Liquidity Improver",
                financingUnlock: "Unlock up to $25,000 working capital at 1.8% lower APR",
                bankUsage: "Banks monitor this metric to assess short-term repayment ability.",
                verificationStatus: "Data verified via banking API"
            ),
            LevelTask(
                level: 8,
                title: "Build Emergency Fund",
                description: "Save 3 months of operating expenses",
                category: .liquidity,
                difficulty: .advanced,
                estimatedTime: "~30 days",
                status: .active,
                trustScoreImpact: 20,
                riskArea: "Financial Resilience",
                bankInterpretation: "Emergency funds demonstrate financial discipline and reduce default risk during unexpected events.",
                simpleExplanation: "An emergency fund protects your business from unexpected expenses. Banks see this as a sign of financial maturity and lower risk.",
                successCondition: "Accumulate savings equal to 3 months of average monthly expenses.",
                currentValue: "1.2 months",
                targetValue: "3.0 months",
                dataSource: "Banking API",
                aiInsight: "Start by saving 10% of monthly revenue. Automate transfers to make it effortless.",
                actionableSuggestions: [
                    "Set up automatic savings transfer",
                    "Reduce one non-essential expense",
                    "Allocate 10% of monthly revenue",
                    "Track progress weekly"
                ],
                badgeName: "Financial Guardian",
                financingUnlock: "Unlock premium credit line with 2.5% lower interest rate",
                bankUsage: "Banks view emergency funds as a buffer against financial shocks.",
                verificationStatus: "Data verified via banking API"
            )
        ]
        
        // Return specific task or create a default one
        if let task = tasks.first(where: { $0.level == level }) {
            return task
        }
        
        // Default task for other levels
        return LevelTask(
            level: level,
            title: "Complete Level \(level) Task",
            description: "Work on improving your business metrics",
            category: level % 3 == 0 ? .liquidity : (level % 3 == 1 ? .growth : .operations),
            difficulty: level <= 5 ? .easy : (level <= 10 ? .medium : .advanced),
            estimatedTime: "~\(level * 2) days",
            status: .active,
            trustScoreImpact: 150,
            riskArea: "Business Health",
            bankInterpretation: "Completing this task improves your overall business health and creditworthiness.",
            simpleExplanation: "This task helps improve your business operations and financial stability.",
            successCondition: "Complete all required steps for this level.",
            currentValue: "0%",
            targetValue: "100%",
            dataSource: "Manual Entry",
            aiInsight: "Focus on one step at a time. Consistency is key to success.",
            actionableSuggestions: [
                "Review your current metrics",
                "Set clear goals",
                "Track your progress",
                "Ask for help when needed"
            ],
            badgeName: nil,
            financingUnlock: nil,
            bankUsage: "Banks use this data to assess your business performance.",
            verificationStatus: "Pending verification"
        )
    }
}


