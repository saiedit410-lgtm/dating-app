# Database Schema (Cloud Firestore)

Firestore is a **NoSQL document database**. We model for the app's read patterns
(discovery, chat, requests) rather than normalizing like SQL. This document is the
**source of truth** for collections, fields, relationships, and indexes.

> **Why Firestore over Realtime Database?** Firestore gives richer queries
> (composite indexes, `in`/array-contains), better scalability, per-document
> security rules, and offline support — a better fit for discovery filtering and
> moderation than RTDB. RTDB is only marginally cheaper for tiny high-frequency
> writes; we keep chat on Firestore for query/rule consistency.

---

## Collection overview

| Collection | Doc ID | Purpose |
|------------|--------|---------|
| `users` | `{uid}` | Profile, location, flags |
| `users/{uid}/private` | `data` | Sensitive sub-doc (phone, exact geo) — restricted |
| `verificationRequests` | `{uid}` | Pending/reviewed verification requests |
| `friendRequests` | `{requestId}` | Pending/accepted/rejected requests |
| `connections` | `{connId}` | Mutual accepted connections |
| `blocks` | `{blockerUid}_{blockedUid}` | Block relationships |
| `chats` | `{chatId}` | Chat thread summary |
| `chats/{chatId}/messages` | `{messageId}` | Messages (subcollection) |
| `reports` | `{reportId}` | User/content reports |
| `adminActions` | `{actionId}` | Moderation audit log |
| `meta/counters` | various | Aggregate counters (reports, etc.) |

---

## `users/{uid}`

Publicly readable **profile** fields (to authenticated, non-blocked users). Sensitive
data lives in the `private` subcollection.

