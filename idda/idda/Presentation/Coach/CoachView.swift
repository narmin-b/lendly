//
//  CoachView.swift
//  idda
//
//  Created by Narmin Baghirova on 19.12.25.
//

import SwiftUI
import Foundation

// MARK: - API Models + Client

struct ChatRequest: Codable {
    let message: String
    let current_quest_title: String?
    let current_quest_desc: String?
}

struct ChatResponse: Codable {
    let reply: String
}

/// Simple backend client (calls your FastAPI /chat)
final class CoachAPI {
    static let baseURL = "https://chatbot-backend-phi-nine.vercel.app"
    static let demoToken: String? = "idda-demo-9f3k2"

    static func send(message: String, questTitle: String?, questDesc: String?) async throws -> String {
        guard let url = URL(string: baseURL + "/chat") else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ✅ Send demo token header (backend expects X-Demo-Token)
        if let t = demoToken {
            req.setValue(t, forHTTPHeaderField: "X-Demo-Token")
        }

        let payload = ChatRequest(
            message: message,
            current_quest_title: questTitle,
            current_quest_desc: questDesc
        )

        req.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "CoachAPI", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Server error (\(http.statusCode)): \(body)"
            ])
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decoded.reply
    }
}

// MARK: - View

struct CoachView: View {
    var initialQuestion: String? = nil
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var currentQuest: Quest?
    @State private var showDefaultQuestions: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            headerCard

            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.md) {
                            if messages.isEmpty {
                                welcomeMessage
                            }

                            ForEach(messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }

                            if isLoading {
                                HStack {
                                    TypingIndicatorView()
                                    Spacer()
                                }
                                .padding(.horizontal, DesignSystem.Spacing.container)
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.lg)
                    }
                    .background(Color.backgroundScreen)
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .frame(height: geo.size.height)
                }
            }

            if showDefaultQuestions && messages.isEmpty {
                defaultQuestionsBottomView
            }

            messageInputView
        }
        .background(Color.backgroundScreen)
        .navigationBarHidden(true)
        .onAppear {
            loadCurrentQuest()
            // If initial question is provided, send it automatically
            if let question = initialQuestion, messages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    sendMessage(question)
                }
            }
        }
    }

    private var headerCard: some View {
        ZStack {
            // Background with texture
            Color.cardBackgroundLight

            HStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.accentGreen)
                        .frame(width: 32, height: 32)
                        .glow(color: .accentGreen, radius: 3)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textOnAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Strategic")
                        .font(DesignSystem.Typography.heading2(size: 18))
                        .foregroundColor(.textPrimaryDark)
                    Text("Coach")
                        .font(DesignSystem.Typography.heading2(size: 18))
                        .foregroundColor(.accentGreen)
                }

                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .frame(height: 60)
    }

    private var welcomeMessage: some View {
        ZStack {
            // Decorative background elements
            HStack {
                OrganicBlob(seed: 0.8)
                    .fill(Color.accentGreen.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .offset(x: -40, y: -30)
                Spacer()
            }

            HStack {
                Spacer()
                OrganicBlob(seed: 1.5)
                    .fill(Color.accentGreen.opacity(0.08))
                    .frame(width: 100, height: 100)
                    .offset(x: 30, y: 40)
            }

            VStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    // Glowing circles
                    Circle()
                        .fill(Color.accentGreen.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .glow(color: .accentGreen, radius: 15)

                    Circle()
                        .fill(Color.accentGreen.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(.accentGreen)
                }

                Text("Hi! I'm your AI Strategic Coach")
                    .font(DesignSystem.Typography.heading1())
                    .foregroundColor(.textPrimaryDark)

                Text("I'll help you understand your business metrics and guide you through completing quests to improve your trust score.")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(.textSecondaryDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.container)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xl)
    }

    private var defaultQuestionsBottomView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(defaultQuestions.enumerated()), id: \.offset) { _, question in
                    Button {
                        sendDefaultQuestion(question)
                    } label: {
                        Text(question)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.textOnAccent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(width: 200, height: 80, alignment: .leading)
                            .background(Color.accentGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.neutralLightGray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color.backgroundScreen)
    }

    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.neutralLightGray)
            HStack(spacing: DesignSystem.Spacing.md) {
                TextField("Ask me anything...", text: $inputText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(.textPrimaryDark)
                    .lineLimit(1...4)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(Color.neutralLightGray)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button))
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .foregroundColor(.accentGreen)
                            .fontWeight(.semibold)
                        }
                    }

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(
                            inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            Color.textSecondaryDark : Color.accentGreen
                        )
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .padding(.trailing, DesignSystem.Spacing.sm)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(Color.cardBackgroundLight)
        }
    }

    private let defaultQuestions = [
        "How can I improve my cash flow?",
        "What affects my creditworthiness?",
        "How to reduce inventory turnover days?",
        "Best practices for SME debt management"
    ]

    private func loadCurrentQuest() {
        // Mock current quest
        currentQuest = Quest(
            title: "Improve Profit Margin",
            description: "Reduce operational costs by 5% or increase pricing efficiency",
            category: .growth,
            isCompleted: false,
            progress: 0.3,
            reward: QuestReward(trustScoreIncrease: 5.0, unlocksOffer: nil),
            level: 5
        )
    }

    // ✅ Updated: default questions now use real backend too
    private func sendDefaultQuestion(_ question: String) {
        sendMessage(question)
    }

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        sendMessage(inputText)
        inputText = ""
    }

    // ✅ Updated: This now calls backend instead of generateResponse()
    private func sendMessage(_ text: String) {
        print("💬 [CoachView] Sending message: \"\(text)\"")
        showDefaultQuestions = false

        let userMessage = ChatMessage(
            id: UUID(),
            text: text,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        print("👤 [CoachView] User message added. Total messages: \(messages.count)")

        isLoading = true
        print("⏳ [CoachView] Loading state set to true")

        Task {
            do {
                print("🚀 [CoachView] Starting API call...")
                let replyText = try await CoachAPI.send(
                    message: text,
                    questTitle: currentQuest?.title,
                    questDesc: currentQuest?.description
                )

                print("✅ [CoachView] API call successful. Reply received: \(replyText.prefix(100))...")
                
                await MainActor.run {
                    let aiMessage = ChatMessage(
                        id: UUID(),
                        text: replyText,
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                    isLoading = false
                    print("🤖 [CoachView] AI message added. Total messages: \(messages.count)")
                    print("✅ [CoachView] Loading state set to false")
                }
            } catch {
                print("❌ [CoachView] API call failed: \(error.localizedDescription)")
                print("❌ [CoachView] Error details: \(error)")
                
                await MainActor.run {
                    let errMsg = "Connection error: \(error.localizedDescription)"
                    let aiMessage = ChatMessage(
                        id: UUID(),
                        text: errMsg,
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                    isLoading = false
                    print("⚠️ [CoachView] Error message added. Total messages: \(messages.count)")
                    print("✅ [CoachView] Loading state set to false")
                }
            }
        }
    }

    // ⚠️ Kept for reference, but no longer used once backend is connected.
    private func generateResponse(for question: String) -> ChatMessage {
        let lowercased = question.lowercased()

        var response = ""

        if lowercased.contains("trust score") || lowercased.contains("how is") {
            response = "Your Trust Score is calculated based on three key categories:\n\n• Liquidity: Cash flow, debt-to-income ratio\n• Growth: Revenue trends, profit margins\n• Operations: Customer retention, inventory turnover\n\nEach completed quest improves your score in these areas!"
        } else if lowercased.contains("quest") || lowercased.contains("current") {
            response = currentQuest != nil ? "Your current quest is: \(currentQuest!.title)\n\n\(currentQuest!.description)\n\nProgress: \(Int(currentQuest!.progress * 100))%\n\nTo complete this, focus on \(getQuestAdvice(for: currentQuest!.category))" : "You don't have an active quest right now. Check your Learning Path to start one!"
        } else if lowercased.contains("improve") || lowercased.contains("how can") {
            response = "Here are 3 quick ways to improve your Trust Score:\n\n1. Complete daily check-ins to maintain your streak\n2. Connect your POS/ERP systems for real-time data\n3. Focus on quests in your weakest category\n\nWould you like specific advice for any category?"
        } else if lowercased.contains("help") || lowercased.contains("what can") {
            response = "I can help you with:\n\n• Understanding your KPIs\n• Completing quests\n• Improving specific business metrics\n• Navigating financial offers\n\nWhat would you like to know?"
        } else if lowercased.contains("profit") || lowercased.contains("margin") {
            response = "To improve profit margin, consider:\n\n1. Review your pricing strategy - are you charging enough?\n2. Reduce operational costs - negotiate with suppliers\n3. Optimize inventory - reduce waste and overstock\n4. Increase efficiency - automate repetitive tasks\n\nWould you like specific strategies for your industry?"
        } else if lowercased.contains("cash flow") || lowercased.contains("liquidity") {
            response = "Improving cash flow involves:\n\n1. Speed up receivables - offer early payment discounts\n2. Delay payables strategically - negotiate better terms\n3. Maintain cash reserves - aim for 3-6 months expenses\n4. Monitor daily - track inflows and outflows\n\nYour current cash flow KPI shows positive trends!"
        } else {
            response = "That's a great question! Based on your current business metrics, I recommend focusing on \(selectedCategoryAdvice()). Would you like me to explain how to improve in that area?"
        }

        return ChatMessage(
            id: UUID(),
            text: response,
            isUser: false,
            timestamp: Date()
        )
    }

    private func getQuestAdvice(for category: BusinessCategory) -> String {
        switch category {
        case .liquidity:
            return "Focus on improving your cash flow by reducing overdue invoices and maintaining healthy reserves."
        case .growth:
            return "Work on increasing revenue through better pricing strategies and customer acquisition."
        case .operations:
            return "Optimize your operations by improving customer retention and inventory management."
        }
    }

    private func selectedCategoryAdvice() -> String {
        return currentQuest?.category.rawValue ?? "Growth"
    }
}

// MARK: - Chat Message + UI

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    // Cached parsed text to avoid re-parsing on every render
    @State private var cachedFormattedText: Text? = nil
    
    // Parse markdown: **text** for bold, ###text (no closing) for bold italic
    private func parseMarkdownBold(_ text: String) -> Text {
        var result = Text("")
        var currentIndex = text.startIndex
        
        while currentIndex < text.endIndex {
            // Check for ###text (bold italic, no closing ###)
            if let boldItalicStart = text.range(of: "###", range: currentIndex..<text.endIndex) {
                // Add text before ###
                if boldItalicStart.lowerBound > currentIndex {
                    let beforeText = String(text[currentIndex..<boldItalicStart.lowerBound])
                    result = result + parseBoldOnly(beforeText)
                }
                
                // Check if there's a closing ###
                let afterStart = boldItalicStart.upperBound
                if let boldItalicEnd = text.range(of: "###", range: afterStart..<text.endIndex) {
                    // Has closing ###, extract text between
                    let boldItalicText = String(text[afterStart..<boldItalicEnd.lowerBound])
                    result = result + Text(boldItalicText).bold().italic()
                    currentIndex = boldItalicEnd.upperBound
                } else {
                    // No closing ###, make everything after ### bold italic
                    let remainingText = String(text[afterStart...])
                    result = result + Text(remainingText).bold().italic()
                    break
                }
            } else {
                // No more ###, process remaining text for ** patterns
                let remainingText = String(text[currentIndex...])
                result = result + parseBoldOnly(remainingText)
                break
            }
        }
        
        return result
    }
    
    // Helper to parse only **text** patterns (used for text outside ### blocks)
    private func parseBoldOnly(_ text: String) -> Text {
        let parts = text.components(separatedBy: "**")
        var result = Text("")
        
        for (index, part) in parts.enumerated() {
            if index % 2 == 0 {
                result = result + Text(part)
            } else {
                result = result + Text(part).bold()
            }
        }
        
        return result
    }
    
    private var formattedText: Text {
        if let cached = cachedFormattedText {
            return cached
        }
        let parsed = parseMarkdownBold(message.text)
        return parsed
    }

    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)

                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                    formattedText
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(.textOnAccent)
                        .onAppear {
                            if cachedFormattedText == nil {
                                cachedFormattedText = parseMarkdownBold(message.text)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(Color.accentGreen)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.card))
                        .clipShape(
                            .rect(
                                topLeadingRadius: DesignSystem.BorderRadius.card,
                                bottomLeadingRadius: DesignSystem.BorderRadius.card,
                                bottomTrailingRadius: DesignSystem.BorderRadius.xs,
                                topTrailingRadius: DesignSystem.BorderRadius.card
                            )
                        )

                    Text(formatTime(message.timestamp))
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(.textSecondaryDark)
                        .padding(.trailing, DesignSystem.Spacing.sm)
                }
            } else {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.accentGreen)
                            .frame(width: 36, height: 36)

                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textOnAccent)
                    }

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        ZStack {
                            // Background - removed expensive DottedPattern for performance
                            Color.cardBackgroundLight

                            formattedText
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(.textPrimaryDark)
                                .onAppear {
                                    if cachedFormattedText == nil {
                                        cachedFormattedText = parseMarkdownBold(message.text)
                                    }
                                }
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                        }
                        .clipShape(
                            .rect(
                                topLeadingRadius: DesignSystem.BorderRadius.xs,
                                bottomLeadingRadius: DesignSystem.BorderRadius.card,
                                bottomTrailingRadius: DesignSystem.BorderRadius.card,
                                topTrailingRadius: DesignSystem.BorderRadius.card
                            )
                        )
                        .shadow(
                            color: DesignSystem.Shadow.card,
                            radius: DesignSystem.Shadow.cardRadius / 2,
                            x: DesignSystem.Shadow.cardOffset.width,
                            y: DesignSystem.Shadow.cardOffset.height
                        )

                        Text(formatTime(message.timestamp))
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(.textSecondaryDark)
                            .padding(.leading, DesignSystem.Spacing.sm)
                    }

                    Spacer(minLength: 60)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.container)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.accentGreen)
                    .frame(width: 36, height: 36)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textOnAccent)
            }

            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.accentGreen.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.3),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(Color.cardBackgroundLight)
            .clipShape(
                .rect(
                    topLeadingRadius: DesignSystem.BorderRadius.xs,
                    bottomLeadingRadius: DesignSystem.BorderRadius.card,
                    bottomTrailingRadius: DesignSystem.BorderRadius.card,
                    topTrailingRadius: DesignSystem.BorderRadius.card
                )
            )
            .shadow(
                color: DesignSystem.Shadow.card,
                radius: DesignSystem.Shadow.cardRadius / 2,
                x: DesignSystem.Shadow.cardOffset.width,
                y: DesignSystem.Shadow.cardOffset.height
            )

            Spacer()
        }
        .onAppear {
            animationOffset = -4
        }
    }
}
