//
//  MarketplaceView.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//

import SwiftUI

struct MarketplaceView: View {
    @State private var offers: [FinancialOffer] = []
    @State private var selectedOffer: FinancialOffer?
    @State private var showingOfferDetail = false
    @State private var currentLevel: Int = 5
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Card
            headerCard
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Unlocked Offers
                    if !unlockedOffers.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Available Offers")
                                .font(DesignSystem.Typography.heading1())
                                .foregroundColor(.textPrimaryDark)
                                .padding(.horizontal, DesignSystem.Spacing.container)
                                .padding(.top, DesignSystem.Spacing.lg)
                            
                            ForEach(unlockedOffers) { offer in
                                OfferCard(offer: offer, currentLevel: currentLevel) {
                                    selectedOffer = offer
                                    showingOfferDetail = true
                                }
                            }
                        }
                    }
                    
                    // Locked Offers
                    if !lockedOffers.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Coming Soon")
                                .font(DesignSystem.Typography.heading1())
                                .foregroundColor(.textPrimaryDark)
                                .padding(.horizontal, DesignSystem.Spacing.container)
                            
                            ForEach(lockedOffers) { offer in
                                LockedOfferCard(offer: offer, currentLevel: currentLevel)
                            }
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
        }
        .background(Color.backgroundScreen)
        .navigationBarHidden(true)
        .sheet(item: $selectedOffer) { offer in
            OfferDetailView(offer: offer, currentLevel: currentLevel)
        }
        .onAppear {
            loadOffers()
        }
    }
    
    private var headerCard: some View {
        ZStack {
            // Background with texture
            Color.cardBackgroundDark
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Icon with glow (smaller)
                ZStack {
                    Circle()
                        .fill(Color.accentGreen.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .glow(color: .accentGreen, radius: 3)
                    
                    Image(systemName: "storefront.fill")
                        .foregroundColor(.accentGreen)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Marketplace")
                        .font(DesignSystem.Typography.heading2(size: 18))
                        .foregroundColor(.textPrimaryDark)
                    Text("Financial Products")
                        .font(DesignSystem.Typography.caption(size: 11))
                        .foregroundColor(.textPrimaryDark.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .frame(height: 60)
    }
    
    private var unlockedOffers: [FinancialOffer] {
        offers.filter { $0.isUnlocked }
    }
    
    private var lockedOffers: [FinancialOffer] {
        offers.filter { !$0.isUnlocked }
    }
    
    private func loadOffers() {
        offers = [
            FinancialOffer(
                title: "Working Capital Loan",
                description: "Flexible financing for daily operations",
                amount: 50000,
                minAmount: 10000,
                maxAmount: 50000,
                interestRate: 8.5,
                duration: 12,
                minDuration: 6,
                maxDuration: 24,
                requiredLevel: 1,
                isUnlocked: currentLevel >= 1,
                type: .workingCapital
            ),
            FinancialOffer(
                title: "Equipment Financing",
                description: "Finance your business equipment purchases",
                amount: 150000,
                minAmount: 25000,
                maxAmount: 150000,
                interestRate: 6.8,
                duration: 36,
                minDuration: 12,
                maxDuration: 60,
                requiredLevel: 3,
                isUnlocked: currentLevel >= 3,
                type: .equipment
            ),
            FinancialOffer(
                title: "Invoice Factoring",
                description: "Get paid immediately for your invoices",
                amount: 75000,
                minAmount: 15000,
                maxAmount: 75000,
                interestRate: 7.2,
                duration: 6,
                minDuration: 1,
                maxDuration: 12,
                requiredLevel: 5,
                isUnlocked: currentLevel >= 5,
                type: .invoice
            ),
            FinancialOffer(
                title: "Line of Credit",
                description: "Access funds when you need them",
                amount: 100000,
                minAmount: 20000,
                maxAmount: 250000,
                interestRate: 9.0,
                duration: 12,
                minDuration: 6,
                maxDuration: 24,
                requiredLevel: 7,
                isUnlocked: currentLevel >= 7,
                type: .lineOfCredit
            )
        ]
    }
}

struct OfferCard: View {
    let offer: FinancialOffer
    let currentLevel: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background with unique texture per offer type
                Color.cardBackgroundLight
                    .overlay(
                        ZStack {
                            // Different patterns based on offer type
                            switch offer.type {
                            case .workingCapital:
                                DiagonalStripePattern(
                                    color: Color.accentGreen.opacity(0.08),
                                    lineWidth: 1.5,
                                    spacing: 14
                                )
                            case .equipment:
                                DottedPattern(
                                    color: Color.accentGreen.opacity(0.06),
                                    dotSize: 2,
                                    spacing: 10
                                )
                            case .invoice:
                                MeshGradientBackground(
                                    color1: .accentGreen,
                                    color2: .accentGreen,
                                    opacity: 0.06
                                )
                            case .lineOfCredit:
                                DiagonalStripePattern(
                                    color: Color.accentGreen.opacity(0.06),
                                    lineWidth: 1,
                                    spacing: 16
                                )
                            }
                            
                            // Wave at bottom
                            VStack {
                                Spacer()
                                WaveShape(amplitude: 5, frequency: 0.1)
                                    .fill(Color.accentGreen.opacity(0.1))
                                    .frame(height: 20)
                            }
                        }
                    )
                
                // Decorative blob
//                HStack {
//                    Spacer()
//                    OrganicBlob(seed: Double(offer.id.hashValue) / 1000.0)
//                        .fill(Color.accentGreen.opacity(0.08))
//                        .frame(width: 80, height: 80)
//                        .offset(x: 20, y: -20)
//                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        // Icon with glow
                        ZStack {
                            Circle()
                                .fill(Color.accentGreen.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .glow(color: .accentGreen, radius: 5)
                            
                            Image(systemName: offer.type.icon)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.accentGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(offer.title)
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textPrimaryDark)
                            Text(offer.description)
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.accentGreen.opacity(0.15))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.accentGreen)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    
                    Divider()
                        .background(Color.neutralLightGray)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Amount")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                            Text("\(formatCurrency(offer.amount))")
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textPrimaryDark)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                            Text("Interest Rate")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                            HStack(spacing: 4) {
                                Text("\(String(format: "%.1f", offer.interestRate))%")
                                    .font(DesignSystem.Typography.heading2())
                                    .foregroundColor(.accentGreen)
                                Circle()
                                    .fill(Color.accentGreen)
                                    .frame(width: 6, height: 6)
                                    .glow(color: .accentGreen, radius: 2)
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
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, DesignSystem.Spacing.container)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount)) AZN"
    }
}

