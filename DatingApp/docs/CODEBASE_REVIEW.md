# Codebase Review

Review date: 2026-06-05
Reviewed commit target: `f82cf49`
Actual repository HEAD during review: `942edc6`
Repository path: `DatingApp`
Application path: `DatingApp/app/mobile`

## Architecture overview

The repository now contains a working Flutter + Firebase implementation rather than only planning artifacts. The production code is concentrated in the Flutter mobile client at `DatingApp/app/mobile`, with Firebase configuration and backend automation in `DatingApp/backend`.

### Mobile architecture

The Flutter app follows a feature-sliced structure with a relatively clean separation between:

- `core/`: application-wide config, Firebase bootstrap/providers, routing, theme, logging, error handling, and notification plumbing.
- `features/`: domain-specific modules for `auth`, `profile`, `discovery`, `connections`, `chat`, `notifications`, `safety`, `verification`, and `home`.
- `shared/`: cross-feature UI helpers and utilities.

Each major feature generally follows this pattern:

- `domain/`: entities and repository contracts
- `data/`: Firebase-backed implementations
- `application/`: Riverpod providers/controllers
- `presentation/`: screens and widgets

### App startup and state management

- `app/mobile/lib/main.dart` delegates entirely to `bootstrap()`.
- `app/mobile/lib/bootstrap.dart` creates a root Riverpod `ProviderContainer`, installs error handlers, initializes Firebase, registers FCM background handling, and runs the app through `UncontrolledProviderScope`.
- `app/mobile/lib/app.dart` creates `MaterialApp.router` and wires theme, router, and global scaffold messenger.
- State management uses `flutter_riverpod` with `riverpod_annotation` and generated providers.
- Navigation uses `go_router` with a centralized startup-state gate in `core/routing`.

### Firebase/backend architecture

- Firebase services are initialized via `core/firebase/firebase_bootstrap.dart`.
- Environment selection is compile-time driven through `core/config/env_config.dart`.
- The repo supports both emulator-first development and live Firebase projects.
- Cloud Functions in `backend/functions/src/index.ts` currently handle push notification fan-out for friend requests and chat messages.
- Security boundaries are primarily enforced in `backend/firestore/firestore.rules` and `backend/firestore/storage.rules`.

## Feature inventory

The codebase includes implemented support for the following functional areas:

- Phone number authentication with OTP verification
- User bootstrap document creation on first sign-in
- Profile onboarding and completion logic
- Multi-photo profile image management
- Discovery feed with filters and public profile viewing
- Friend request creation, acceptance, rejection, and connection lists
- Real-time chat with conversations and messages
- Device token registration and FCM push notifications
- Blocking and abuse reporting
- Verification selfie submission and admin-review-oriented verification state
- App startup gating for logged-out, onboarding, and ready states
- Emulator-aware Firebase wiring and environment configuration

### User-facing routes currently wired

The router exposes screens for:

- splash
- phone login
- OTP verification
- onboarding
- home
- photo management
- discovery
- profile details
- friend requests
- connections
- conversations list
- one-to-one chat
- verification

## Firestore collections

Based on repository implementations, rules, and Cloud Functions, the active Firestore model includes these top-level collections and subcollections.

### Top-level collections

- `users`
  - Main public profile document keyed by `uid`
  - Fields include account state, onboarding state, verification state, and public discovery/profile data
- `friendRequests`
  - Pending/accepted/rejected request workflow between users
- `connections`
  - Accepted mutual relationships, with both participant UIDs stored for querying
- `conversations`
  - One-to-one conversation metadata including participants and last message information
- `blocks`
  - Block relationships keyed as `blockerUid_blockedUid`
- `reports`
  - Abuse/safety reports submitted by users
- `verificationRequests`
  - Verification submission and review status, keyed by `uid`

### Nested collections

- `users/{uid}/private/data`
  - Sensitive owner-only information such as phone number
- `users/{uid}/deviceTokens/{token}`
  - FCM registration tokens for push delivery
