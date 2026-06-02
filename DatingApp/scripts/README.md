# `scripts/` — Developer & Ops Tooling

Helper scripts for local development and operations (no app logic). Examples planned:

- `seed_emulator.dart` / `.ts` — Seed the Firebase Emulator Suite with test data.
- `set_admin_claim.ts` — Grant the `admin` custom claim to a UID.
- `release.sh` — Version bump + tag + changelog.

All scripts should run against the **Firebase Emulator Suite** by default to avoid
touching production. See [DeploymentPlan.md](../docs/DeploymentPlan.md).
