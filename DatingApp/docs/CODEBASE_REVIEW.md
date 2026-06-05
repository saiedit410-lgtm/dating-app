# Codebase Review

Review date: 2026-06-05
Reviewed commit: `f82cf49`
Repository path: `DatingApp`

## Summary

The repository contains a real Flutter + Firebase dating application implementation for all stated completed phases from Flutter foundation through verification. The mobile app is organized as a feature-sliced Flutter codebase using Riverpod code generation, GoRouter, Firebase Auth, Firestore, Storage, Messaging, and Firebase Cloud Functions.

The code is not production-ready yet. The main gaps are security-rule hardening, emulator-backed integration tests, stronger server-side validation, moderation/admin workflows, production environment separation, and scale-oriented discovery/query design. The recommended next phase is Phase 2.1: Production Hardening, Security Rules, and Test Infrastructure.

## Architecture Overview

### Flutter app

- Entry point: `app/mobile/lib/main.dart` calls `bootstrap()`.
- Bootstrap: `app/mobile/lib/bootstrap.dart` creates a root `ProviderContainer`, installs global error handlers, initializes Firebase, registers push handlers, and runs `DatingApp` through `UncontrolledProviderScope`.
- Root widget: `app/mobile/lib/app.dart` wires `MaterialApp.router`, theme, global scaffold messenger, and the GoRouter provider.
- Core modules:
  - `core/config`: compile-time environment resolution through `APP_ENV` and `USE_FIREBASE_EMULATORS`.
  - `core/firebase`: singleton Firebase providers and emulator/live Firebase bootstrap.
  - `core/routing`: centralized route enum, GoRouter provider, and auth/onboarding startup stage.
  - `core/theme`, `core/error`, `core/logging`, `core/notifications`.
- Feature modules use a consistent structure:
  - `domain`: app/domain models and repository interfaces.
  - `data`: Firebase-backed repository implementations.
  - `application`: Riverpod providers/controllers.
  - `presentation`: screens and widgets.

### Riverpod providers

The app uses `riverpod_annotation` with generated providers. Important provider groups:

- Core: `envConfigProvider`, `appLoggerProvider`, `firebaseAuthProvider`, `firebaseFirestoreProvider`, `firebaseStorageProvider`, `appStartupStageProvider`, `goRouterProvider`.
- Auth: `authRepositoryProvider`, `userRepositoryProvider`, `authStateChangesProvider`, `phoneAuthControllerProvider`.
- Profile/photos: `profileRepositoryProvider`, `photoRepositoryProvider`, `currentUserProfileProvider`, `onboardingControllerProvider`, `photoManagerControllerProvider`.
- Discovery: `discoveryRepositoryProvider`, `profileByIdProvider`, `discoveryFiltersControllerProvider`, `discoveryControllerProvider`.
- Connections: `connectionRepositoryProvider`, `relationshipProvider`, `incomingRequestsProvider`, `connectionsControllerProvider`.
- Chat: `chatRepositoryProvider`, `conversationsProvider`, `chatControllerProvider`.
- Notifications: `deviceTokenRepositoryProvider`, `notificationServiceProvider`.
- Safety: `safetyRepositoryProvider`, `blockedUidsProvider`.
- Verification: `verificationRepositoryProvider`, `myVerificationRequestProvider`, `verificationControllerProvider`.

### Routing

GoRouter is centralized in `core/routing/app_router.dart`. Routes exist for:

- `/` splash
- `/login` phone login
- `/otp` OTP verification
- `/onboarding`
- `/home`
- `/photos`
- `/discovery`
- `/profile/:uid`
- `/requests`
- `/connections`
- `/chats`
- `/chat/:uid`
- `/verification`

Route guards are driven by `AppStartupStage`:

- `loading` routes to splash.
- `loggedOut` allows only login/OTP.
- `onboarding` routes to onboarding.
- `ready` keeps users out of pre-auth/onboarding routes.

## Completed Phase Verification

All listed phases have corresponding source code:

