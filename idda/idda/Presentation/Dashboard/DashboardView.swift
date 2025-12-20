//
//  DashboardView.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @State private var trustScore: Double = 72.5
    @State private var scoreVelocity: Double = 5.2
    @State private var selectedCategory: BusinessCategory = .liquidity
    @State private var kpis: [KPI] = []
    @State private var revenueData: [ChartDataPoint] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Card
            headerCard
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Trust Score Card
                    TrustScoreCard(score: trustScore, velocity: scoreVelocity)
                        .padding(.horizontal, DesignSystem.Spacing.container)
                        .padding(.top, DesignSystem.Spacing.lg)
                    
                    // Category Selector
                    CategorySelector(selectedCategory: $selectedCategory)
                        .padding(.horizontal, DesignSystem.Spacing.container)
                    
                    // KPI Grid
                    KPIGrid(kpis: filteredKPIs)
                        .padding(.horizontal, DesignSystem.Spacing.container)
                    
                    // Revenue Trend Chart
                    RevenueChartView(data: revenueData)
                        .padding(.horizontal, DesignSystem.Spacing.container)
                    
                    // Score Velocity Indicator
                    ScoreVelocityCard(velocity: scoreVelocity)
                        .padding(.horizontal, DesignSystem.Spacing.container)
                }
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .background(Color.backgroundScreen)
        .navigationBarHidden(true)
        .onAppear {
            loadDashboardData()
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
                        .fill(
                            Color.accentGreen.opacity(0.3)
                        )
                        .frame(width: 32, height: 32)
                        .glow(color: .accentGreen, radius: 3)
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(.accentGreen)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Morning, User")
                        .font(DesignSystem.Typography.heading2(size: 18))
                        .foregroundColor(.textPrimaryDark)
                    Text("Free Account")
                        .font(DesignSystem.Typography.caption(size: 11))
                        .foregroundColor(.textPrimaryDark.opacity(0.8))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.accentGreen.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "bell.fill")
                        .foregroundColor(.textOnAccent)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .frame(height: 60)
    }
    
    private var filteredKPIs: [KPI] {
        kpis.filter { $0.category == selectedCategory }
    }
    
    private func loadDashboardData() {
        // Mock data - in real app, this would come from data service
        kpis = [
            KPI(name: "Revenue", value: 125000, unit: "AZN", trend: .up, category: .growth),
            KPI(name: "Debt-to-Income", value: 0.35, unit: "ratio", trend: .down, category: .liquidity),
            KPI(name: "Cash Flow", value: 45000, unit: "AZN", trend: .up, category: .liquidity),
            KPI(name: "Customer Retention", value: 0.78, unit: "%", trend: .stable, category: .operations),
            KPI(name: "Profit Margin", value: 0.22, unit: "%", trend: .up, category: .growth),
            KPI(name: "Inventory Turnover", value: 4.5, unit: "days", trend: .up, category: .operations)
        ]
        
        revenueData = [
            ChartDataPoint(month: "Jan", value: 95000),
            ChartDataPoint(month: "Feb", value: 105000),
            ChartDataPoint(month: "Mar", value: 110000),
            ChartDataPoint(month: "Apr", value: 120000),
            ChartDataPoint(month: "May", value: 125000)
        ]
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
}

struct TrustScoreCard: View {
    let score: Double
    let velocity: Double
    
