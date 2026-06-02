# `backend/functions/` — Firebase Cloud Functions (TypeScript)

Server-side trusted logic that must **not** run on the client. **No code yet** —
populated in Phase 2 of the [Development Roadmap](../../docs/DevelopmentRoadmap.md).

## Planned callable / triggered functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `onUserCreate` | Auth `onCreate` | Seed `users/{uid}` doc, default flags |
| `submitVerification` | HTTPS callable | Accept verification selfie, queue review |
| `approveVerification` | HTTPS callable (admin) | Set `isVerified = true` |
| `sendFriendRequest` | HTTPS callable | Validate + write request, push notify |
| `respondFriendRequest` | HTTPS callable | Accept/reject, create `connections` doc |
| `onMessageCreate` | Firestore `onCreate` | Update `chats` summary, FCM push |
| `blockUser` | HTTPS callable | Write block, tear down chat/connection |
| `submitReport` | HTTPS callable | Write report, auto-flag on threshold |
| `onReportThreshold` | Firestore trigger | Auto-suspend on N reports |
| `recomputeGeohash` | HTTPS callable | Update geohash on location change |

> **Why Cloud Functions?** Friend-request validation, verification approval,
> report auto-moderation, and block tear-down require authority the client cannot
> be trusted with. See [SecurityRequirements.md](../../docs/SecurityRequirements.md).

**Free-tier note:** Cloud Functions require the Blaze (pay-as-you-go) plan, but the
free monthly quota (2M invocations) covers MVP traffic at ~zero cost. See
[FirebaseArchitecture.md](../../docs/FirebaseArchitecture.md#8-cost--free-tier-strategy).
