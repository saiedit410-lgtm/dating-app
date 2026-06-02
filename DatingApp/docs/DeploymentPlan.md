# Deployment Plan

Environments, CI/CD, release process, and operations — biased toward **free tooling**
and the **Firebase Emulator Suite** so development costs ~$0 and releases are repeatable.

---

## 1. Environments

| Env | Firebase project | Flutter flavor | Purpose |
|-----|------------------|----------------|---------|
| **Local** | Emulator Suite | `dev` | Day-to-day dev; no cloud cost |
| **Dev** | `spark-dev` | `dev` | Shared integration |
| **Staging** | `spark-staging` | `staging` | Pre-release QA, closed testing |
| **Prod** | `spark-prod` | `prod` | Play Store production |

Each flavor ships its own `firebase_options.dart` / `google-services.json` and app id
suffix (`.dev`, `.staging`) so all three can co-exist on a device.

## 2. Local development — Emulator Suite (default)

Run Auth + Firestore + Functions + Storage locally:
```
firebase emulators:start --import=./.emulator-data --export-on-exit
```
- **Zero cost**, offline, safe (never touches prod).
- Seed via `scripts/seed_emulator.*`.
- Rules + Functions tested here before any deploy.

## 3. Source control & branching

- **`main`** = always releasable; protected (required review + green CI).
- Short-lived **feature branches** → PR → squash merge.
- **Tags** `vX.Y.Z` trigger release builds.
- Conventional commits → generated changelog.

## 4. CI (GitHub Actions, on every PR)

`.github/workflows/ci.yml`:
1. `flutter pub get`, `dart format --set-exit-if-changed`, `flutter analyze`.
2. `flutter test` (unit + widget).
3. **Firestore rules tests** on the emulator (security gate).
4. Functions: `npm ci`, `eslint`, `tsc`, `npm test`.

GitHub Actions free tier covers this (2,000 min/mo private; unlimited public).

## 5. CD (on merge to `main` / on tag)

| Target | Trigger | Action |
|--------|---------|--------|
| **Rules + indexes** | merge to `main` | `firebase deploy --only firestore:rules,firestore:indexes,storage` (staging → prod gated) |
| **Cloud Functions** | merge to `main` | `firebase deploy --only functions` |
| **Admin dashboard** | merge to `main` | build Flutter Web → `firebase deploy --only hosting` |
| **Android app** | tag `vX.Y.Z` | build signed **AAB** → upload artifact / Play track |

Deploys use a **CI service account** (least-privilege) stored in GitHub Secrets — never
in the repo.

## 6. Android release process (Play Store)

1. Bump version (`pubspec.yaml` `version: x.y.z+build`).
2. `flutter build appbundle --flavor prod --release` → **signed AAB**
   (upload key in CI secrets / Play App Signing enabled).
3. Upload to Play Console **internal testing** → **closed (beta)** → **production**
   (staged rollout %).
4. Required before public listing: privacy policy URL, data-safety form, content rating
   (mature/dating), in-app reporting & blocking (already in MVP), target API level.

> **Why staged rollout?** Catch crashes/regressions on a small % before full release;
> halt rollout if crash-free dips below the 99% target.

## 7. Firebase deploy targets & ordering

Deploy order matters: **rules/indexes → functions → app**, so the backend is ready
before clients depend on it. Indexes can take minutes to build — deploy ahead of the
queries that need them.

## 8. Secrets & config

- App-signing keys, service accounts, Functions config → **GitHub Secrets** /
  `firebase functions:config`. None committed.
- `.gitignore` excludes keystores, `google-services.json` for prod (injected in CI),
  local emulator data, and build artifacts.

## 9. Rollback

- **App:** halt Play staged rollout; previous AAB remains live.
- **Functions:** `firebase functions:delete`/redeploy previous, or re-deploy prior tag.
- **Rules:** re-deploy previous `firestore.rules` from git history (fast revert).
- **Feature-level:** **Remote Config kill-switches** disable a feature instantly without
  a redeploy.

## 10. Monitoring & ops

- **Crashlytics** (crash-free %), **Analytics** (funnels), **Functions logs** + error alerts.
- **Budget alerts** on the prod Firebase project (cost-drain guard).
- Uptime/health via Firebase Status + alerting on Functions error rate.

## 11. Cost summary

- **Build phase:** emulators → effectively **$0**.
- **Prod:** Blaze pay-as-you-go; free quotas cover low traffic. Main variable costs:
  **SMS OTP** and Firestore reads — both rate-limited and capped, with budget alerts.
  See [FirebaseArchitecture.md §8](FirebaseArchitecture.md#8-cost--free-tier-strategy).