    var body: some View {
        ZStack {
            // Background with texture
            Color.cardBackgroundLight
                .overlay(
                    ZStack {
                        // Diagonal stripes in background
                        DiagonalStripePattern(
                            color: Color.accentGreen.opacity(0.08),
                            lineWidth: 1.5,
                            spacing: 16
                        )
                        .opacity(0.5)
                        
                        // Mesh gradient overlay
                        MeshGradientBackground(
                            color1: .accentGreen,
                            color2: .accentGreen,
                            opacity: 0.05
                        )
                    }
                )
            
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Trust Score")
                        .font(DesignSystem.Typography.heading2())
                        .foregroundColor(.textSecondaryDark)
                    Spacer()
                    // Decorative dot
                    Circle()
                        .fill(Color.accentGreen)
                        .frame(width: 8, height: 8)
                        .glow(color: .accentGreen, radius: 3)
                }
                
                ZStack {
                    // Background circle with texture
                    ZStack {
                        Circle()
                            .stroke(Color.neutralLightGray, lineWidth: 12)
                            .frame(width: 150, height: 150)
                        
                        // Diagonal stripes on inactive portion
                        Circle()
                            .trim(from: score / 100, to: 1.0)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Color.clear,
                                        Color.neutralLightGray.opacity(0.3)
                                    ]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 150, height: 150)
                            .overlay(
                                DiagonalStripePattern(
                                    color: Color.textSecondaryDark.opacity(0.1),
                                    lineWidth: 1,
                                    spacing: 8
                                )
                                .clipShape(
                                    Circle()
                                        .trim(from: score / 100, to: 1.0)
                                        .path(in: CGRect(x: -75, y: -75, width: 150, height: 150))
                                )
                            )
                    }
                    
                    // Progress circle with gradient
                    Circle()
                        .trim(from: 0, to: score / 100)
                        .stroke(
                            Color.accentGreen,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 150, height: 150)
                        .glow(color: .accentGreen, radius: 5)
                    
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Text("\(Int(score))")
                            .font(DesignSystem.Typography.hero(size: 48))
                            .foregroundColor(.textPrimaryDark)
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .bold))
                            Text("+\(String(format: "%.1f", velocity))")
                                .font(DesignSystem.Typography.caption())
                        }
                        .foregroundColor(.accentGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.accentGreen.opacity(0.15))
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
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
}

struct CategorySelector: View {
    @Binding var selectedCategory: BusinessCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BusinessCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryButton: View {
    let category: BusinessCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(category.rawValue)
                    .font(DesignSystem.Typography.caption())
            }
            .foregroundColor(isSelected ? .textOnAccent : .textPrimaryDark)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                            .fill(Color.accentGreen)
                    } else {
                        RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button)
                            .fill(Color.neutralLightGray)
                    }
                }
            )
        }
    }
}

struct KPIGrid: View {
    let kpis: [KPI]
    
    let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
            ForEach(kpis) { kpi in
                KPICard(kpi: kpi)
            }
        }
    }
}

struct KPICard: View {
    let kpi: KPI
    
