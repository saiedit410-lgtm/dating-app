# `backend/firestore/` — Security Rules & Indexes

Holds the source-of-truth for Firestore access control and composite indexes.
**No rules written yet** — drafted in Phase 1/2.

Planned files:

- `firestore.rules` — Declarative security rules (see [SecurityRequirements.md](../../docs/SecurityRequirements.md))
- `firestore.indexes.json` — Composite indexes for discovery/chat queries
- `storage.rules` — Cloud Storage access control for profile/verification photos

The canonical data model lives in [DatabaseSchema.md](../../docs/DatabaseSchema.md).