```jsonc
{
  "uid": "string",                 // == doc id
  "displayName": "string",
  "bio": "string (<= 500)",
  "gender": "male|female|nonbinary|other",
  "interestedIn": ["male","female", ...],
  "dob": "timestamp",              // used to derive age; not exposed raw
  "age": 24,                       // denormalized, recomputed by function
  "interests": ["travel","music"],
  "photos": [                      // up to 6
    { "id":"p1", "url":"https://...", "isPrimary": true, "order": 0 }
  ],
  "city": "Pune",
  "state": "Maharashtra",
  "country": "IN",
  "geohash": "tdr1y2",             // coarse (precision ~5-6) for discovery
  "geohashPrefixes": ["tdr1","tdr1y"],  // optional, for radius bucketing
  "isVerified": false,
  "verificationStatus": "none|pending|approved|rejected",
  "onboardingComplete": false,
  "accountStatus": "active|suspended|banned",
  "lastActiveAt": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### `users/{uid}/private/data` (owner + admin only)
```jsonc
{
  "phoneNumber": "+91...",
  "email": "string|null",
  "exactLat": 18.5204,             // never exposed to other users
  "exactLng": 73.8567,
  "fcmTokens": ["token1", "token2"],
  "deviceIds": ["..."]             // for abuse/uniqueness checks
}
```

> **Privacy decision:** other users can read profile + coarse `geohash`/`city`, but
> **never** exact coordinates or phone. Enforced in `firestore.rules`
> (see [SecurityRequirements.md](SecurityRequirements.md)).

---

## `verificationRequests/{uid}`
```jsonc
{
  "uid": "string",
  "selfiePath": "verifications/{uid}/{ts}.jpg",  // private Storage path
  "status": "pending|approved|rejected",
  "reviewedBy": "adminUid|null",
  "rejectionReason": "string|null",
  "createdAt": "timestamp",
  "reviewedAt": "timestamp|null"
}
```

## `friendRequests/{requestId}`
`requestId = {fromUid}_{toUid}` (deterministic → prevents duplicate requests).
```jsonc
{
  "fromUid": "string",
  "toUid": "string",
  "status": "pending|accepted|rejected|cancelled",
  "createdAt": "timestamp",
  "respondedAt": "timestamp|null"
}
```
**Indexes:** query incoming = `where toUid == me and status == 'pending'`;
outgoing = `where fromUid == me and status == 'pending'`.

## `connections/{connId}`
`connId = sorted(uidA, uidB).join('_')` → one canonical doc per pair.
```jsonc
{
  "users": ["uidA", "uidB"],       // array-contains for "my connections"
  "createdAt": "timestamp",
  "chatId": "string"               // == connId for simplicity
}
```
**Index:** `where users array-contains me`.

## `blocks/{blockerUid}_{blockedUid}`
```jsonc
{ "blocker": "uid", "blocked": "uid", "createdAt": "timestamp" }
```
Two-way checks done by querying both `me_*` and `*_me`. Discovery/query results are
filtered client-side against the user's block set (loaded once, cached).

## `chats/{chatId}`  (chatId == connId)
```jsonc
{
  "users": ["uidA", "uidB"],
  "lastMessage": { "text":"…", "senderId":"uid", "createdAt":"timestamp" },
  "unread": { "uidA": 0, "uidB": 3 },
  "isActive": true,               // false after a block
  "updatedAt": "timestamp"
}
```

### `chats/{chatId}/messages/{messageId}`
```jsonc
{
  "senderId": "uid",
  "type": "text|image",
  "text": "string|null",
  "imageUrl": "string|null",
  "createdAt": "timestamp",
  "readBy": ["uid", ...]
}
```
**Index:** `messages order by createdAt asc` (default single-field is enough).

## `reports/{reportId}`
```jsonc
{
  "reporterUid": "uid",
  "targetType": "user|message",
  "targetUid": "uid",
  "targetRef": "chats/{chatId}/messages/{msgId}|null",
  "reason": "spam|harassment|fake|nudity|underage|other",
  "details": "string|null",
  "status": "open|under_review|actioned|dismissed",
  "createdAt": "timestamp",
  "resolvedBy": "adminUid|null",
  "resolution": "warn|suspend|ban|dismiss|null"
}
```

## `adminActions/{actionId}` (audit log, admin-only read)
```jsonc
{
  "adminUid": "uid",
  "action": "approve_verification|reject_verification|suspend|ban|restore|dismiss_report",
  "targetUid": "uid",
  "relatedRef": "reports/{id}|verificationRequests/{uid}|null",
  "note": "string|null",
  "createdAt": "timestamp"
}
```

---

## Relationships (entity map)

```
users 1──* photos (embedded array)
users 1──1 users/{uid}/private/data
users 1──* friendRequests (from/to)
users *──* connections (via users[] array)
connections 1──1 chats ──* messages
users *──* blocks
users 1──* reports (as reporter and as target)
admins 1──* adminActions / verificationRequests / reports (review)
```

---

## Geo-query strategy (why geohash)

Firestore has **no native geospatial query**. Standard approach:
1. Store a **geohash** (e.g. via the `geoflutterfire`/`geoflutterfire_plus` package).
2. For a radius search, compute the set of geohash prefix ranges covering it.
3. Issue range queries per prefix, then **filter precisely client-side** by Haversine
   distance using the (private) exact coords — or, for privacy, by the coarse center.

We pair geohash with **city/state equality filters** so the common "people in my city"
query is a cheap indexed equality lookup, and radius search is the richer path.

---

## Required composite indexes (`firestore.indexes.json`)

| Collection | Fields | Used by |
|------------|--------|---------|
| `users` | `city ASC, isVerified DESC, lastActiveAt DESC` | City discovery, verified-first |
| `users` | `geohash ASC, gender ASC` | Nearby + gender filter |
| `friendRequests` | `toUid ASC, status ASC, createdAt DESC` | Incoming requests |
| `friendRequests` | `fromUid ASC, status ASC` | Outgoing requests |
| `reports` | `status ASC, createdAt DESC` | Admin report queue |
| `verificationRequests` | `status ASC, createdAt ASC` | Admin verification queue (FIFO) |

> Single-field indexes are auto-created. Composite indexes above must be declared and
> deployed (`firebase deploy --only firestore:indexes`).

---

## Denormalization & counters

- `age`, `chats.lastMessage`, `chats.unread` are **denormalized** for cheap reads,
  maintained by Cloud Functions — Firestore bills per document read, so we avoid
  fan-out reads on hot paths.
- Aggregate counts (e.g. report counts per target) use a counter doc / function rather
  than `count()` on every load, to control cost.

See [FirebaseArchitecture.md](FirebaseArchitecture.md) for how these collections map to
Functions, Storage, and free-tier limits.
