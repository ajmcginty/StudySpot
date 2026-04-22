# CLAUDE.md — StudySpot Project Context

## Course Context
This project is the final app for **Prof. John Gallaugher's BCSwift course** at Boston College (Spring 2026). The course teaches Swift + SwiftUI from scratch. All code must follow patterns and conventions taught in the course — do NOT introduce patterns or APIs that were not covered, even if they are "better" by general Swift community standards.

**Course playlist:** https://bit.ly/prof-g-swiftui  
**Course site:** https://gallaugher.com  
When answering questions about patterns, architecture, or syntax, prefer approaches demonstrated in Prof. Gallaugher's YouTube videos and course materials over general Swift community conventions.

---

## Reference App: Snacktacular
Snacktacular (Chapter 8 of the course) is the **pattern reference** for core technologies — NOT a template to clone. StudySpot is a completely different app with its own identity, data model, UI, and purpose.

Use Snacktacular only as a reference for *how* to implement these underlying mechanisms:
- Firebase Firestore listener setup and teardown
- Firebase Storage photo uploads and URL storage
- MVVM ViewModel structure and Firestore interaction
- CoreLocation auto-fill of coordinates on the Add form
- MapKit annotations and navigation to detail
- The Add/Edit sheet flow with cancel and save toolbar buttons

**Do NOT copy Snacktacular's UI, field names, variable names, view names, or structure.** StudySpot has its own domain and should feel like an entirely original app. A student reviewing both apps side by side should not think one was derived from the other — only that both use Firebase and MapKit correctly per course conventions.

StudySpot has meaningful features Snacktacular does not have:
- A reviews subcollection with average rating recalculation on save
- Open/Closed status computed from stored hours against the current time
- Attribute tags (outlets, wifi, group-friendly) on each spot
- Community busyness reporting that updates the parent spot document

When in doubt: use Snacktacular to understand the *mechanism*, then implement it fresh for StudySpot's context.

---

## Architecture Rules

### MVVM — strictly follow course conventions
- ViewModels are `@Observable` classes (NOT `ObservableObject` / `@StateObject` — the course uses the newer `@Observable` macro)
- Views use `@State` for local UI state only
- All Firestore and Storage interactions live in the ViewModel, never in a View
- Pass ViewModels into views; don't instantiate them inside child views

### SwiftUI Conventions from This Course
- Use `NavigationStack` (NOT the deprecated `NavigationView`)
- Use `.sheet(isPresented:)` for the Add Spot and Add Review flows, with their own `NavigationStack` inside so toolbar buttons render correctly
- Toolbar buttons use `.toolbar { ToolbarItem(placement: .confirmationAction) { ... } }` and `.toolbar { ToolbarItem(placement: .cancellationAction) { ... } }` for sheets
- Use `.glassProminent` button style where appropriate (iOS 26 convention from course)
- Use `AsyncImage` for loading remote images from Firebase Storage URLs
- Use `listStyle(.plain)` on Lists unless otherwise specified
- Fonts follow course conventions: `.font(.title)` for primary, `.font(.title2)` for secondary, `.font(.title3)` for tertiary

### Firebase Patterns
- Use `Firestore.firestore()` (not dependency injection)
- Real-time listeners use `addSnapshotListener` — not one-time `getDocuments` fetches — so the list updates live
- Always use `try? await` for Firestore writes; print a descriptive error message if they fail
- Store photo URLs as a `String` field (`imageURL`) in the Firestore document
- Upload photos to Firebase Storage before saving the Firestore document; store the returned download URL
- Reviews live in a subcollection: `studySpots/{spotId}/reviews` — not a top-level collection
- When a review is saved, recalculate and update `averageRating` and `reviewCount` on the parent spot document in the same operation

### CoreLocation
- Wrap `CLLocationManager` in a helper class `LocationManager.swift`
- Request `whenInUse` authorization only
- Auto-fill `latitude` and `longitude` fields in the Add Spot form when location is available
- Do not block the UI waiting for location — use the last known location if available

---

## What NOT to Do
- Do NOT use `ObservableObject` or `@StateObject` — the course uses `@Observable`
- Do NOT use `NavigationView` — use `NavigationStack`
- Do NOT use `UIKit` unless absolutely necessary and no SwiftUI equivalent exists
- Do NOT use third-party packages beyond Firebase (no Kingfisher, no Alamofire, etc.)
- Do NOT use `async/await` patterns for Firestore listeners — use `addSnapshotListener` callbacks as taught in class
- Do NOT add features not listed in the PRD without asking first
- Do NOT silently accept deprecated APIs — flag them and ask for the course-appropriate alternative
- Do NOT implement ⭐ stretch features from the PRD until all core features are complete and polished

---

## Project Structure
```
StudySpot/
├── Models/
│   ├── StudySpot.swift           ← Codable struct; includes isOpenNow computed property
│   └── Review.swift              ← Codable struct for reviews subcollection
├── ViewModels/
│   ├── SpotsViewModel.swift      ← Firestore listener on studySpots; filter logic
│   ├── SpotDetailViewModel.swift ← Loads reviews subcollection for one spot
│   ├── AddSpotViewModel.swift    ← Photo picking, location, form state, save
│   └── AddReviewViewModel.swift  ← Review submission + updates parent averageRating
├── Views/
│   ├── SpotMapView.swift
│   ├── SpotListView.swift
│   ├── SpotDetailSheet.swift
│   ├── ReviewListView.swift
│   ├── AddSpotView.swift
│   └── AddReviewView.swift
└── Helpers/
    ├── LocationManager.swift     ← CLLocationManager wrapper
    └── ImageUploader.swift       ← Firebase Storage upload; returns download URL
```

---

## General Instructions
- Write clean, readable code with brief comments explaining the "why" — this is a learning project and the student needs to understand every line
- When you make a non-obvious choice, add a `// NOTE:` comment explaining why
- If something deviates from Snacktacular's approach, flag it explicitly so the student is aware
- Keep functions short — prefer multiple small functions over one large one
- Always check: would Prof. Gallaugher recognize this pattern from his course videos? If not, reconsider.
