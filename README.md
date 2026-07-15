# Lendly

Lendly is an iOS business-health prototype for small and medium-sized businesses. The app combines a learning path, KPI dashboard, sample financing offers, and an AI coach for business-improvement guidance.

## Tech Stack

| Area | Implementation |
| --- | --- |
| Platform | iOS 18+; iPhone and iPad |
| Language | Swift 5 |
| UI | SwiftUI |
| UIKit interoperability | `UINavigationBar`, `UITabBar`, `UIImage`, and keyboard dismissal handling |
| State | SwiftUI `@State`, `@StateObject`, `@ObservedObject`, and Combine `@Published` |
| Charts | Apple Charts on iOS 16+; custom SwiftUI line-chart fallback |
| Networking | `URLSession`, `Codable`, JSON, and Swift concurrency (`async`/`await`) |
| Dependencies | None — only Apple frameworks are used |

## Architecture

The codebase is organized into `Models`, `Views`, `ViewModels`, `Presentation`, and `Utilities`. It uses a lightweight MVVM-style approach: `RoadmapViewModel` is an `ObservableObject` that owns roadmap progress, selected-level state, score data, and marketplace-notification state; the remaining screens keep their local UI state in SwiftUI views.

State is in memory only. There is no persistence, authentication, or shared data service.

### Navigation

`MainTabView` provides four `NavigationView`-based tabs:

- Learning Path
- Dashboard
- Offers
- AI Coach

Task details, offer details, and the contextual coach are presented with SwiftUI sheets.

## API Integration

The AI Coach is the only live backend integration. `CoachAPI` sends a JSON `POST` request via `URLSession` and `async`/`await` to:

`https://chatbot-backend-phi-nine.vercel.app/chat`

The request includes the user message and optional current-quest context; the response is decoded as a JSON object with a `reply` field. The client sends the demo-token header expected by the backend and displays loading or connection-error states in the chat UI.

## Implemented UI Flows

- Learning path with level/task-detail screens and session-only roadmap progress.
- Dashboard with category filtering, KPI cards, and revenue visualization.
- Offer browsing with level-gated sample offers, payment estimates, and a request-justification form.
- AI coach chat backed by the external API.

## Sample Data and Current Scope

Dashboard KPIs and revenue data, marketplace offers/current level, coach quest context, and task definitions are hard-coded sample data. Banking-related wording in task content does not represent a banking integration.

- Task completion is not wired to a full workflow or persistence.
- Offer applications and request submission are UI-only.
- Metrics, tasks, and offers have no backend or database integration.
- The coach requires the external backend to be available.

## Project Structure

```text
idda/
|-- idda.xcodeproj/              # Xcode project
`-- idda/
    |-- iddaApp.swift            # App entry point
    |-- Models/                  # Data models and sample task definitions
    |-- ViewModels/              # Observable roadmap state
    |-- Views/                   # Learning-path and supporting views
    |-- Presentation/            # Tab, dashboard, offers, and coach screens
    |-- Utilities/               # Styling and reusable SwiftUI helpers
    `-- Assets.xcassets/         # App assets
```

## Run Locally

1. Open `idda/idda.xcodeproj` in an Xcode version with the iOS 18 SDK.
2. Choose the `idda` scheme and an iOS 18+ simulator or device.
3. Build and run.

For a physical device, select an available Apple Development signing team in the target settings.