    var body: some View {
        ZStack {
            // Background with unique texture per card
            Color.cardBackgroundLight
                .overlay(
                    Group {
                        if kpi.trend == .up {
                            MeshGradientBackground(
                                color1: .accentGreen,
                                color2: .accentGreen,
                                opacity: 0.08
                            )
                        } else if kpi.trend == .down {
                            DiagonalStripePattern(
                                color: Color.red.opacity(0.05),
                                lineWidth: 1,
                                spacing: 12
                            )
                        } else {
                            DottedPattern(
                                color: Color.textSecondaryDark.opacity(0.05),
                                dotSize: 1.5,
                                spacing: 8
                            )
                        }
                    }
                )
            
//            // Decorative corner element
//            VStack {
//                HStack {
//                    Spacer()
//                    if kpi.trend == .up {
//                        OrganicBlob(seed: Double(kpi.id.hashValue) / 1000.0)
//                            .fill(Color.accentGreen.opacity(0.1))
//                            .frame(width: 50, height: 50)
//                            .offset(x: 15, y: -15)
//                    }
//                }
//                Spacer()
//            }
//            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    // Icon with glow
                    ZStack {
                        Circle()
                            .fill(
                                (kpi.trend == .up ? Color.accentGreen :
                                 kpi.trend == .down ? Color.red :
                                 Color.neutralLightGray).opacity(0.25)
                            )
                            .frame(width: 40, height: 40)
                            .glow(
                                color: kpi.trend == .up ? .accentGreen :
                                       kpi.trend == .down ? .red : .clear,
                                radius: 4
                            )
                        
                        Image(systemName: kpi.category.icon)
                            .foregroundColor(
                                kpi.trend == .up ? .accentGreen :
                                kpi.trend == .down ? .red :
                                .textSecondaryDark
                            )
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    // Trend indicator with unique design
                    HStack(spacing: 4) {
                        if kpi.trend == .up {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .bold))
                        } else if kpi.trend == .down {
                            Image(systemName: "arrow.down.right")
                                .font(.system(size: 10, weight: .bold))
                        } else {
                            Image(systemName: "minus")
                                .font(.system(size: 10, weight: .bold))
                        }
                    }
                    .foregroundColor(
                        kpi.trend == .up ? .accentGreen :
                        kpi.trend == .down ? .red :
                        .textSecondaryDark
                    )
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(
                                (kpi.trend == .up ? Color.accentGreen :
                                 kpi.trend == .down ? Color.red :
                                 Color.neutralLightGray).opacity(0.15)
                            )
                    )
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack(spacing: 4) {
                        Text(formatValue(kpi.value))
                            .font(DesignSystem.Typography.heading1(size: 20))
                            .foregroundColor(.textPrimaryDark)
                        Text(kpi.unit)
                            .font(DesignSystem.Typography.heading1(size: 20))
                            .foregroundColor(.textPrimaryDark)
                    }
                    Text(kpi.name)
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(.textSecondaryDark)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cornerRadius(DesignSystem.BorderRadius.card)
        .shadow(
            color: DesignSystem.Shadow.card,
            radius: DesignSystem.Shadow.cardRadius,
            x: DesignSystem.Shadow.cardOffset.width,
            y: DesignSystem.Shadow.cardOffset.height
        )
    }
    
    private func formatValue(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        } else if value < 1 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

struct RevenueChartView: View {
    let data: [ChartDataPoint]
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value)) AZN"
    }
    
    var body: some View {
        ZStack {
            // Background with texture
            Color.cardBackgroundLight
                .overlay(
                    ZStack {
                        // Diagonal stripes in background
                        DiagonalStripePattern(
                            color: Color.accentGreen.opacity(0.06),
                            lineWidth: 1,
                            spacing: 20
                        )
                        
                        // Mesh gradient
                        MeshGradientBackground(
                            color1: .accentGreen,
                            color2: .accentGreen,
                            opacity: 0.04
                        )
                    }
                )
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Revenue Trend")
                        .font(DesignSystem.Typography.heading1())
                        .foregroundColor(.textPrimaryDark)
                    Spacer()
                    // Decorative accent dots
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.accentGreen)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.accentGreen)
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
                
                if #available(iOS 16.0, *) {
                    Chart(data) { point in
                        LineMark(
                            x: .value("Month", point.month),
                            y: .value("Revenue", point.value)
                        )
                        .foregroundStyle(
                            Color.accentGreen
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        
                        AreaMark(
                            x: .value("Month", point.month),
                            y: .value("Revenue", point.value)
                        )
                        .foregroundStyle(
                            Color.accentGreen.opacity(0.3)
                        )
                        .interpolationMethod(.catmullRom)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.textSecondaryDark.opacity(0.2))
                            AxisValueLabel()
                                .foregroundStyle(Color.textSecondaryDark)
                                .font(DesignSystem.Typography.caption())
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic) { value in
                            AxisGridLine()
                                .foregroundStyle(Color.textSecondaryDark.opacity(0.2))
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    Text(formatCurrency(doubleValue))
                                        .foregroundStyle(Color.textSecondaryDark)
                                        .font(DesignSystem.Typography.caption())
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(DesignSystem.Spacing.lg)
                } else {
                    // Fallback for iOS 15
                    SimpleLineChart(data: data)
                        .frame(height: 200)
                        .padding(DesignSystem.Spacing.lg)
                }
            }
        }
        .cornerRadius(DesignSystem.BorderRadius.card)
        .shadow(
            color: DesignSystem.Shadow.card,
            radius: DesignSystem.Shadow.cardRadius,
            x: DesignSystem.Shadow.cardOffset.width,
            y: DesignSystem.Shadow.cardOffset.height
        )
    }
}

