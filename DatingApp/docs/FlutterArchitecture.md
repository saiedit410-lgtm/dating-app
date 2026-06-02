# Flutter Architecture

Client-side architecture for the **Android-first** Flutter app: layering, state
management, navigation, and the rules that keep it testable and Firebase-swappable.

---

## 1. Principles

- **Feature-first + layered (Clean-ish).** Group by feature; within each, split
  `data / domain / presentation`. This keeps features independently understandable and
  the codebase navigable as the team grows.
- **Firebase is an implementation detail.** Only the `data` layer imports Firebase.
  `domain` and `presentation` depend on **repository interfaces**, so we can mock for
  tests and migrate backends later (mirrors the lock-in mitigation in
  [FirebaseArchitecture.md](FirebaseArchitecture.md)).
- **Unidirectional data flow.** UI → use case/notifier → repository → data source, and
  state flows back down via immutable state objects.

## 2. Layering

```
presentation  (Widgets, Screens, Notifiers/State)   ← depends on domain
     │
domain        (Entities, Repository interfaces, UseCases)   ← pure Dart, no Firebase
     │
data          (DTOs, Repository impls, Firebase data sources)   ← imports Firebase
```

- **Entity** (domain): clean model used by UI (`UserProfile`, `FriendRequest`, `Message`).
- **DTO** (data): Firestore-shaped model with `fromJson/toJson`, maps ↔ entity.
- **Repository interface** (domain) ↔ **Repository impl** (data).
- **Use case** (domain): one action (`SendFriendRequest`, `GetNearbyUsers`) — optional
  for trivial reads, used where business rules exist.

## 3. State Management — decision

**Choice: Riverpod (v2, with code-gen).**

| Option | Verdict |
|--------|---------|
| **Riverpod** ✅ | Compile-safe DI, testable, no `BuildContext` coupling, great with async/streams (chat). Chosen. |
| Bloc | Excellent, but more boilerplate than a small team needs for MVP. |
| Provider | Simpler but weaker for complex async + DI. |
| setState only | Not viable beyond trivial screens. |

Riverpod's `StreamProvider` maps cleanly onto Firestore **real-time listeners** (chat,
requests, discovery), and its overrides make widget/unit tests trivial.

## 4. Navigation

**GoRouter** with declarative routes + **redirect guards**:
- **Auth guard:** unauthenticated → `/auth`.
- **Onboarding guard:** authed but `onboardingComplete == false` → `/onboarding`.
- **Verified-only routes** (where required) check `isVerified`.

Deep links (FCM notification taps → specific chat/request) handled via GoRouter paths.

## 5. Proposed module map

```
lib/
├── main.dart                # bootstrap: Firebase.initializeApp, ProviderScope
├── app.dart                 # MaterialApp.router, theme, router
├── core/
│   ├── config/              # flavors, env, AppConstants
│   ├── error/               # Failure, AppException, mappers
│   ├── network/             # connectivity, FirebaseRefs helpers
│   ├── router/              # GoRouter + guards
│   ├── theme/               # AppTheme, colors, typography
│   └── utils/               # validators, formatters, geohash helpers
├── features/
│   ├── auth/                # phone+OTP, session
│   ├── profile/             # profile CRUD, photos, verification
│   ├── discovery/           # nearby + city/state filters
│   ├── friends/             # requests, accept/reject, blocking
│   ├── chat/                # chat list + thread (StreamProviders)
│   ├── reporting/           # report flow
│   └── settings/            # prefs, privacy, delete account
│       ├── data/  domain/  presentation/
└── shared/
    ├── widgets/             # buttons, avatars, verified badge, empty states
    └── models/              # shared value objects
```

## 6. Key technical choices & rationale

| Concern | Choice | Why |
|---------|--------|-----|
| State mgmt / DI | **Riverpod 2** | Testable, async-first, no context coupling |
| Routing | **GoRouter** | Declarative + guard redirects + deep links |
| Models | **Freezed + json_serializable** | Immutable entities/DTOs, less boilerplate |
| Async results | **Either / Result type** (`fpdart` or sealed `Result`) | Explicit error handling vs. throwing |
| Local cache | **Hive / shared_preferences** | Cache session, blocks set, prefs |
| Images | **cached_network_image** + **image_picker/cropper** | Perf + photo flow |
| Geo | **geoflutterfire_plus** | Geohash queries (see DatabaseSchema) |
| Real-time | Firestore **snapshots() → StreamProvider** | Live chat/requests |
| Env separation | **Flutter flavors** (dev/staging/prod) | Matches Firebase projects |
| Crash/metrics | **firebase_crashlytics / analytics** | PRD success metrics |

## 7. Theming & UX

- Material 3, light/dark, single source-of-truth `AppTheme`.
- Reusable `VerifiedBadge`, `UserAvatar`, `PrimaryButton`, `Loading/Empty/Error` states.
- Accessibility: scalable text, sufficient contrast, semantic labels.

## 8. Error handling

Data layer catches Firebase exceptions → maps to typed `Failure` → repositories return
`Result<T, Failure>` → notifiers expose `AsyncValue` → UI renders loading/error/data
consistently. No raw exceptions reach the UI.

## 9. Testing strategy

| Level | Tool | Scope |
|-------|------|-------|
| Unit | `flutter_test`, `mocktail` | use cases, repositories (mock data sources), utils |
| Widget | `flutter_test` | screens with Riverpod overrides |
| Integration | `integration_test` + **Firebase Emulator** | auth → onboarding → request → chat |
| Golden (P2) | `golden_toolkit` | key widgets (badge, cards) |

CI runs `flutter analyze`, `flutter test`, and format check on every PR
([DeploymentPlan.md](DeploymentPlan.md)).

## 10. Cross-platform readiness

Although Android-first, we avoid Android-only APIs in shared code and keep platform
specifics behind interfaces, so an iOS launch later is mostly configuration + store
work, not a rewrite.
