# StudySpot — Product Requirements Document

## Overview
StudySpot is a community-powered iOS app that helps students find the perfect place to study — right now. Users open the app, see study spots on a map filtered by whether they're currently open, tap a spot to check its vibe (quiet? outlets? good for groups?), head there, and then contribute back by rating it and uploading a photo. The core value is real-time utility: helping someone find a good spot in the next 5 minutes, not just browsing for fun.

## Tech Stack
- **Language/Framework:** Swift + SwiftUI
- **Backend:** Firebase Firestore (data) + Firebase Storage (photos)
- **Location:** CoreLocation (user's current location for map centering + distance)
- **Maps:** MapKit (primary discovery surface)
- **Architecture:** MVVM
- **Min iOS Target:** iOS 17+

---

## User Flow

1. User opens app → lands on **Map View** centered on their location
2. Pins show nearby study spots — color coded by open/closed status
3. User taps a pin → **Spot Detail Sheet** slides up with all info
4. User decides to go → navigates there
5. Once there, user taps "I'm Here — Rate This Spot" → **Rate & Photo flow**
6. Their rating + photo is saved to Firebase and visible to others immediately

---

## Data Model

### Firestore Collection: `studySpots`

| Field | Type | Description |
|---|---|---|
| `name` | String | e.g. "O'Neill Library 3rd Floor" |
| `description` | String | Short description of the spot |
| `latitude` | Double | Coordinates of the spot |
| `longitude` | Double | Coordinates of the spot |
| `imageURL` | String | Firebase Storage download URL |
| `hoursOpen` | String | e.g. "8:00 AM" |
| `hoursClose` | String | e.g. "11:00 PM" |
| `isOpenWeekends` | Bool | Whether the spot is open on weekends |
| `noiseLevel` | String | "quiet" / "moderate" / "loud" |
| `busyness` | String | "empty" / "moderate" / "packed" — community updated |
| `hasOutlets` | Bool | Power outlets available |
| `goodForGroups` | Bool | Suitable for group work |
| `hasWifi` | Bool | Wifi available |
| `averageRating` | Double | Calculated from all reviews (0.0–5.0) |
| `reviewCount` | Int | Total number of reviews |
| `postedBy` | String | Display name of original poster |
| `datePosted` | Timestamp | When the spot was first added |

### Firestore Subcollection: `studySpots/{spotId}/reviews`

| Field | Type | Description |
|---|---|---|
| `rating` | Int | 1–5 stars |
| `comment` | String | Optional written review |
| `imageURL` | String | Optional photo from this visit |
| `busynessReport` | String | "empty" / "moderate" / "packed" |
| `postedBy` | String | Reviewer display name |
| `datePosted` | Timestamp | When this review was submitted |

---

> ⭐ = stretch goal, implement only if time allows after core features are complete and polished

## Views

### 1. SpotMapView (Home / Tab 1)
- Full-screen MapKit map centered on user's current location
- Each spot is a standard annotation pin
- ⭐ **Custom colored pins: green = open, gray = closed**
- Tap a pin → `SpotDetailSheet` slides up as a bottom sheet
- Floating "+" button → opens `AddSpotView`
- ⭐ **Toolbar toggle: "Hide Closed Spots" to declutter the map**

### 2. SpotDetailSheet
- Presented as a bottom sheet when a map pin is tapped
- Shows:
  - Spot name + open/closed badge (calculated from current time vs. hours)
  - Hours (e.g. "Open until 11:00 PM")
  - `AsyncImage` photo
  - Attribute tag row: icons + labels for noise level, outlets, wifi, group-friendly
  - Busyness indicator: "Empty / Moderate / Packed"
  - Star rating (average) + review count
  - "See All Reviews" → `ReviewListView`
  - "I'm Here — Rate This Spot" button → `AddReviewView`

### 3. SpotListView (Tab 2)
- Scrollable list of all spots, open spots listed first
- Each row: name, open/closed badge, noise level icon, average star rating
- ⭐ **Distance from user shown on each row**
- Segmented picker: **All / Open Now / Quiet / Has Outlets**
- Tap row → `SpotDetailSheet`

### 4. AddSpotView (sheet)
- Form to submit a new study spot
- Fields: name, description, open/close time pickers
- ⭐ **Weekend availability toggle**
- Attribute toggles: outlets, wifi, group-friendly
- Noise level picker: quiet / moderate / loud
- Photo: camera or photo library
- Location: auto-filled from CoreLocation
- Cancel / Save in toolbar

### 5. AddReviewView (sheet)
- Triggered from "I'm Here — Rate This Spot"
- Star rating picker (1–5), optional comment, busyness picker, optional photo
- On save:
  - Writes to `reviews` subcollection
  - Recalculates and updates `averageRating` + `reviewCount` on parent spot document
  - Updates `busyness` on parent spot with latest report

### 6. SignInView
- Shown on first launch when no authenticated user is detected
- Full-screen view with a Sign in with Apple button
- On successful sign-in, transitions to the main tab view
- `postedBy` is set from `Auth.auth().currentUser?.displayName`

### 7. ReviewListView
- List of all reviews for a spot, newest first
- Each row: stars, comment, photo thumbnail, busyness report, date

### 8. ⭐ FilterView (sheet)
- ⭐ **Toggle: Show/hide closed spots**
- ⭐ **Noise level filter: All / Quiet / Moderate / Loud**
- ⭐ **Outlets: Any / Required**
- ⭐ **Group-friendly: Any / Yes**

---

## Open/Closed Logic
- Computed property on `StudySpot` model: `var isOpenNow: Bool`
- Compares current time against `hoursOpen` and `hoursClose`
- ⭐ **Weekend support: also checks `isOpenWeekends` against current day of week**
- Purely client-side — no server logic needed

---

## MVVM Structure

```
Models/
  StudySpot.swift           ← Codable struct; includes isOpenNow computed property
  Review.swift              ← Codable struct for subcollection documents

ViewModels/
  SpotsViewModel.swift      ← @Observable; Firestore listener; filter logic
  SpotDetailViewModel.swift ← @Observable; loads reviews subcollection for one spot
  AddSpotViewModel.swift    ← Photo picking, location, form state, Firestore save
  AddReviewViewModel.swift  ← Review submission + updates parent spot averageRating

Views/
  SignInView.swift
  SpotMapView.swift
  SpotListView.swift
  SpotDetailSheet.swift
  ReviewListView.swift
  AddSpotView.swift
  AddReviewView.swift
  FilterView.swift

Helpers/
  LocationManager.swift     ← CLLocationManager wrapper
  ImageUploader.swift       ← Firebase Storage upload; returns download URL
```

---

## Authentication

- **Provider:** Firebase Authentication with Sign in with Apple
- **Gated actions:** posting a spot and submitting a review require sign-in; browsing the map and reading reviews do not
- **First launch flow:** if no authenticated user is detected, show `SignInView` (full-screen) with a Sign in with Apple button before entering the app; once signed in, proceed to the normal tab view
- **`postedBy` field:** populated from the Firebase user's `displayName` after sign-in
- **View:** `SignInView` — full-screen, single Sign in with Apple button, shown when `Auth.auth().currentUser == nil`

---

## Firebase Setup Notes
- Enable Firestore + Firebase Storage + Authentication in Firebase console
- In Firebase Auth, enable the Sign in with Apple provider
- Add the Sign in with Apple capability in Xcode (Signing & Capabilities)
- Add `GoogleService-Info.plist` to Xcode project root
- Firestore + Storage rules: allow read/write during development

---

## Non-Goals (out of scope for v1)
- In-app navigation / directions
- Push notifications
- EventBoard tab (planned for a future version)
- Admin moderation
- ⭐ Full FilterView sheet (stretch — segmented picker on list view covers the core need)
