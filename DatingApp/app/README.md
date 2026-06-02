# `app/` — Flutter Mobile Client (Android-first)

This directory will hold the Flutter application. **No code is generated yet** — this
is the planned structure that `flutter create` will populate during Phase 1 of the
[Development Roadmap](../docs/DevelopmentRoadmap.md).

## Planned `lib/` structure (feature-first, layered)

```
lib/
├── main.dart                  # App entrypoint, Firebase init, runApp()
├── app.dart                   # MaterialApp, theming, router wiring
│
├── core/                      # Cross-cutting concerns (no feature logic)
│   ├── config/                # Env, flavors (dev/staging/prod), constants
│   ├── error/                 # Failure types, exception → Failure mapping
│   ├── network/               # Connectivity, retry, Firebase wrappers
│   ├── router/                # GoRouter config, route guards (auth/verified)
│   ├── theme/                 # Colors, typography, component themes
│   └── utils/                 # Formatters, validators, extensions
│
├── features/                  # One folder per bounded feature
│   ├── auth/                  # OTP login, session, account
│   ├── profile/               # Profile CRUD, photos, verification
│   ├── discovery/             # Nearby users, city/state filters
│   ├── friends/               # Friend requests, accept/reject, blocking
│   ├── chat/                  # Real-time messaging
│   ├── reporting/             # Report users/content
│   └── settings/              # Preferences, privacy, account deletion
│       ├── data/              # DTOs, repositories, Firebase data sources
│       ├── domain/            # Entities, repository interfaces, use cases
│       └── presentation/      # Screens, widgets, state (Riverpod/Bloc)
│
└── shared/                    # Reusable widgets/models used across features
    ├── widgets/
    └── models/
```

See [FlutterArchitecture.md](../docs/FlutterArchitecture.md) for the rationale,
state-management choice, and layering rules.