- `conversations/{conversationId}/messages/{messageId}`
  - Real-time chat messages

### Indexed query paths

Composite indexes currently exist for:

- `users` filtered by onboarding state, account status, and age
- `friendRequests` by recipient, status, and creation time
- `connections` by participant membership and creation time
- `conversations` by participant membership and last-message time
- `verificationRequests` by status and submission time

## Firebase services

The repository currently integrates the following Firebase services.

- `Firebase Auth`
  - Phone number sign-in and OTP verification
- `Cloud Firestore`
  - Primary application database for users, requests, connections, chats, blocks, reports, and verification state
- `Cloud Storage`
  - Profile photos and verification selfies
- `Firebase Cloud Messaging`
  - Device token registration and push notifications
- `Cloud Functions for Firebase`
  - Server-side push triggers for request creation, request acceptance, and new messages
- `Firebase Emulator Suite`
  - Local Auth, Firestore, Storage, Functions, and Emulator UI

Notably absent from the current implementation:

- Firebase App Check
- Firebase Analytics
- Firebase Crashlytics
- Firebase Remote Config
- Firebase Hosting for an admin app in active use

## Security model

The security posture is better than a prototype that relies only on client code, but it is not yet fully production hardened.

### Strengths

- Firestore is deny-by-default outside explicitly allowed paths.
- Public and private user data are separated, with `users/{uid}/private/data` restricted to the owner.
- Verification requests can only be submitted by the user for their own UID in pending state, while admin updates are reserved for admin claims.
- Reports are write-only for normal users, which limits disclosure of moderation activity.
- Storage rules restrict profile and verification uploads to authenticated owners and enforce image content type plus size limits.
- Blocks, reports, and verification data all have explicit rules instead of relying on implicit client behavior.

### Weaknesses and gaps

- Admin capability currently depends on `request.auth.token.admin == true`, but there is no visible end-to-end admin claim provisioning or admin dashboard enforcement flow in the reviewed implementation.
- Cloud Functions send notifications but do not enforce business invariants; important trust decisions still rely on clients plus rules.
- Verification approval/rejection methods exist in the mobile repository, which means privileged operations are represented in client code even if rules should block non-admin usage. That increases confusion and misuse risk.
- Read rules appear to permit signed-in discovery of public user documents broadly; that is probably intentional, but it raises privacy review requirements for every field stored on `users/{uid}`.
- Report submission appears minimally validated server-side beyond UID checks.
- No App Check means backend resources remain more exposed to abuse from scripted clients.
- No evidence of rate limiting, anti-spam controls, or abuse heuristics for OTP retries, requests, messages, reports, or verification submissions beyond provider defaults.

## Technical debt

The codebase is organized well enough to continue iterating, but several debt areas are visible.

- Repository documentation is stale: `DatingApp/README.md` still says the app is in planning and that application code does not yet exist.
- `docs/CODEBASE_REVIEW.md` already existed before this task and required verification against live code, indicating documentation drift risk.
- Generated Riverpod files are committed throughout the app, which is normal for Flutter teams but requires consistent regeneration discipline.
- Business logic is split across client repositories, Riverpod controllers, Firestore rules, and Functions, with limited explicit architectural documentation tying them together.
- Discovery and safety policies are encoded across models/rules/controllers but are not yet centralized into a clear trust policy layer.
- Backend automation is narrow: Functions cover notifications only, leaving moderation, verification workflow, cleanup, and policy enforcement mostly unimplemented server-side.
- The admin area exists structurally in the repo, but the reviewed task centered on mobile; production moderation tooling appears incomplete relative to the safety-sensitive domain.
- Some implementation details remain encoded as stringly-typed Firestore fields and status values, which can drift between app, rules, and functions.

## Missing tests

The app has useful unit-level coverage for several domain/model areas, but important gaps remain.

### Present coverage

Current tests cover:

- environment config
- profile completion and validation logic
- photo validation
- discovery filter/public profile model logic
- connection domain logic
- report domain logic
- verification request domain logic
- conversation ID logic
- default widget smoke test