struct SimpleLineChart: View {
    let data: [ChartDataPoint]
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value)) AZN"
    }
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.map { $0.value }.max() ?? 1
            let width = geometry.size.width
            let height = geometry.size.height - 40 // Reserve space for axis labels
            let chartHeight = height - 20
            let stepX = width / CGFloat(max(data.count - 1, 1))
            
            // Calculate Y-axis tick values
            let yTicks = 5
            let yStep = maxValue / Double(yTicks - 1)
            
            VStack(spacing: 0) {
                ZStack {
                    // Background with diagonal stripes
                    DiagonalStripePattern(
                        color: Color.accentGreen.opacity(0.05),
                        lineWidth: 1,
                        spacing: 12
                    )
                    
                    // Y-axis grid lines
                    ForEach(0..<yTicks, id: \.self) { tick in
                        let yValue = Double(tick) * yStep
                        let y = chartHeight - (CGFloat(yValue / maxValue) * chartHeight)
                        
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                        .stroke(Color.textSecondaryDark.opacity(0.2), lineWidth: 0.5)
                    }
                    
                    // Y-axis labels
                    ForEach(0..<yTicks, id: \.self) { tick in
                        let yValue = Double(tick) * yStep
                        let y = chartHeight - (CGFloat(yValue / maxValue) * chartHeight)
                        
                        Text(formatCurrency(yValue))
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(.textSecondaryDark)
                            .position(x: 30, y: y)
                    }
                    
                    // Area
                    Path { path in
                        for (index, point) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = chartHeight - (CGFloat(point.value / maxValue) * chartHeight)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: chartHeight))
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        path.addLine(to: CGPoint(x: width, y: chartHeight))
                        path.closeSubpath()
                    }
                    .fill(Color.accentGreen.opacity(0.3))
                    
                    // Line
                    Path { path in
                        for (index, point) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = chartHeight - (CGFloat(point.value / maxValue) * chartHeight)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        Color.accentGreen,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    
                    // Points (accent markers)
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                        let x = CGFloat(index) * stepX
                        let y = chartHeight - (CGFloat(point.value / maxValue) * chartHeight)
                        
                        Circle()
                            .fill(index % 2 == 0 ? Color.accentGreen : Color.accentGreen)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
                .frame(height: chartHeight)
                
                // X-axis labels (months)
                HStack(spacing: 0) {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                        Text(point.month)
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(.textSecondaryDark)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
                .frame(height: 20)
            }
        }
    }
}

struct ScoreVelocityCard: View {
    let velocity: Double
    
    var body: some View {
        ZStack {
            // Background
            Color.cardBackgroundLight
            
            // Wave pattern at bottom
            VStack {
                Spacer()
                WaveShape(amplitude: 6, frequency: 0.08)
                    .fill(Color.accentGreen.opacity(0.1))
                    .frame(height: 30)
            }
            
            HStack(spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Score Velocity")
                        .font(DesignSystem.Typography.heading2())
                        .foregroundColor(.textPrimaryDark)
                    Text("Your trust score is improving")
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(.textSecondaryDark)
                }
                
                Spacer()
                
                ZStack {
                    // Glowing background circle
                    Circle()
                        .fill(Color.accentGreen.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .glow(color: .accentGreen, radius: 8)
                    
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 18, weight: .bold))
                        Text("+\(String(format: "%.1f", velocity))")
                            .font(DesignSystem.Typography.heading1(size: 22))
                    }
                    .foregroundColor(.accentGreen)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.card)
                .fill(Color.accentGreen.opacity(0.12))
        )
        .cornerRadius(DesignSystem.BorderRadius.card)
    }
}