- Phase 1.1 Flutter Foundation: Flutter app scaffold, Material 3 theme, routing, logging, errors, app bootstrap, tests.
- Phase 1.2 Firebase Foundation: Firebase options, Firebase initialization, emulator wiring, Firebase providers, `firebase.json`, Firestore/Storage rules, indexes.
- Phase 1.2B OTP Authentication: phone login screen, OTP screen, `FirebaseAuthRepository`, `PhoneAuthController`, user document creation.
- Phase 1.3 Profile Creation & Onboarding: onboarding domain models, controller, screen, profile repository, completion logic.
- Phase 1.4 Multi-Photo Upload: photo validation, `FirebasePhotoRepository`, photo manager controller/screen, Storage paths.
- Phase 1.5 Discovery & Search: discovery repository, filters, controller, discovery/profile detail UI, public profile model.
- Phase 1.6 Friend Requests & Connections: friend request and connection models, repository, controllers, requests/connections screens.
- Phase 1.7 Realtime Chat: conversation/message models, chat repository, conversations screen, chat screen, realtime message streams.
- Phase 1.8 Push Notifications: FCM token repository/service, background handler, Cloud Functions notification triggers.
- Phase 1.9 Blocking & Reporting: safety repository, block/report domain, report sheet, profile safety menu, Firestore rules.
- Phase 2.0 Verification System: verification request model/repository/controller/screen, verification Storage path, verification Firestore rules, verified badge.

## Feature Inventory

### Authentication

- Firebase phone authentication.
- OTP send/resend/confirm flow.
- Auto-verification callback support.
- Creates public `users/{uid}` and private `users/{uid}/private/data`.
- Auth state stream drives routing.

### Profile and onboarding

- Multi-step onboarding draft.
- Required basics, preferences, location, bio.
- Age calculation and under-18 validation in app logic.
- Public profile document stored in `users/{uid}`.
- Onboarding completion gates access to main app.

### Photos

- Image picker integration.
- Client validation for extension, MIME type, size, dimensions, and max photo count.
- Firebase Storage upload path: `users/{uid}/photos/{photoId}`.
- Photo metadata embedded in public user document.
- Primary photo and reorder support.

### Discovery

- Firestore query over completed, active users with age range.
- Pagination through Firestore document cursor.
- Client-side filters for gender, interested-in, city/state, self-exclusion, and blocks.
- Public profile detail route and provider.

### Connections

- Directional request IDs: `fromUid_toUid`.
- Symmetric connection IDs: sorted pair.
- Request states: pending, accepted, rejected, cancelled.
- Accepting a request creates a connection and a conversation in a batch.
- Incoming request stream and paginated accepted connections.

### Chat

- Conversation IDs align with connection IDs.
- Realtime conversation list ordered by last activity.
- Realtime messages ordered newest-first with growing stream window for older messages.
- Send message updates message subcollection and conversation summary.

### Notifications

- FCM permission and token registration on auth state.
- Device tokens stored under `users/{uid}/deviceTokens/{token}`.
- Foreground notifications displayed as SnackBars.
- Cloud Functions send push notifications for new friend requests, accepted requests, and new messages.
- Invalid/stale FCM tokens are pruned.

### Safety

- Blocks stored in `blocks/{blockerUid}_{blockedUid}`.
- `blockedUidsProvider` combines outgoing and incoming block docs.
- Discovery filters blocked users client-side.
- Message rules prevent messaging when a block exists.
- Reports are user-write-only in client security rules.

### Verification

- User submits a verification selfie from gallery.
- Verification selfie stored at `users/{uid}/verification/{uid}`.
- Request stored at `verificationRequests/{uid}`.
- Public profile reflects pending/approved/rejected verification status.
- Admin-only approval/rejection is modeled in repository and rules.
- Shared `VerifiedBadge` widget exists.

## Firestore Collections

