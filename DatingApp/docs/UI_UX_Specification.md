# UI / UX Specification

How Spark **feels** and **behaves**: experience principles, the global navigation model,
and detailed UX for every major flow (onboarding, profile creation, discovery, chat,
safety, admin). It binds the product flows in [UserFlows.md](UserFlows.md) to concrete
screens in [ScreenInventory.md](ScreenInventory.md), styled with
[DesignSystem.md](DesignSystem.md).

Target feel: **modern, premium, calm, and trustworthy** — Android-first, Material 3
native. Safety and verification are surfaced as reassurance, never friction theatre.

---

## 1. Experience principles

1. **Earn trust on every screen** — verified badges, clear consent, visible safety tools.
2. **Frictionless entry, meaningful gates** — OTP onboarding is fast, but the 18+ gate,
   consent, and verification are deliberate and clear.
3. **Consent before contact** — no stranger can message you; connect first.
4. **Calm confidence** — generous space, soft motion, no manipulative urgency or streaks.
5. **Always recoverable** — every action is reversible or confirmable; every error has a
   next step.
6. **One primary action per screen** — clear visual hierarchy guides the user.

---

## 2. Global navigation model

### 2.1 Primary navigation — Bottom Navigation Bar (4 tabs)
| Tab | Icon | Destination | Badge |
|-----|------|-------------|-------|
| **Discover** | explore | Discovery feed (default landing) | — |
| **Requests** | person_add | Incoming/outgoing friend requests | count of incoming pending |
| **Chats** | chat_bubble | Conversations | total unread count |
| **Profile** | account_circle | My profile + entry to Settings | "!" if profile incomplete/unverified |

Rationale: a **persistent bottom bar** is the Android-native pattern for ≤5 top-level
destinations; the four map directly to the core loop (find → request → talk → manage me).

### 2.2 Navigation hierarchy
```
Splash ─► [unauth] Auth flow ─► [new] Onboarding ─► App shell (bottom nav)
                                                      ├─ Discover ─► Filters / Profile detail / Search
                                                      ├─ Requests ─► (tabs) Incoming / Outgoing
                                                      ├─ Chats ─► Chat thread ─► Image viewer
                                                      └─ Profile ─► Edit / Photos / Verification / Settings ─► …
```
- **Within-tab** navigation pushes onto that tab's stack (back returns within the tab).
- **Cross-cutting** surfaces (Report, Block, Filters) open as **bottom sheets/dialogs**,
  not full pages, to keep context.
