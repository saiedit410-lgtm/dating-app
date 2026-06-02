# Firebase Architecture

How the backend is assembled from Firebase managed services, why each was chosen, and
how we stay on the **free / minimal-cost** path for the MVP.

---

## 1. Why Firebase (Backend-as-a-Service)

A small team should not run servers. Firebase gives us auth, database, storage,
serverless compute, push, hosting, and analytics behind one SDK with built-in
client-side **security rules** and **offline support**. This lets us ship the MVP
without provisioning or operating infrastructure, and scale managed.

**Trade-off considered:** a custom Node/Go API on Cloud Run would give more control
and avoid vendor lock-in, but adds DevOps load (DB ops, scaling, auth) we can't afford
pre-funding. We accept Firebase lock-in for MVP velocity; the Flutter
**repository/data-source layer** ([FlutterArchitecture.md](FlutterArchitecture.md))
isolates Firebase so a later migration is contained.

---

## 2. Service map

```
                         ┌─────────────────────────────┐
        Flutter (Android)│         Client app          │
                         └──────────────┬──────────────┘
                                        │ Firebase SDK
        ┌───────────────┬───────────────┼───────────────┬───────────────┐
        ▼               ▼               ▼               ▼               ▼
  Firebase Auth   Cloud Firestore  Cloud Storage   Cloud Functions      FCM
  (phone OTP)     (data model)     (photos)        (trusted logic)  (push notif)
        │               │               │               │               │
        └───────────────┴──────┬────────┴───────────────┘               │
                               ▼                                         │
                      Firebase Hosting ◄──── Admin Dashboard ────────────┘
                      (admin web app)
                               │
                               ▼
                     Firebase Analytics + Crashlytics (telemetry)
```

| Service | Role | Notes |
|---------|------|-------|
| **Firebase Auth** | Phone-number OTP login, sessions, custom claims (`admin`) | No passwords to store |
| **Cloud Firestore** | Primary database | Schema in [DatabaseSchema.md](DatabaseSchema.md) |
| **Cloud Storage** | Profile photos, verification selfies | Path-scoped rules |
| **Cloud Functions** | Trusted server logic & triggers | Validation, moderation, push |
| **Cloud Messaging (FCM)** | Push notifications | Requests, accepts, messages |
| **Firebase Hosting** | Admin dashboard hosting | Free tier sufficient |
| **Crashlytics + Analytics** | Stability & product metrics | Free |
| **Remote Config** | Feature flags / kill-switches | Free; toggle MVP features |
| **App Check** | Block non-app/abusive clients | Play Integrity provider |

---

## 3. Authentication design

- **Provider:** Phone (SMS OTP) as primary; email optional secondary.
- **Custom claims:** `admin: true` set via a privileged script/function for moderators;
  gate the admin dashboard and admin-only Functions on this claim.
- **Session:** SDK persists tokens; refresh handled automatically. Logout clears local
  state + removes the device FCM token from `users/{uid}/private`.
- **App Check** enforced on Firestore/Functions in production to stop scripted abuse of
  the (costly) SMS and write paths.

## 4. Compute: Cloud Functions (when & why)

Client SDKs can read/write Firestore directly under security rules — so we use
Functions **only where the client cannot be trusted** or where we need server authority:

- **Validation that rules can't express cheaply** (e.g. preventing duplicate/abusive
  friend requests, cross-doc invariants).
- **Privileged transitions:** `approveVerification`, suspend/ban, set `isVerified`.
- **Fan-out & denormalization:** `onMessageCreate` → chat summary + FCM push.
- **Moderation automation:** `onReportThreshold` → auto-flag.
- **Lifecycle:** `onUserCreate` seeds the user doc.

Full list in [backend/functions/README.md](../backend/functions/README.md) and
[API_Specification.md](API_Specification.md). Runtime: **Node.js + TypeScript** (typed,
testable, same language as admin tooling).

## 5. Storage layout

```
users/{uid}/photos/{photoId}.jpg        # profile photos (readable to authed users)
verifications/{uid}/{ts}.jpg            # selfies (private: owner + admin only)
chat/{chatId}/{messageId}.jpg          # image messages (connected users only)
```
Rules enforce owner-on-write, size/content-type limits, and read scope. Images are
client-compressed before upload to save bandwidth/quota.

## 6. Push notifications (FCM)

Tokens stored in `users/{uid}/private.fcmTokens`. Functions send targeted pushes for
friend request / accept / new message. Notification preferences (P1) gate sends.

## 7. Environments & project structure

Three Firebase projects (cost-free to create) for isolation:

| Env | Project | Use |
|-----|---------|-----|
| **dev** | `spark-dev` | Local + emulator + daily dev |
| **staging** | `spark-staging` | Pre-release QA, internal testing |
| **prod** | `spark-prod` | Play Store production |

Flutter **flavors** + `firebase_options.dart` per env select the project at build time.
Local development uses the **Firebase Emulator Suite** (Auth, Firestore, Functions,
Storage) — zero cost, fast, safe. See [DeploymentPlan.md](DeploymentPlan.md).

---

## 8. Cost & Free-Tier Strategy

**Spark (free) plan limits** comfortably cover early development:
- Firestore: 50K reads, 20K writes, 20K deletes/day; 1 GiB stored.
- Storage: 5 GB stored, 1 GB/day download.
- Hosting: 10 GB stored, 360 MB/day transfer.
- Auth: unlimited (phone SMS has its own quota/cost).

**Cloud Functions require the Blaze plan**, but Blaze includes the same free quotas and
only bills past them (2M function invocations/month free). Practical strategy:

1. **Develop entirely on emulators** → no cloud cost during build-out.
2. Move to **Blaze** only when deploying Functions; set a **budget alert** (e.g. ₹/$5).
3. **Minimize reads:** denormalize hot data (chat summaries, counts); cache the user's
   own blocks/connections client-side; paginate discovery.
4. **Control SMS cost:** the biggest variable cost is OTP SMS — add per-phone/per-IP
   **rate limiting** (App Check + Functions) and a daily cap.
5. **Compress images** client-side to stay within Storage bandwidth.
6. **Avoid expensive aggregations:** maintain counters via Functions rather than
   scanning collections.

> Net: MVP development is effectively **$0**; production cost scales with SMS + reads,
> both of which we actively cap. Budget alerts prevent surprises.

## 9. Observability

- **Crashlytics** — crash-free metric (PRD success metric).
- **Analytics** — funnel events: `otp_started`, `otp_completed`, `onboarding_done`,
  `request_sent`, `connection_made`, `message_sent`.
- **Cloud Functions logs** + alerts on error rate.

## 10. Scalability path (post-MVP)

- Shard hot counters; add Firestore **bundles**/caching for discovery.
- Introduce a recommendation service (Cloud Run) reading Firestore for AI matching.
- Add a search service (Algolia/Typesense free tier) if discovery filtering outgrows
  Firestore query limits.
- Region expansion → multi-region Firestore + CDN for Storage.