- `users/{uid}`: public user profile, onboarding fields, photos, account state, verification flags.
- `users/{uid}/private/data`: sensitive user data such as phone number.
- `users/{uid}/deviceTokens/{token}`: FCM device tokens.
- `friendRequests/{fromUid}_{toUid}`: directional friend requests.
- `connections/{sortedUidPair}`: accepted connection between two users.
- `conversations/{sortedUidPair}`: one-to-one conversation metadata.
- `conversations/{sortedUidPair}/messages/{messageId}`: chat messages.
- `blocks/{blockerUid}_{blockedUid}`: directional user block.
- `reports/{reportId}`: moderation report, user-create-only.
- `verificationRequests/{uid}`: one verification request per user.

## Firebase Services Used

- Firebase Core: app initialization.
- Firebase Auth: phone OTP authentication.
- Cloud Firestore: user profiles, requests, connections, chat, blocks, reports, verification, device tokens.
- Firebase Storage: profile photos and verification selfies.
- Firebase Cloud Messaging: push notifications.
- Firebase Cloud Functions v2: notification triggers.
- Firebase Emulator Suite: auth, Firestore, Storage, Functions, and UI configured.

## Security Model

### Current strengths

- Firestore and Storage rules are deny-by-default.
- Public profile data is separated from private phone data.
- Device tokens are owner-only in rules and read by Cloud Functions through Admin SDK.
- Identity/trust fields `uid`, `accountStatus`, and `isVerified` are protected from normal user profile updates.
- Connections and conversations are participant-scoped.
- Message creation is blocked if either participant has blocked the other.
- Reports are write-only for users.
- Verification approval/rejection requires an admin custom claim in rules.
- Storage paths are owner-scoped with image type and size constraints.

### Security gaps

- `users/{uid}` is readable by any signed-in user, including blocked users. Client-side filtering hides blocked profiles in discovery, but server-side rules do not prevent profile reads after a block.
- User profile updates are too permissive. Users cannot change `isVerified`, but they can likely alter fields such as `age`, `verificationStatus`, `verifiedAt`, or other undeclared public profile fields through direct client writes unless rules are tightened.
- User-created `verificationRequests/{uid}` writes only require `uid == requestId` and `status == pending`; field allowlists, state transitions, and immutable review fields are not enforced.
- Report creation rules do not validate category, status, description length, or allowed fields.
- Chat message rules do not validate message text type, length, or allowed fields.
- Friend request, connection, conversation, block, and report rules generally check identities and state, but not full schema/field allowlists.
- Admin custom claim dependency is present, but no admin user provisioning or admin dashboard/workflow is implemented.
- There are no Firebase emulator security-rule tests in the repo.

## Technical Debt

- Generated Riverpod files are committed and need a consistent regeneration process in CI.
- Some comments render with mojibake characters, suggesting encoding drift in text files.
- `debugLogDiagnostics: true` is always enabled in GoRouter; production builds should make this environment-gated.
- Many controllers catch broad errors and convert them to generic messages, which is user-friendly but weak for diagnostics unless structured logging is added around failures.
- `backend/firestore/README.md` still says no rules are written, which is stale relative to the actual rules files.
- `backend/functions/README.md` references future callable functions such as verification approval, but `src/index.ts` currently only implements push notification triggers.
- Notification service requests notification permission during bootstrap, before a user action in the app flow.
- Profile age is derived client-side and stored as a mutable field; this is convenient but weak for trust and drift over time.

## Potential Bugs

- Users can potentially manipulate discovery-relevant public fields such as `age`, `onboardingComplete`, or `verificationStatus` through direct Firestore writes because update rules do not validate allowed keys or value constraints beyond `uid`, `accountStatus`, and `isVerified`.
- Verification request resubmission can overwrite a request as `pending` without strict state-transition rules; this may allow confusing or stale review metadata.
- `NotificationService.dispose()` is not wired to the root `ProviderContainer` lifecycle, so foreground/token-refresh listeners are long-lived for the process.
- Discovery applies several filters client-side after fetching pages. If many candidates are filtered out, a user can see empty/short pages even while matching profiles exist later.
- Discovery block filtering depends on `blockedUidsProvider.value`; before the block stream resolves, the initial fetch can include blocked users.
- Chat send failures are swallowed in `ChatController.send`, so the UI may clear the sending state without surfacing failed sends.
- Push notifications include message text in the FCM notification body, which can expose private content on lock screens.
- Photo deletion removes Firestore metadata first and Storage blob second; if Storage deletion fails, orphan files remain with no cleanup process.

