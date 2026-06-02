# Security & Privacy Requirements

Security and privacy are **product features** for a dating app — they directly drive
trust (a PRD success metric). This document defines the controls across auth, data,
rules, abuse prevention, and privacy/compliance.

---

## 1. Threat model (top risks)

| Threat | Vector | Control |
|--------|--------|---------|
| Account takeover | OTP interception/SIM swap | Short OTP TTL, attempt lockout, re-auth for sensitive ops |
| Fake/catfish profiles | Easy signup | Verification badge, report thresholds, phone uniqueness |
| Stalking | Exact location exposure | Coarse geo only; exact coords never client-readable |
| Harassment | Unsolicited contact | Connect-before-chat, block, report |
| Data scraping | Bulk profile reads | App Check, pagination, query limits, rate limits |
| Privilege escalation | Client tampering | Server-set claims/flags; privileged ops in Functions |
| PII leakage | Over-broad reads | Private subcollection + strict rules |
| Cost-drain abuse | Spamming SMS/writes | Rate limiting, App Check, budget alerts |

---

## 2. Authentication & session

- **Phone OTP** via Firebase Auth; **no passwords stored**.
- **18+ gate** at onboarding (DOB); underage reports → ban.
- **OTP hardening:** limited attempts, resend cooldown, lockout after repeated failures.
- **Custom claims** (`admin`) are the **only** source of admin authority — never a
  client-writable field.
- **Re-authentication** required for account deletion and (future) phone change.
- **Logout** removes the device FCM token.

## 3. Authorization — Firestore Security Rules (design)

Principles: **deny by default**, validate on **write**, scope on **read**, never trust
client-supplied identity/flags.

Representative rules (final source lives in `backend/firestore/firestore.rules`):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {

    function isSignedIn() { return request.auth != null; }
    function isOwner(uid) { return isSignedIn() && request.auth.uid == uid; }
    function isAdmin() { return isSignedIn() && request.auth.token.admin == true; }
    function isActive(uid) {
      return get(/databases/$(db)/documents/users/$(uid)).data.accountStatus == 'active';
    }

    // PROFILES: readable to signed-in users; writable only by owner; flags locked.
    match /users/{uid} {
      allow read: if isSignedIn();
      allow create: if isOwner(uid);
      allow update: if isOwner(uid)
        // owner cannot self-grant trust/status
        && request.resource.data.isVerified == resource.data.isVerified
        && request.resource.data.accountStatus == resource.data.accountStatus;
      allow delete: if false;          // deletion via Function only

      // PRIVATE: phone, exact geo, tokens — owner or admin only.
      match /private/{doc} {
        allow read, write: if isOwner(uid) || isAdmin();
      }
    }

    // FRIEND REQUESTS: created via Function; recipient can read.
    match /friendRequests/{id} {
      allow read: if isSignedIn() &&
        (resource.data.fromUid == request.auth.uid ||
         resource.data.toUid   == request.auth.uid);
      allow write: if false;           // only Cloud Functions
    }

    // CONNECTIONS: members read; writes via Function.
    match /connections/{id} {
      allow read: if isSignedIn() && request.auth.uid in resource.data.users;
      allow write: if false;
    }

    // CHAT: only members; sending requires an active connection.
    match /chats/{chatId} {
      allow read: if isSignedIn() && request.auth.uid in resource.data.users;
      allow update: if isSignedIn() && request.auth.uid in resource.data.users;

      match /messages/{msgId} {
        allow read: if isSignedIn() &&
          request.auth.uid in get(/databases/$(db)/documents/chats/$(chatId)).data.users;
        allow create: if isSignedIn()
          && request.resource.data.senderId == request.auth.uid
          && request.auth.uid in get(/databases/$(db)/documents/chats/$(chatId)).data.users
          && get(/databases/$(db)/documents/chats/$(chatId)).data.isActive == true;
        allow update, delete: if false;   // immutable; moderation via Function
      }
    }

    // BLOCKS: owner manages own blocks.
    match /blocks/{id} {
      allow read, write: if isSignedIn() && id.matches(request.auth.uid + '_.*');
    }

    // REPORTS: reporter creates; only admin reads/updates.
    match /reports/{id} {
      allow create: if isSignedIn()
        && request.resource.data.reporterUid == request.auth.uid;
      allow read, update: if isAdmin();
    }

    // ADMIN: audit log + admin-only collections.
    match /adminActions/{id} { allow read, write: if isAdmin(); }
    match /verificationRequests/{uid} {
      allow read: if isOwner(uid) || isAdmin();
      allow write: if false;            // via Function
    }
  }
}
```

> These are **design drafts** for review, not final — they must be unit-tested with the
> emulator's rules-testing library before deploy.

## 4. Storage rules (design)

```
match /b/{bucket}/o {
  match /users/{uid}/photos/{file} {
    allow read: if request.auth != null;
    allow write: if request.auth.uid == uid
      && request.resource.size < 5 * 1024 * 1024
      && request.resource.contentType.matches('image/.*');
  }
  match /verifications/{uid}/{file} {
    allow read: if request.auth.uid == uid || request.auth.token.admin == true;
    allow write: if request.auth.uid == uid
      && request.resource.size < 5 * 1024 * 1024
      && request.resource.contentType.matches('image/.*');
  }
}
```

## 5. Abuse & rate limiting

- **App Check** (Play Integrity) on Firestore/Storage/Functions in prod → blocks
  non-genuine clients and scrapers.
- **Rate limits** (Functions + counters): OTP sends/hour, friend requests/day,
  reports/day, messages/min → `resource-exhausted`.
- **Phone/device uniqueness** checks to slow mass fake-account creation.
- **Budget alerts** on the Firebase project to catch cost-drain abuse early.

## 6. Privacy & data protection

- **Data minimization:** collect only what features need; DOB stored, age denormalized.
- **Location privacy:** exact coordinates live only in the private subcollection,
  **never** readable by other users; discovery uses coarse geohash/city.
- **Consent:** explicit, revocable location permission; clear copy on what's shared.
- **PII at rest:** Firebase encrypts in transit + at rest by default.
- **Right to erasure:** `deleteAccount` Function purges user docs, photos, tokens, and
  anonymizes residual references (reports/audit keep an opaque ID for integrity).
- **Retention:** verification selfies deleted after approval/expiry; report evidence
  retained per policy then purged.

## 7. Compliance posture (MVP-appropriate)

- **GDPR/India DPDP-aware:** consent, access/erasure, minimal retention. A formal DPIA
  is scheduled before public launch.
- **Play Store policy:** dating-app + UGC requirements — in-app reporting, block,
  content moderation, and a published privacy policy are **mandatory** and present.
- **Age policy:** 18+ enforced; underage = immediate removal.

## 8. Secrets & supply chain

- No secrets in the repo; service-account keys in CI secrets / Functions config only.
- `firebase_options.dart` (API keys) are not secrets but are gated by App Check + rules.
- Dependabot/`flutter pub outdated` + `npm audit` for dependency hygiene.
- Branch protection + required review on `main`.

## 9. Security testing & review gates

- Security-rules **unit tests** (emulator) are a CI gate.
- Manual rules review before each deploy.
- Pre-launch: penetration-style review of auth, rules, and Functions authorization.
- Crashlytics + Functions error monitoring for anomaly detection.

## 10. Incident response (lightweight)

- **Kill-switches** via Remote Config (disable signups/chat/discovery).
- Documented escalation: detect → contain (disable feature / suspend accounts) →
  eradicate → notify affected users if PII impacted → post-mortem.
