# Product Requirements Document (PRD)

**Product:** (working title) **Spark** — an Android-first dating & social-connection app
**Owner:** CTO / Lead Developer
**Status:** Draft v1.0 — MVP definition
**Last updated:** 2026-06-03

---

## 1. Vision

A trust-first dating app for emerging markets where **mobile-number OTP login**,
**profile verification**, and **proximity-based discovery** lower the barrier to
joining while keeping the community safe. We launch **Android-first** because Android
dominates our target markets and lets us iterate on a single platform before
investing in iOS.

## 2. Problem Statement

Mainstream dating apps suffer from (a) fake profiles and catfishing, (b) poor safety
tooling, and (c) friction-heavy onboarding (email/password, paywalls). We solve this
with verified profiles, strong blocking/reporting, and frictionless OTP onboarding,
shipped on a **zero-to-low-cost Firebase free-tier** foundation so the startup can
validate the market before raising capital.

## 3. Goals & Non-Goals

### Goals (MVP)
- Frictionless **OTP-based** sign-up/login (no passwords).
- Rich, **photo-first user profiles** (multiple photos).
- **Verified profile** badge to build trust.
- **Discovery** of nearby users + **city/state** filtering.
- **Friend-request** model (send / accept / reject) rather than swipe-only.
- **Real-time 1:1 chat** between connected users.
- **Safety:** block users + report users/content.
- **Admin dashboard** for moderation, verification review, and report triage.

### Non-Goals (MVP — deferred)
- AI matchmaking / recommendation engine.
- Video profiles & live video calls.
- Face-recognition verification (manual review only in MVP).
- Premium subscriptions / payments.
- iOS client.
- Group chat.

## 4. Target Users & Personas

| Persona | Description | Key needs |
|---------|-------------|-----------|
| **Aanya, 24** | Young professional, safety-conscious | Verified matches, easy blocking |
| **Rahul, 28** | New to a city | Nearby discovery, city filter |
| **Mod (internal)** | Trust & Safety operator | Fast report triage, verification queue |

## 5. MVP Feature Requirements

Each requirement has a priority: **P0** (must ship), **P1** (should ship), **P2** (nice-to-have).

### 5.1 Authentication & Onboarding
- **P0** Phone-number **OTP login** via Firebase Auth (SMS).
- **P0** Auto-create user record on first login.
- **P0** Mandatory onboarding: name, date of birth (18+ gate), gender, location consent.
- **P1** Email as an alternate/secondary identifier.
- **P0** Session persistence + secure logout.

### 5.2 Profiles
- **P0** Create/edit profile: display name, bio, age (derived from DOB), gender, interests.
- **P0** **Multiple profile photos** (up to 6), stored in Firebase Storage.
- **P0** Set a primary photo.
- **P0** **Profile verification** flow (selfie → manual admin approval → verified badge).
- **P1** Profile completeness meter to nudge richer profiles.

### 5.3 Discovery
- **P0** **Nearby users** ranked by distance (geohash-based query).
- **P0** **City/state filtering**.
- **P1** Filter by age range and gender preference.
- **P2** Verified-only filter.

### 5.4 Connections (Friend Requests)
- **P0** Send a friend request to a discovered user.
- **P0** **Accept / reject** an incoming request.
- **P0** View pending (incoming/outgoing) and accepted connections.
- **P0** A chat unlocks **only after both users connect** (mutual consent).

### 5.5 Real-time Chat
- **P0** 1:1 real-time text chat between connected users (Firestore listeners).
- **P0** Message timestamps + read receipts.
- **P1** Typing indicator + image messages.
- **P0** Chat disabled/torn down when either party blocks the other.

### 5.6 Safety & Trust
- **P0** **Block** a user (removes connection, hides profiles both ways, kills chat).
- **P0** **Report** a user/message with a reason.
- **P0** Auto-flag accounts crossing a report threshold for admin review.
- **P0** **Verified badge** surfaced in discovery, profile, and chat.

### 5.7 Admin Dashboard
- **P0** Verification review queue (approve/reject selfies).
- **P0** Report triage (review, warn, suspend, ban).
- **P0** User search + account actions (suspend/ban/restore).
- **P1** Basic metrics (DAU, signups, reports/day).

### 5.8 Notifications
- **P0** Push (FCM) for: new friend request, request accepted, new message.
- **P1** Notification preferences per category.

## 6. User Stories (sample)

- *As a new user,* I can sign up with just my phone number and an OTP, so I don't manage a password.
- *As a user,* I can add up to 6 photos and get verified, so others trust my profile.
- *As a user,* I can browse nearby people and filter by my city, so I find local matches.
- *As a user,* I must connect before chatting, so I'm not spammed by strangers.
- *As a user,* I can block and report anyone, so I stay safe.
- *As a moderator,* I can review reports and verifications quickly, so the community stays clean.

## 7. Success Metrics (North-star & supporting)

| Metric | Target (first 90 days) |
|--------|------------------------|
| **North star:** mutual connections / WAU | ≥ 3 |
| OTP onboarding completion rate | ≥ 70% |
| Profile verification rate | ≥ 40% of active users |
| Median report-resolution time | < 24 h |
| Day-7 retention | ≥ 20% |
| Crash-free sessions | ≥ 99% |

## 8. Constraints & Principles

- **Cost:** stay within Firebase **free (Spark) / minimal Blaze** usage for MVP — see
  [FirebaseArchitecture.md](FirebaseArchitecture.md#8-cost--free-tier-strategy).
- **Privacy by default:** precise location never exposed to other users; only
  approximate distance/city. See [SecurityRequirements.md](SecurityRequirements.md).
- **Safety first:** every social surface ships with block + report from day one.
- **Android-first:** one platform, fast iteration; architecture stays
  cross-platform-ready for a later iOS launch.

## 9. Assumptions & Risks

| Risk | Mitigation |
|------|------------|
| SMS OTP costs at scale | Firebase free SMS quota for dev; budget Blaze SMS for prod, add rate limiting |
| Fake profiles | Manual verification + report thresholds + device/phone uniqueness |
| Location privacy backlash | Coarse location only, opt-in, clear consent copy |
| Firestore query limits (no native geo) | Geohash strategy (see schema) |
| Solo/small team velocity | Phased roadmap, free tooling, managed backend |

## 10. Release Criteria (MVP "done")

- All **P0** items implemented, tested, and behind security rules.
- Admin can verify users and resolve reports end-to-end.
- Crash-free ≥ 99% on internal testing track.
- Security rules reviewed; no client can read another user's private data.
- Play Store internal-testing release published.

See [DevelopmentRoadmap.md](DevelopmentRoadmap.md) for sequencing and
[UserFlows.md](UserFlows.md) for end-to-end flows.
