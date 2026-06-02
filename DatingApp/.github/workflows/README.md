# `.github/workflows/` — CI/CD Pipelines

GitHub Actions workflows. **No workflows yet** — added in Phase 1 (CI) and Phase 5
(CD). See [DeploymentPlan.md](../../docs/DeploymentPlan.md).

Planned workflows:

- `ci.yml` — On PR: `flutter analyze`, `flutter test`, format check, functions lint.
- `build-android.yml` — On tag: build signed AAB, upload artifact.
- `deploy-functions.yml` — On `main`: deploy Cloud Functions + rules.
- `deploy-hosting.yml` — On `main`: deploy admin dashboard to Firebase Hosting.

GitHub Actions free tier: 2,000 minutes/month on private repos, unlimited on public.