struct LockedOfferCard: View {
    let offer: FinancialOffer
    let currentLevel: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.neutralLightGray)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: offer.type.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.textSecondaryDark)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(offer.title)
                        .font(DesignSystem.Typography.heading2())
                        .foregroundColor(.textSecondaryDark)
                    Text(offer.description)
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(.textSecondaryDark)
                }
                
                Spacer()
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.textSecondaryDark)
                        .font(.system(size: 16, weight: .semibold))
                    Text("Level \(4)")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(.textSecondaryDark)
                }
            }
            
            HStack {
                Text("Gain 300 more XP points to unlock")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(.textSecondaryDark)
                
                Spacer()
                
                ProgressView(value: Double(currentLevel), total: Double(offer.requiredLevel))
                    .tint(Color.accentGreen)
                    .frame(width: 100)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.card)
                .fill(Color.neutralLightGray)
        )
        .padding(.horizontal, DesignSystem.Spacing.container)
    }
}

struct OfferDetailView: View {
    let offer: FinancialOffer
    let currentLevel: Int
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedAmount: Double
    @State private var selectedDuration: Int
    @State private var showingJustification = false
    @State private var justificationText = ""
    
    init(offer: FinancialOffer, currentLevel: Int) {
        self.offer = offer
        self.currentLevel = currentLevel
        _selectedAmount = State(initialValue: offer.amount)
        _selectedDuration = State(initialValue: offer.duration)
    }
    
    // Calculate EMI using the provided formula
    var monthlyPayment: Double {
        let annualInterestRate = adjustedInterestRate
        let monthlyRate = annualInterestRate / 12 / 100
        let numberOfMonths = Double(selectedDuration)
        let principal = selectedAmount
        
        if monthlyRate == 0 {
            return principal / numberOfMonths
        }
        
        let emi = (principal * monthlyRate * pow(1 + monthlyRate, numberOfMonths)) /
                  (pow(1 + monthlyRate, numberOfMonths) - 1)
        
        return emi
    }
    
    // Calculate total payment and total interest
    var totalPayment: Double {
        let emi = monthlyPayment
        let numberOfMonths = Double(selectedDuration)
        return emi * numberOfMonths
    }
    
    var totalInterest: Double {
        return totalPayment - selectedAmount
    }
    
