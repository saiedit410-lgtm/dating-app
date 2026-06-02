# Spark — Android-first Dating App

A trust-first dating & social-connection app built **Flutter + Firebase**, Android-first.
This repository is currently in the **planning & architecture** phase — no application
code yet. All decisions live in [`docs/`](docs/README.md).

## What's here

| Path | Purpose |
|------|---------|
| [`docs/`](docs/README.md) | PRD, architecture, schema, security, roadmap, deployment |
| [`app/`](app/README.md) | Flutter client (to be scaffolded — Phase 1) |
| [`backend/functions/`](backend/functions/README.md) | Cloud Functions (TypeScript) |
| [`backend/firestore/`](backend/firestore/README.md) | Security rules & indexes |
| [`admin/`](admin/README.md) | Admin dashboard (Flutter Web) |
| [`.github/workflows/`](.github/workflows/README.md) | CI/CD pipelines |
| [`assets/`](assets/README.md) | Design & brand assets |
| [`scripts/`](scripts/README.md) | Dev & ops tooling |
| `idea.md`, `requirements.txt`, `notes/` | Original concept notes |

## Stack at a glance

- **Client:** Flutter · Riverpod · GoRouter (Android-first, cross-platform-ready)
- **Backend:** Firebase — Auth (phone OTP), Firestore, Storage, Cloud Functions, FCM
- **Admin:** Flutter Web on Firebase Hosting
- **Principles:** safety-first, privacy by default, free/low-cost (emulator-driven dev)

## MVP scope

OTP login · profiles + multiple photos · verification · nearby + city/state discovery ·
friend requests (accept/reject) · real-time chat · block · report · admin dashboard.

## Getting started (once Phase 1 begins)

See the [Development Roadmap](docs/DevelopmentRoadmap.md) and
[Deployment Plan](docs/DeploymentPlan.md). Local development runs entirely on the
**Firebase Emulator Suite** (zero cost).

---
*Status: Phase 0 — Planning. See [docs/](docs/README.md).*