## Missing Tests

Existing tests cover routing guards, environment config, domain parsing, profile completion, photo validation, discovery filters, public profile mapping, connection IDs, conversation IDs, safety report models, and verification request models.

Important missing coverage:

- Firestore security rule tests for every collection and state transition.
- Storage rule tests for photo and verification paths.
- Repository integration tests against the Firebase Emulator Suite.
- OTP controller tests with mocked auth repository callbacks.
- Onboarding controller tests for draft save/submit behavior.
- Photo repository/controller tests for upload, rollback, reorder, delete, and max-photo race behavior.
- Discovery controller tests for pagination, block filtering, dedupe, and client-side filter exhaustion.
- Connection repository tests for request lifecycle and accept batch behavior.
- Chat repository/controller tests for realtime streams, send failure handling, and blocked messaging.
- Cloud Functions tests for notification triggers, token pruning, and malformed document data.
- Verification repository/controller tests for submit/approve/reject state transitions.
- End-to-end smoke tests for auth-to-onboarding-to-discovery-to-chat flows.

## Performance Concerns

- Discovery uses age filtering server-side but gender, interested-in, city/state, self-exclusion, and block filtering client-side. This increases reads and may scale poorly.
- `DiscoveryController` may fetch up to five Firestore pages per fetch attempt when filters eliminate results.
- User profile documents contain photo metadata and are readable by all signed-in users; large embedded photo arrays increase read payload size.
- Chat pagination grows the realtime query limit instead of using cursor-based historical page fetches, which can re-stream increasingly large windows.
- Blocked UID streams perform two live queries per user.
- Functions send to all tokens for a user in a single multicast call; this is fine now but needs batching if token counts grow.

## Scalability Concerns

- Discovery needs a more scalable matching/indexing strategy before large user counts: server-side filters, geohash/city indexes, preference indexes, and possibly Cloud Functions-generated discovery documents.
- Firestore rules use `exists/get` calls for block and relationship checks; these add rule evaluation cost and complexity.
- One public `users` document carries both editable profile fields and trust/moderation fields; separating public profile, private profile, and server-managed trust state would reduce rule complexity.
- Moderation and verification depend on admin claims but lack operational tooling, audit logs, queues, SLAs, or reviewer assignment.
- No production/staging Firebase project mapping is committed beyond the dev project alias.
- No CI workflow currently proves analyze/test/build/rules/functions on every push.

## Production Readiness Assessment

Current status: functional prototype / pre-production alpha.

The app has the core product surface implemented and the Firebase backend is meaningfully structured. However, it should not be treated as production-ready until the following are addressed:

- Harden Firestore and Storage rules with schema allowlists, value validation, and state-transition validation.
- Add emulator-backed security and repository integration tests.
- Add production/staging environment configuration and deployment checks.
- Add admin/moderation tooling for reports, blocked/abusive accounts, and verification review.
- Add CI for Flutter analyze, Flutter tests, Functions build/tests, and Firebase rules tests.
- Add observability around auth, uploads, chat sends, notifications, rules-denied failures, and moderation workflows.
- Rework discovery for server-side filtering and privacy-aware matching.
- Add privacy controls around push notification message content.

## Recommended Next Phase

Recommended next phase: Phase 2.1 Production Hardening, Security Rules, and Test Infrastructure.

Scope:

- Add Firestore and Storage emulator test suites.
- Tighten rules with field allowlists, immutable server-managed fields, type checks, size limits, and state-machine checks.
- Add Functions tests and implement/admin-protect verification review callables if admin UI is not ready.
- Add CI for Flutter analyze/test/build and backend Functions/rules checks.
- Split or formalize server-managed trust/moderation fields.
- Gate debug-only logging and diagnostics by environment.
- Define staging/prod Firebase project configuration and deployment runbooks.

This phase should come before building more product features because the current implementation has enough surface area that security and integration drift will become expensive if not locked down now.
