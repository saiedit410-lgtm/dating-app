# User Flows

Companion to the [PRD](PRD.md). Flows are written as step sequences with the
**system/Firebase action** noted, so they map directly onto
[FlutterArchitecture.md](FlutterArchitecture.md) screens and the
[API_Specification.md](API_Specification.md).

Legend: 📱 = client action · ☁️ = Firebase/Cloud Function · 🔔 = push notification

---

## 1. Onboarding & OTP Login

```
Splash → Phone entry → OTP entry → (new user?) Onboarding → Home
```

1. 📱 User opens app → Splash checks for an existing session.
   - If signed in **and** onboarding complete → **Home (Discovery)**.
   - Else → **Phone entry**.
2. 📱 User enters phone number (with country code) → taps *Send OTP*.
3. ☁️ `FirebaseAuth.verifyPhoneNumber` sends SMS; client receives a `verificationId`.
4. 📱 User enters the 6-digit code → client builds credential → `signInWithCredential`.
5. ☁️ Auth `onCreate` trigger (`onUserCreate`) seeds `users/{uid}` with defaults
   (`onboardingComplete: false`, `isVerified: false`).
6. 📱 If `onboardingComplete == false` → **Onboarding wizard**; else → **Home**.

**Edge cases:** wrong code (allow retry, lock after N attempts), expired code
(resend with cooldown), auto-retrieval on Android (auto-fill OTP), no-SMS fallback
(resend / call later).

## 2. Onboarding Wizard (first run)

```
Name → DOB (18+ gate) → Gender → Location consent → Add photos → Done
```

1. 📱 Collect display name, **date of birth** → reject if age < 18.
2. 📱 Collect gender + (optional) interested-in.
3. 📱 Request **location permission**; on grant, capture coarse location → derive
   `geohash`, `city`, `state` (reverse geocode). On deny → require manual city/state.
4. 📱 Prompt to add at least 1 photo (up to 6) → upload to Storage.
5. ☁️ Update `users/{uid}` with profile + `onboardingComplete: true` → **Home**.

## 3. Profile Creation & Photo Management

1. 📱 Profile tab → Edit.
2. 📱 Add photo → pick/crop → upload to `storage://users/{uid}/photos/{photoId}`.
3. ☁️ Storage rule validates owner + size + content-type → write `photoUrl` into
   `users/{uid}.photos[]`.
4. 📱 Reorder / set primary / delete photo (delete removes Storage object + array entry).
5. 📱 Edit bio, interests → save → `users/{uid}` updated (validated by rules).

## 4. Profile Verification

```
Start verification → Capture selfie → Submit → (admin review) → Verified badge
```

1. 📱 Profile → *Get Verified* → guided selfie capture (liveness pose prompt).
2. ☁️ `submitVerification` callable stores selfie at
   `storage://verifications/{uid}/{ts}.jpg` (private) and creates
   `verificationRequests/{uid}` with `status: pending`.
3. 🧑‍💻 **Admin** opens the verification queue → compares selfie to profile photos →
   approve/reject.
4. ☁️ `approveVerification` sets `users/{uid}.isVerified = true`, closes request, and
   🔔 notifies the user. Reject → status `rejected` with reason; user may retry.

> **MVP = manual review.** Automated face verification is a Phase-6 enhancement
> (see [DevelopmentRoadmap.md](DevelopmentRoadmap.md)).

## 5. Discovery (Nearby + City/State Filtering)

```
Home → (filters) → Ranked list/cards → Profile detail
```

1. 📱 Home loads default filters (current city/state, age range, gender).
2. 📱 Client computes the set of **geohash prefixes** covering the chosen radius.
3. ☁️ Firestore query: `users where geohashPrefix in [...] and city == X` (with the
   composite index from [DatabaseSchema.md](DatabaseSchema.md)).
4. 📱 Client filters/sorts remaining results by precise distance + excludes blocked,
   already-connected, and self.
5. 📱 Tap a card → **Profile detail** → *Add Friend* / *Block* / *Report*.

## 6. Friend Request (Send / Accept / Reject)

```
Profile detail → Add Friend → (recipient) Requests → Accept/Reject → Connection
```

1. 📱 Sender taps *Add Friend*.
2. ☁️ `sendFriendRequest` validates (not blocked, not already connected, no duplicate)
   → writes `friendRequests/{requestId}` (`status: pending`) → 🔔 notifies recipient.
3. 📱 Recipient sees it under **Requests (incoming)**.
4. 📱 Recipient taps **Accept** or **Reject**.
5. ☁️ `respondFriendRequest`:
   - **Accept** → request `status: accepted`, create `connections/{connId}` (both UIDs)
     → 🔔 notify sender → chat now unlocked.
   - **Reject** → request `status: rejected` (no notification, to avoid awkwardness).

## 7. Real-time Chat

```
Connections → Chat thread → Send/receive (live)
```

1. 📱 Open a connected user's chat → subscribe to
   `chats/{chatId}/messages` (ordered by `createdAt`).
2. 📱 Send message → write `messages/{msgId}` (client write allowed only if a
   `connection` exists and neither party is blocked — enforced by rules).
3. ☁️ `onMessageCreate` updates `chats/{chatId}` summary (last message, unread count)
   and 🔔 pushes to the recipient.
4. 📱 Opening the thread marks messages read (updates read receipt + unread count).

## 8. Block User

1. 📱 Profile/chat → *Block*.
2. ☁️ `blockUser` writes `blocks/{blockerUid}_{blockedUid}`, deletes any
   `connection`, and disables the `chat`.
3. 📱 Both users disappear from each other's discovery; chat becomes read-only/hidden.
   Blocking is **silent** to the blocked user.

## 9. Report User / Content

1. 📱 Profile/chat/message → *Report* → choose reason (spam, harassment, fake, nudity, other).
2. ☁️ `submitReport` writes `reports/{reportId}` with target + reason + context snapshot.
3. ☁️ `onReportThreshold` auto-flags the target (`status: under_review`) when reports ≥ N.
4. 🧑‍💻 Admin reviews → warn / suspend / ban / dismiss.

## 10. Admin Moderation (internal)

```
Admin login → Dashboard → (Verifications | Reports | Users) → Action
```

1. 🧑‍💻 Admin signs in (account with `admin` custom claim).
2. 🧑‍💻 Verification queue → approve/reject.
3. 🧑‍💻 Reports queue → review evidence → take action (warn/suspend/ban/dismiss).
4. 🧑‍💻 User search → inspect → suspend/ban/restore; actions are audit-logged.

Detailed admin screens in [AdminPanel.md](AdminPanel.md).

---

## Flow → Screen → API map (quick index)

| Flow | Primary screen | Key API (see API_Specification.md) |
|------|----------------|-------------------------------------|
| OTP login | `PhoneAuthScreen`, `OtpScreen` | Firebase Auth SDK |
| Onboarding | `OnboardingWizard` | `users` write |
| Verification | `VerifyScreen` | `submitVerification`, `approveVerification` |
| Discovery | `DiscoveryScreen` | `users` geohash query |
| Friend request | `ProfileDetail`, `RequestsScreen` | `sendFriendRequest`, `respondFriendRequest` |
| Chat | `ChatListScreen`, `ChatThreadScreen` | `chats`/`messages` listeners, `onMessageCreate` |
| Block | `ProfileDetail`, `ChatThreadScreen` | `blockUser` |
| Report | any social surface | `submitReport` |