    var adjustedInterestRate: Double {
        // Interest rate increases if amount/duration is outside standard range
        var rate = offer.interestRate
        if selectedAmount > offer.amount * 1.2 {
            rate += 0.5
        }
        if selectedDuration > offer.duration {
            rate += 0.3
        }
        return rate
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Header Card
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.accentGreen.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: offer.type.icon)
                            .foregroundColor(.accentGreen)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Offer Details")
                            .font(DesignSystem.Typography.heading2())
                            .foregroundColor(.textPrimaryDark)
                        Text(offer.title)
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(.textPrimaryDark.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimaryDark)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .padding(DesignSystem.Spacing.lg)
                .background(Color.cardBackgroundDark)
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Offer Header
                        VStack(spacing: DesignSystem.Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentGreen.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: offer.type.icon)
                                    .font(.system(size: 40, weight: .semibold))
                                    .foregroundColor(.accentGreen)
                            }
                            
                            Text(offer.title)
                                .font(DesignSystem.Typography.heading1(size: 28))
                                .foregroundColor(.textPrimaryDark)
                            
                            Text(offer.description)
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textSecondaryDark)
                                .multilineTextAlignment(.center)
                        }
                        .padding(DesignSystem.Spacing.lg)
                    
                    // Amount Slider
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Loan Amount")
                            .font(DesignSystem.Typography.heading2())
                            .foregroundColor(.textPrimaryDark)
                        
                        Text("\(formatCurrency(selectedAmount))")
                            .font(DesignSystem.Typography.hero(size: 32))
                            .foregroundColor(.textPrimaryDark)
                        
                        Slider(
                            value: $selectedAmount,
                            in: offer.minAmount...offer.maxAmount,
                            step: 1000
                        )
                        .tint(Color.accentGreen)
                        
                        HStack {
                            Text(formatCurrency(offer.minAmount))
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                            Spacer()
                            Text(formatCurrency(offer.maxAmount))
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .cardStyle()
                    
                    // Duration Slider
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Duration")
                            .font(DesignSystem.Typography.heading2())
                            .foregroundColor(.textPrimaryDark)
                        
                        Text("\(selectedDuration) months")
                            .font(DesignSystem.Typography.hero(size: 32))
                            .foregroundColor(.textPrimaryDark)
                        
                        Slider(
                            value: Binding(
                                get: { Double(selectedDuration) },
                                set: { selectedDuration = Int($0) }
                            ),
                            in: Double(offer.minDuration)...Double(offer.maxDuration),
                            step: 1
                        )
                        .tint(Color.accentGreen)
                        
                        HStack {
                            Text("\(offer.minDuration) months")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                            Spacer()
                            Text("\(offer.maxDuration) months")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(.textSecondaryDark)
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .cardStyle()
                    
                    // Terms Summary
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Text("Interest Rate")
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textPrimaryDark)
                            Spacer()
                            Text("\(String(format: "%.2f", adjustedInterestRate))%")
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.accentGreen)
                        }
                        
                        Divider()
                            .background(Color.neutralLightGray)
                        
                        HStack {
                            Text("Monthly Payment")
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textPrimaryDark)
                            Spacer()
                            Text(formatCurrency(monthlyPayment))
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textPrimaryDark)
                        }
                        
                        Divider()
                            .background(Color.neutralLightGray)
                        
                        HStack {
                            Text("Total Amount")
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textPrimaryDark)
                            Spacer()
                            Text(formatCurrency(totalPayment))
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textPrimaryDark)
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.card)
                            .fill(Color.accentGreen.opacity(0.1))
                    )
                    
                    // Action Buttons
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Accept Offer")
                                .font(DesignSystem.Typography.heading2())
                                .foregroundColor(.textOnAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                        .fill(Color.accentGreen)
                                )
                        }
                        
                        Button(action: {
                            showingJustification = true
                        }) {
                            Text("Request Custom Terms")
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.accentGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                        .stroke(Color.accentGreen, lineWidth: 2)
                                )
                        }
                    }
                    }
                    .padding(DesignSystem.Spacing.container)
                }
                .background(Color.backgroundScreen)
            }
            .sheet(isPresented: $showingJustification) {
                JustificationView(offer: offer, justificationText: $justificationText)
            }
        }
        .background(Color.backgroundScreen)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount)) AZN"
    }
}

struct JustificationView: View {
    let offer: FinancialOffer
    @Binding var justificationText: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text("Explain why you need custom terms")
                    .font(DesignSystem.Typography.heading1())
                    .foregroundColor(.textPrimaryDark)
                
                Text("Help us understand your specific needs. Your request will be reviewed by our team.")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(.textSecondaryDark)
                
                TextEditor(text: $justificationText)
                    .frame(minHeight: 200)
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(.textPrimaryDark)
                    .padding(DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                            .fill(Color.neutralLightGray)
                    )
                    .scrollContentBackground(.hidden)
                
                Spacer()
                
                Button(action: {
                    // Submit justification
                    dismiss()
                }) {
                    Text("Submit Request")
                        .font(DesignSystem.Typography.heading2())
                        .foregroundColor(.textOnAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                                .fill(Color.accentGreen)
                        )
                }
                .disabled(justificationText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(DesignSystem.Spacing.container)
            .background(Color.backgroundScreen)
            .navigationTitle("Custom Terms Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.accentGreen)
                }
            }
        }
    }
}

