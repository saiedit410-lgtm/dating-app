# API Specification

The app uses two interaction styles:

1. **Direct SDK access** to Firestore/Storage/Auth from the client, governed by
   **security rules** (most reads + simple writes).
2. **Cloud Functions** (HTTPS-callable + triggers) for trusted/privileged operations.

This document specifies the Cloud Functions "API" (callables) and the conventions for
direct-SDK collection access. Data shapes reference
[DatabaseSchema.md](DatabaseSchema.md).

---

## Conventions

- **Callable functions** are invoked via the Firebase SDK (`httpsCallable`), authed by
  the caller's ID token. No REST URLs to manage; auth is automatic.
- **Auth required:** every callable rejects unauthenticated calls (`unauthenticated`).
- **Errors** use Firebase `HttpsError` codes: `unauthenticated`, `permission-denied`,
  `invalid-argument`, `failed-precondition`, `already-exists`, `not-found`,
  `resource-exhausted` (rate limit), `internal`.
- **App Check** required in production on all callables.
- **Idempotency:** deterministic doc IDs (e.g. `friendRequests/{from}_{to}`) make
  retries safe.

---

## 1. Authentication
Handled by the **Firebase Auth SDK** (no custom functions):

| Operation | SDK call |
|-----------|----------|
| Send OTP | `verifyPhoneNumber(phoneNumber, callbacks)` |
| Verify OTP | `signInWithCredential(PhoneAuthProvider.credential(...))` |
| Sign out | `signOut()` |
| Current user | `authStateChanges()` stream |

Trigger: **`onUserCreate`** (Auth `onCreate`) → seeds `users/{uid}` and
`users/{uid}/private/data`.

---

## 2. Profile & Photos (direct SDK + Storage)

| Operation | Mechanism | Rule summary |
|-----------|-----------|--------------|
| Read profile | `users/{uid}` get | Authed, non-blocked, account active |
| Update own profile | `users/{me}` update | Owner only; validated fields |
| Upload photo | Storage `users/{me}/photos/{id}` | Owner write; ≤ 5 MB; image/* |
| Set primary / reorder | `users/{me}.photos` update | Owner only |
| Read private data | `users/{me}/private/data` | Owner or admin only |

---

## 3. Verification

### `submitVerification` (callable)
**Request:** `{ selfieStoragePath: string }`
**Effect:** validates the selfie belongs to caller; creates/updates
`verificationRequests/{uid}` with `status:"pending"`.
**Returns:** `{ status: "pending" }`
**Errors:** `failed-precondition` (already pending/approved), `invalid-argument`.

### `approveVerification` (callable, **admin**)
**Request:** `{ uid: string, decision: "approve"|"reject", reason?: string }`
**Effect:** sets `users/{uid}.isVerified` + `verificationStatus`; writes
`adminActions`; 🔔 notifies user.
**Returns:** `{ ok: true }`
**Errors:** `permission-denied` (non-admin), `not-found`.

---

## 4. Friend Requests

### `sendFriendRequest` (callable)
**Request:** `{ toUid: string }`
**Preconditions:** not self, not blocked (either way), not already connected, no
existing pending request.
**Effect:** writes `friendRequests/{fromUid}_{toUid}` `status:"pending"`; 🔔 notifies recipient.
**Returns:** `{ requestId: string, status: "pending" }`
**Errors:** `already-exists`, `failed-precondition` (blocked/connected),
`resource-exhausted` (rate limit), `invalid-argument`.

### `respondFriendRequest` (callable)
**Request:** `{ requestId: string, action: "accept"|"reject" }`
**Auth:** caller must be `toUid`.
**Effect (accept):** request → `accepted`; create `connections/{connId}` + `chats/{chatId}`;
🔔 notify sender. **(reject):** request → `rejected` (silent).
**Returns:** `{ status: "accepted"|"rejected", connectionId?: string }`
**Errors:** `permission-denied`, `not-found`, `failed-precondition`.

### Reads (direct SDK)
- Incoming: `friendRequests where toUid == me and status == "pending"`.
- Outgoing: `friendRequests where fromUid == me and status == "pending"`.
- Connections: `connections where users array-contains me`.

---

## 5. Chat

| Operation | Mechanism | Rule summary |
|-----------|-----------|--------------|
| List chats | `chats where users array-contains me` | Member only |
| Listen to thread | `chats/{chatId}/messages orderBy createdAt` (snapshots) | Member, chat active |
| Send message | create `chats/{chatId}/messages/{id}` | Member + connection exists + not blocked |
| Mark read | update `messages.readBy` / `chats.unread[me]` | Member only |

Trigger: **`onMessageCreate`** → update `chats` summary (lastMessage, unread++) + 🔔 push.

> Send is allowed via direct SDK because security rules can fully verify membership +
> active connection. The summary/push fan-out is done server-side to keep it trusted
> and cheap.

---

## 6. Blocking

### `blockUser` (callable)
**Request:** `{ targetUid: string }`
**Effect:** writes `blocks/{me}_{target}`; deletes `connections/{connId}`; sets
`chats/{chatId}.isActive = false`. Silent to target.
**Returns:** `{ ok: true }`
**Errors:** `invalid-argument`, `not-found`.

### `unblockUser` (callable)
**Request:** `{ targetUid: string }` → deletes the block doc. Returns `{ ok: true }`.

---

## 7. Reporting

### `submitReport` (callable)
**Request:**
```jsonc
{ "targetType":"user|message", "targetUid":"uid",
  "targetRef":"chats/{chatId}/messages/{id}|null",
  "reason":"spam|harassment|fake|nudity|underage|other", "details":"string?" }
```
**Effect:** writes `reports/{reportId}`; increments target's report counter.
**Returns:** `{ reportId: string, status: "open" }`
**Errors:** `invalid-argument`, `resource-exhausted` (anti-spam on reports).

Trigger: **`onReportThreshold`** (Firestore `onWrite` of `reports`) → when distinct
reports ≥ N, set target `accountStatus`/flag → `under_review` for admin.

---

## 8. Admin (callable, **admin claim required**)

| Function | Request | Effect |
|----------|---------|--------|
| `setUserStatus` | `{ uid, status:"active\|suspended\|banned", note? }` | Update `accountStatus`; audit log |
| `resolveReport` | `{ reportId, resolution:"warn\|suspend\|ban\|dismiss", note? }` | Close report; apply action; audit |
| `listVerificationQueue` | `{ cursor? }` | Paged pending verifications |
| `listReportQueue` | `{ status?, cursor? }` | Paged reports |
| `grantAdmin` | `{ uid }` (super-admin only) | Set `admin` custom claim |

All admin functions verify `context.auth.token.admin == true`, else `permission-denied`.

---

## 9. Discovery (direct SDK, indexed query)

```
users
  where city == :city            // or geohash prefix range
  where gender in :interestedIn  // optional
  where isVerified == true        // optional (verified-only)
  orderBy lastActiveAt desc
  limit 20  (paginated)
```
Client post-filters out self, blocked, and existing connections (cached sets).
Requires composite indexes in [DatabaseSchema.md](DatabaseSchema.md).

---

## 10. Rate limiting & abuse (cross-cutting)

- OTP sends, friend requests, and reports are rate-limited (per-uid/per-IP) via App
  Check + counters in Functions → `resource-exhausted` when exceeded.
- See [SecurityRequirements.md](SecurityRequirements.md) for thresholds and rules.
