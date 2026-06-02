# `admin/` — Admin Dashboard (Web)

Internal web console for moderation, verification review, and reporting triage.
**No code yet** — built in Phase 4 of the [Development Roadmap](../docs/DevelopmentRoadmap.md).

- **Stack:** Flutter Web (code reuse) **or** lightweight React + Firebase JS SDK.
  Decision and trade-offs in [AdminPanel.md](../docs/AdminPanel.md).
- **Hosting:** Firebase Hosting (free tier: 10 GB storage, 360 MB/day transfer).
- **Access:** Restricted to accounts with the `admin` custom claim; enforced by
  both security rules and a route guard.

See [AdminPanel.md](../docs/AdminPanel.md) for screens, roles, and workflows.
