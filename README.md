# lendly
# by TECHBHOSS

A SwiftUI iOS application designed to help Small and Medium Enterprises (SMEs) improve their business health, access AI-powered coaching, and unlock financial opportunities through gamified task completion.

## 📱 Overview

idda is a business health management platform that guides SMEs through structured tasks to improve key business metrics. By completing levels and tasks, businesses can increase their trust score, unlock financial offers, and receive personalized AI coaching.

## ✨ Features

### 🗺️ Roadmap View
- **Level-based progression system** with visual roadmap
- **Task tracking** with progress indicators
- **Interactive level bubbles** with detailed task information
- **Category-based organization** (Growth, Leverage, Operations)
- **Trust score visualization** with progress tracking

### 🤖 AI Coach
- **Conversational AI interface** for business advice
- **SME-focused default questions** for quick guidance
- **Markdown support** for formatted responses (bold, bold italic)
- **Real-time chat** with typing indicators
- **Keyboard dismissal** with "Done" button

### 📊 Dashboard
- **Key Performance Indicators (KPIs)** display
- **Revenue trend charts** with axis labels
- **Business category insights** (Liquidity, Growth, Operations)
- **Trend indicators** (up/down/stable) with visual feedback

### 🏪 Marketplace
- **Financial offers** (Working Capital, Equipment Financing, Invoice Factoring, Line of Credit)
- **Level-gated unlocks** - complete tasks to access better offers
- **EMI calculator** with real-time updates
- **Interactive sliders** for amount and duration customization

## 🛠️ Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **iOS Version**: iOS 15+
- **Charts**: Swift Charts (iOS 16+) with fallback for iOS 15

## 📁 Project Structure

```
idda/
├── idda/
│   ├── iddaApp.swift              # App entry point
│   ├── ContentView.swift          # Main content view
│   │
│   ├── Models/
│   │   ├── BusinessModels.swift   # Business categories, KPIs, offers, quests
│   │   └── LevelTasks.swift       # Task definitions and difficulty levels
│   │
│   ├── ViewModels/
│   │   └── RoadmapViewModel.swift # Roadmap state management
│   │
│   ├── Views/
│   │   ├── RoadmapView.swift      # Main roadmap interface
│   │   └── CoachViewWithQuestion.swift # Coach wrapper with initial question
│   │
│   ├── Presentation/
│   │   ├── MainTabView.swift      # Tab bar navigation
│   │   ├── Dashboard/
│   │   │   └── DashboardView.swift
│   │   ├── Coach/
│   │   │   └── CoachView.swift    # AI chat interface
│   │   └── Marketplace/
│   │       └── MarketplaceView.swift
│   │
│   └── Utilities/
│       ├── AppColors.swift        # Color palette definitions
│       ├── DesignSystem.swift    # Typography, spacing, border radius
│       ├── BubbleShape.swift     # Custom bubble shape for tooltips
│       └── Textures.swift        # Visual texture patterns
│
└── idda.xcodeproj/               # Xcode project file
```

## 🎨 Design System

### Color Palette
- **Background**: Dark theme (`#1C1D22`)
- **Card Backgrounds**: `#282930`, `#232528`, `#32363F`
- **Accent Green**: `#A4EE6F` (primary action color)
- **Text Colors**: White primary, gray secondary
- **Accent Colors**: Red (`#FF4444`), Gold (`#FFD700`), Silver (`#C0C0C0`)

### Typography
- Custom typography system with body, heading, caption styles
- Consistent font weights and sizes throughout

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0+ deployment target
- macOS 12.0 or later (for development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd idda
```

2. Open the project in Xcode:
```bash
open idda/idda.xcodeproj
```

3. Select your target device or simulator

4. Build and run (⌘R)

## 📖 Usage

### Roadmap
- Navigate through levels by tapping level buttons
- View task details in interactive bubbles
- Track progress with visual indicators
- Complete tasks to unlock new levels and financial offers

### AI Coach
- Tap ready-made questions for quick guidance
- Type custom questions in the input field
- Receive formatted responses with markdown support
- Use "Done" button to dismiss keyboard

### Dashboard
- View key business metrics and KPIs
- Analyze revenue trends with interactive charts
- Monitor business health across categories

### Marketplace
- Browse available financial offers
- Adjust loan amount and duration with sliders
- View calculated EMI and total payment
- Unlock premium offers by completing levels

## 🏗️ Architecture

### MVVM Pattern
- **Models**: Data structures (`BusinessModels`, `LevelTasks`)
- **Views**: SwiftUI views (`RoadmapView`, `DashboardView`, etc.)
- **ViewModels**: State management (`RoadmapViewModel`)

### State Management
- `@State` for local view state
- `@StateObject` / `@ObservedObject` for shared state
- `@Published` properties for reactive updates

### Key Components
- **Custom Shapes**: `BubbleShape` for tooltips
- **Patterns**: `DiagonalStripePattern`, `DottedPattern`, `MeshGradientBackground`
- **Charts**: Swift Charts with iOS 15 fallback

## 🔧 Configuration

### API Integration
The AI Coach feature requires backend API configuration. Update the API endpoint in `CoachView.swift`:

```swift
private let apiURL = "your-api-endpoint"
```

## 🤖 AI Coach Backend

The AI Coach feature is powered by a dedicated backend service deployed on Vercel.  
The mobile app communicates with this service to deliver contextual, execution-focused guidance.

### Backend
- **Live API:**  
  https://chatbot-backend-phi-nine.vercel.app/

- **Source Code:**  
  https://github.com/AlehsanAliyev/ChatbotBackend

### Integration Summary
- The iOS app sends user questions and current task context to the backend.
- All AI processing and credentials are handled server-side.
- Responses are structured to align with the app’s level and task system.

> The mobile application consumes the API only and does not contain any AI credentials or internal logic.

## 📝 Notes

- The app uses a dark theme throughout
- Level 1 and 2 are pre-completed by default
- Level 3 is the active level with 30% progress
- Levels beyond 3 are locked until previous levels are completed
- Financial offers unlock based on level completion

## 👤 Author

**Narmin Baghirova**
- Created: December 19, 2025

## 📄 License

This project is proprietary and confidential.

---

**Note**: This is an active development project. Features and structure may change.