### Missing or weak coverage

- No emulator-backed integration tests for Firestore repositories
- No tests validating Firestore security rules behavior
- No tests validating Storage rules behavior
- No tests for router redirect/startup gating behavior
- No tests for authentication controller flows and OTP edge cases
- No tests for onboarding controller state transitions
- No tests for repository error mapping across Firebase failures
- No tests for chat stream behavior and message ordering
- No tests for connection workflow side effects across request acceptance/rejection
- No tests for notification token registration lifecycle
- No tests for Cloud Functions notification triggers
- No golden/widget coverage for key screens in a UI-heavy consumer app

For a trust-sensitive dating product, the lack of emulator integration tests is the largest validation gap.

## Scalability concerns

The current architecture is appropriate for early-stage development but will encounter pressure as usage grows.

- Discovery appears to rely on Firestore query constraints over user documents. Firestore is not ideal for rich matchmaking, ranking, or geospatial discovery at larger scale.
- User profiles, discovery visibility fields, and verification state all live on the same `users/{uid}` document, which may become a hot aggregation point as features expand.
- Chat is modeled as per-conversation subcollections, which is workable, but unread counts, moderation, search, retention, and large-scale notification fan-out are not yet addressed.
- Notification fan-out reads all device tokens from Firestore on each event; workable now, but lacks batching strategy, observability, and per-user notification preferences.
- Safety and moderation data are stored, but there is no visible workflow for queue processing, escalation, reviewer assignment, or abuse analytics.
- Verification image storage and download URL persistence may become difficult to rotate or secure tightly over time; signed URL strategy or stricter access patterns may be needed later.
- No evidence of background cleanup jobs for stale friend requests, orphaned tokens, abandoned verification artifacts, or old reports.
- Query/index strategy is still MVP-oriented and may need redesign once filtering expands beyond simple field combinations.

## Production readiness assessment

Overall assessment: not production ready yet.

### Ready enough for continued internal development

- Clear Flutter app structure
- Working Firebase integration
- Core social flow implemented end-to-end
- Basic Firestore and Storage rules in place
- Notification triggers implemented
- Initial domain/unit tests present

### Blocking issues before production launch

- Stale top-level documentation and likely process drift
- Insufficient automated integration/security testing
- Incomplete moderation/admin workflow for a safety-critical domain
- Limited server-side enforcement beyond notification triggers and security rules
- No App Check / anti-abuse hardening
- No visible analytics, crash reporting, or operational observability layer
- No demonstrated release/environment separation strategy beyond compile-time config
- No evidence of migration/versioning strategy for evolving Firestore schemas
- No evidence of privacy/compliance review for exposed profile fields and stored verification data

If released broadly in its current state, the largest risks would be abuse handling, privacy leakage from public profile fields, and regression risk from limited end-to-end test coverage.

## Recommended next phase

Recommended next phase: **Phase 2.1 - Production Hardening and Trust Infrastructure**

That phase should focus on the following, in order:

1. Align documentation with reality
   - update root and app docs to reflect the actual implementation state
   - document canonical Firestore schemas and public/private field boundaries

2. Add emulator-backed validation
   - repository integration tests against Auth/Firestore/Storage emulators
   - automated tests for Firestore and Storage rules
   - Cloud Functions trigger tests

3. Harden trust and abuse controls
   - implement admin claim provisioning and documented reviewer flows
   - move verification approval/rejection and other privileged actions behind server-controlled paths
   - add App Check and basic anti-spam/rate-limit measures

4. Strengthen operational readiness
   - add crash reporting/logging strategy and release environment discipline
   - define production/staging Firebase project separation
   - add observability around notification failures and moderation workflows

5. Revisit scaling-sensitive product areas
   - redesign discovery for future ranking/geospatial needs
   - define strategy for chat unread counts, moderation, and retention
   - plan asynchronous cleanup/maintenance jobs

In short: the next best investment is not another end-user feature. It is security, verification workflow hardening, emulator-backed test coverage, and production operations discipline.
