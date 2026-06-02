# Development Roadmap

Phased plan from the current **planning** state to a production MVP and beyond. Phases
are sequenced to de-risk early (auth + rules first) and keep each phase shippable to the
internal testing track. Durations assume a small team and are **estimates**, not commitments.

---

## Phase 0 — Foundation & Planning ✅ (current)

- Repo structure + planning docs (this set).
- Decisions locked: Flutter + Riverpod + GoRouter; Firebase backend; Android-first.
- **Exit:** docs reviewed and approved; structure in place.

## Phase 1 — Project & Auth Bootstrap  *(~1–2 weeks)*

- `flutter create` into `app/`; flavors (dev/staging/prod); base theme/router.
- Firebase projects (dev/staging/prod) + **Emulator Suite** wired.
- **Phone OTP** auth end-to-end; session persistence; auth/onboarding route guards.
- `onUserCreate` function; first **security rules** + rules unit tests in CI.
- CI: `analyze`, `test`, format check.
- **Exit:** user can OTP-login on a device against the emulator/dev; rules tests pass.

## Phase 2 — Profiles, Photos & Verification  *(~2 weeks)*

- Onboarding wizard (18+ gate, location consent, city/state).
- Profile CRUD; **multiple photos** (upload/crop/reorder/primary) on Storage + rules.
- Verification submit flow (`submitVerification`) + selfie storage.
- **Exit:** complete, photo-rich, verifiable profiles persisted under rules.

## Phase 3 — Discovery & Connections  *(~2 weeks)*

- Geohash on write; **nearby discovery** + **city/state** + age/gender filters.
- Friend requests: `sendFriendRequest` / `respondFriendRequest`; incoming/outgoing/
  connections screens.
- Composite indexes deployed.
- **Exit:** users discover, request, accept/reject, and form connections.

## Phase 4 — Chat, Safety & Admin  *(~2–3 weeks)*

- Real-time 1:1 **chat** (StreamProviders) + `onMessageCreate` (summary + FCM push).
- **Block** (`blockUser`) + chat tear-down; **report** (`submitReport`) +
  `onReportThreshold` auto-flag.
- **Admin dashboard** (Flutter Web): verification queue, report triage, user actions,
  audit log.
- **Exit:** end-to-end safety loop works; admin can verify users and resolve reports.

## Phase 5 — Hardening, Beta & Launch  *(~2 weeks)*

- App Check (Play Integrity) on; rate limits + budget alerts.
- Crashlytics/Analytics funnels; performance pass; accessibility pass.
- Integration tests (auth→chat) green; security-rules review.
- Play Store: listing, privacy policy, content rating, **internal/closed testing** → production.
- **Exit:** MVP live on Play Store internal/closed track meeting release criteria
  ([PRD §10](PRD.md)).

## Phase 6+ — Post-MVP (deferred features)

Prioritized backlog (from PRD non-goals):
1. Notification preferences, typing indicators, image messages.
2. **Automated face verification** (replace manual review).
3. **AI matching / recommendations** (Cloud Run service over Firestore).
4. **Premium** subscriptions / payments.
5. **iOS** client.
6. Video profiles / calls; group features.

---

## Cross-cutting tracks (every phase)

- **Security:** rules tests as a CI gate; least-privilege by default.
- **Testing:** unit + widget per feature; integration on emulator before merge.
- **Cost:** develop on emulators; budget alerts; minimize reads.
- **Docs:** keep these planning docs current as decisions evolve.

## Milestones

| Milestone | Phase | Definition |
|-----------|-------|------------|
| **M1 Auth alpha** | 1 | OTP login + rules in CI |
| **M2 Profiles** | 2 | Verifiable photo profiles |
| **M3 Social core** | 3 | Discovery + connections |
| **M4 Feature-complete MVP** | 4 | Chat + safety + admin |
| **M5 Public MVP** | 5 | Play Store launch |

## Team & critical path (note)

Auth + security rules (Phase 1) are the **critical path** — everything else depends on a
trusted identity and access model, so we build and test them first. Discovery's geohash
work is the main technical risk; spike it early in Phase 3.