- **Deep links** from notifications route straight to the relevant Chat thread or
  Requests tab (GoRouter — [FlutterArchitecture.md](FlutterArchitecture.md#4-navigation)).
- **Back behavior:** Android system back mirrors the in-tab stack; at a tab root it
  returns to Discover; at Discover root it confirms exit.

### 2.3 App bar
Contextual top app bar per screen: title, optional back, and ≤2 actions. Elevates
(`elev/2`) on scroll. Verified badge shown beside names wherever a user is presented.

---

## 3. Onboarding flow (UX detail)

**Goal:** get a trustworthy, photo-rich profile created in minutes, with safety framed
positively. Linear wizard with a **top progress indicator** (step n of 7) and the ability
to go **Back**; no step is skippable except where noted.

```
A1 Splash → A2 Phone → A3 OTP → B1 Welcome → B2 Name → B3 DOB(18+) →
B4 Gender → B5 Location → B6 Photos → B7 Bio/Interests → B8 Done → Discover
```

UX notes per step:
- **Phone (A2):** country auto-detected; inline validation; single Primary "Send code".
- **OTP (A3):** 6-box field with auto-advance + Android SMS auto-fill; resend disabled
  behind a 30s countdown; clear, blame-free error on wrong/expired; lockout screen (A4)
  after repeated failures.
- **Welcome (B1):** 3-slide value carousel emphasizing **verified profiles & safety**.
- **DOB (B3):** date picker; **under-18 is a hard stop** with a clear message (no retry
  loop trickery).
- **Location (B5):** a **ConsentCard** explains *exactly* what's shared ("approximate
  area only — never your exact location") before the OS prompt. Denial → manual
  city/state entry, never a dead end.
- **Photos (B6):** require ≥1; encourage more (up to 6); live upload progress; first
  photo auto-set as primary. Tasteful guidance on good photos.
- **Bio/Interests (B7):** optional but nudged by a **completeness meter**.
- **Done (B8):** celebratory but calm; CTA into Discover; soft prompt to "Get verified."

Persistence: progress is saved per step so an interrupted onboarding resumes where left.

---

## 4. Profile creation & management (UX detail)

- **My Profile (F1)** shows a **completeness meter** and a prominent **Get Verified** CTA
  if unverified — verification is positioned as a benefit (more trust, more matches).
- **Edit (F2):** inline validation, autosave-on-save with success snackbar.
- **Photo Manager (F3):** drag-to-reorder grid, long-press to set primary, swipe/menu to
  delete; uploads show shimmer placeholders; enforces type/size limits with friendly errors.
- **Verification (F4→F5):**
  - Guided selfie with a **pose prompt** and framing overlay.
  - On submit → status becomes **Pending** with a clear "usually reviewed within 24h" note.
  - **Approved** → blue **VerifiedBadge** appears across discovery/profile/chat + a
    celebratory confirmation.
  - **Rejected** → respectful reason + a **Retry** path. No shaming.
- Verified status is a **visual trust signal**, consistently rendered with `trust/verified`
  ([DesignSystem.md §2.2](DesignSystem.md#22-trust--verification-dedicated-never-reused)).

---

## 5. Discovery (UX detail)

- **Discover (C1):** premium **profile cards** (4:5 photo, scrim, name·age, verified
  badge, distance/city chip). **Verified profiles rank first** by default to reinforce
  trust. Pull-to-refresh; infinite scroll with footer spinner.
- **Filters (C2)** open as a bottom sheet: **city/state**, age range (slider), gender,
  and a **Verified-only** toggle. Applying re-queries; active filters shown as removable chips.
- **Profile Detail (C3):** photo carousel, bio, interests, approximate distance/city
  (never exact location), and three clear actions: **Add Friend** (primary), **Block**,
  **Report** (in an overflow to avoid accidental taps).
- **No precise location** is ever displayed — only approximate distance and city
  ([SecurityRequirements.md §6](SecurityRequirements.md#6-privacy--data-protection)).
- **Empty state:** "No one nearby yet" with actions to widen distance or change city.

---

## 6. Connections & requests (UX detail)

- **Requests (D1):** segmented **Incoming / Outgoing** tabs. Incoming tiles offer
  **Accept** (primary) and **Reject**; accepting shows a success cue and surfaces the new
  chat. Rejecting is **silent** to the other user (no notification) to reduce social friction.
- **Chat unlocks only after mutual connection** — the core consent guarantee, reinforced
  by copy ("You can chat once you're connected").
- **Connections (D2):** list of accepted people, tap to open chat.

---

## 7. Chat (UX detail)

- **Chat List (E1):** tiles with avatar, name + verified badge, last message preview,
  timestamp, and unread count badge. Most-recent first.
- **Chat Thread (E2):**
  - Real-time **message bubbles** — sent (rose, right) vs received (neutral, left), with
    timestamps and **read receipts**.
  - **Composer** pinned at bottom: text field, (P1) image attach, send button.
  - Header shows the other user with verified badge and an **overflow menu: Block /
    Report**, keeping safety one tap away inside the conversation.
  - **Empty thread:** "Say hi 👋" with the composer focused.
  - **States:** history skeleton on load; per-message send state (sending → sent → read);
    failed send shows a **Retry** affordance; an **offline banner** appears when
    disconnected (cached messages stay readable).
  - **Blocking** either party immediately disables the composer and marks the thread
    inactive.
- **Image Viewer (E3):** full-screen, zoomable, with report option.

---

## 8. Safety & trust UX (cross-cutting)

Present on **every** surface where a user or message appears:
- **Report (G1):** bottom sheet with a clear reason list (spam, harassment, fake,
  nudity, underage, other) + optional details; calm confirmation; never reveals the report
  to the target.
- **Block (G2):** destructive confirm dialog stating consequences ("They won't be able to
  find or message you; your chat will be removed"); silent to the blocked user.
- **Blocked List (G3):** manage/unblock.
- **Consent & permissions:** always explained with a **ConsentCard** before any OS prompt.
- **Trust signals:** verified badges, safety tips during onboarding, and accessible
  reporting communicate "we keep this community safe."

---

## 9. Admin UX (web)

Utility-first, dense, fast — distinct from the consumer app but sharing tokens.
- **Login (I1):** rejects non-admins with a clear denied state.
- **Dashboard (I2):** stat cards (pending verifications, open reports, under-review,
  signups, DAU) + quick links to queues.
- **Verification Queue (I3):** **side-by-side** selfie vs profile photos, Approve/Reject
  with reason, auto-advance to the next item (keyboard-friendly for speed).
- **Reports Queue (I4):** list + reason filters; detail shows target, evidence snapshot,
  and the target's report history; actions Warn/Suspend/Ban/Dismiss with a required note.
- **User Search/Detail (I5/I6):** inspect and act (Suspend/Ban/Restore) with full audit trail.
- **Audit Log (I7)** and **Admin Settings (I8)**: accountability + kill-switches.
Full spec in [AdminPanel.md](AdminPanel.md).

---

## 10. Cross-cutting UX rules

- **Loading:** content uses **skeletons** (not spinners); buttons show inline spinners;
  only bootstrap uses a full-screen loader ([DesignSystem.md §9.1](DesignSystem.md#91-loading-states)).
- **Empty:** every list defines an illustrated, actionable empty state
  ([DesignSystem.md §9.2](DesignSystem.md#92-empty-states)).
- **Errors:** blame-free, specific, with a next step; never expose codes/stack traces
  ([DesignSystem.md §9.3](DesignSystem.md#93-error-states)).
- **Confirmation:** destructive actions (block, ban, delete) always confirm with explicit
  consequences.
- **Feedback:** every user action yields immediate visual feedback (optimistic UI where
  safe, e.g. sending a message; pessimistic for irreversible actions).
- **Accessibility:** AA contrast, ≥48dp targets, scalable text, semantic labels, honored
  reduced-motion and RTL ([DesignSystem.md §11](DesignSystem.md#11-accessibility-checklist-per-screen)).

---

## 11. Notifications UX

Push (FCM) for: new friend request, request accepted, new message. Tapping deep-links to
the relevant Requests tab or Chat thread. Categories are user-toggleable in Notification
Preferences (H2). Notifications are informative, never manipulative re-engagement bait.

## 12. Design → build traceability

| Spec | Maps to |
|------|---------|
| Flows here | [UserFlows.md](UserFlows.md) (product) |
| Every screen | [ScreenInventory.md](ScreenInventory.md) |
| Components/tokens | [DesignSystem.md](DesignSystem.md) |
| Navigation impl | [FlutterArchitecture.md](FlutterArchitecture.md#4-navigation) |
| Safety/privacy | [SecurityRequirements.md](SecurityRequirements.md) |
