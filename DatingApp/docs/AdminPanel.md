# Admin Panel

Internal web console for **Trust & Safety**: verification review, report triage, user
management, and basic metrics. Built in Phase 4 (see
[DevelopmentRoadmap.md](DevelopmentRoadmap.md)).

---

## 1. Goals

- Resolve verification requests and reports **fast** (PRD target: < 24 h).
- Give moderators safe, audited account actions (suspend/ban/restore).
- Surface basic health metrics.
- Cost: host on **Firebase Hosting free tier**.

## 2. Tech decision

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **Flutter Web** | Reuse models/`data` layer + entities from the app; one language | Heavier web bundle; less "web-native" | ✅ **MVP choice** — maximizes reuse for a small team |
| React + Firebase JS | Lighter, web-native, big ecosystem | Second stack/language to maintain | Reconsider if web grows complex |

We choose **Flutter Web** for the MVP to reuse the existing domain/data layer and avoid
a second toolchain. The decision is revisited if the admin surface outgrows it.

**Hosting:** Firebase Hosting. **Auth:** Firebase Auth, gated by the `admin` custom
claim (route guard + security rules + admin-only Functions).

## 3. Roles & permissions

| Role | Claim | Capabilities |
|------|-------|--------------|
| **Moderator** | `admin: true`, `role: "mod"` | Review verifications & reports; warn/suspend |
| **Admin** | `admin: true`, `role: "admin"` | All mod powers + ban/restore + user search |
| **Super-admin** | `admin: true`, `role: "super"` | Grant/revoke admin, config kill-switches |

Roles via custom claims set by `grantAdmin` (super-admin only). Every privileged action
writes to `adminActions` (audit log).

## 4. Screens

### 4.1 Login
Firebase Auth sign-in; reject accounts without the `admin` claim.

### 4.2 Dashboard (home)
Cards: pending verifications, open reports, accounts under review, today's signups,
DAU/WAU. Quick links to queues.

### 4.3 Verification Queue
- FIFO list of `verificationRequests` where `status == pending`.
- Detail view: selfie **side-by-side** with profile photos.
- Actions: **Approve** (→ `isVerified = true`) / **Reject** (reason) →
  `approveVerification`. Auto-advance to next item.

### 4.4 Reports Queue
- List `reports` by `status` (open/under_review), newest first; filter by reason.
- Detail: target profile, report reason/details, context snapshot (e.g. reported
  message), target's report history/count.
- Actions via `resolveReport`: **Warn / Suspend / Ban / Dismiss** (+ note).

### 4.5 User Search & Detail
- Search by uid/phone/displayName.
- Detail: profile, verification status, connections count, reports against, account
  status, audit trail.
- Actions via `setUserStatus`: **Suspend / Ban / Restore** (with note).

### 4.6 Audit Log
Read-only stream of `adminActions` (who did what, when) — accountability.

### 4.7 Settings (super-admin)
- Manage admins (`grantAdmin` / revoke).
- **Kill-switches** via Remote Config (disable signup/chat/discovery).

## 5. Workflows

**Verification:** queue → compare → approve/reject → user notified → audit logged.

**Report triage:** queue → review evidence → decide → action applied (status change +
optional account action) → report closed → audit logged. Auto-flagged accounts
(`onReportThreshold`) appear pre-marked `under_review`.

**Account action:** search → review → suspend/ban/restore → user's `accountStatus`
changes → rules immediately restrict suspended/banned users → audit logged.

## 6. Security

- Admin-only **Functions** verify `token.admin == true`.
- Admin-only **collections** (`reports`, `adminActions`, verification selfies) gated by
  rules ([SecurityRequirements.md](SecurityRequirements.md)).
- **All mutations audited**; admins cannot edit the audit log.
- App Check + (recommended) IP allowlist / org SSO for the Hosting site pre-GA.

## 7. Metrics (MVP)

Pull from Analytics/Firestore counters: DAU/WAU, signups/day, verification
approval rate, reports/day, median resolution time, suspensions/bans. Lightweight —
heavier BI deferred post-MVP.
