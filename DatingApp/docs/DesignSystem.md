# Design System

The visual foundation for **Spark** — a modern, premium, **trustworthy** Android-first
dating app. This is the single source of truth for color, type, spacing, elevation,
motion, and the component library. It maps directly onto the Flutter `core/theme/` and
`shared/widgets/` layers ([FlutterArchitecture.md](FlutterArchitecture.md)).

Design language: **Material 3** as the substrate, customized into a warm-but-calm,
safety-forward premium aesthetic. Tokens below are named so they translate 1:1 into
`ThemeData`, `ColorScheme`, and `TextTheme`.

---

## 1. Design principles

1. **Trust is visual.** Verification, safety, and clarity are expressed through the UI —
   verified badges, calm colors, generous space, never dark-pattern pressure.
2. **Premium = restraint.** One accent, deliberate whitespace, soft elevation, smooth
   motion. No clutter, no neon.
3. **Android-first, Material-native.** Respect Material 3 ergonomics (touch targets,
   navigation, ripple) so the app feels native, not ported.
4. **Accessible by default.** WCAG AA contrast, ≥48dp targets, scalable text, semantic labels.
5. **Calm, not addictive.** Warm neutrals and soft surfaces; avoid aggressive reds and
   manipulative urgency.

---

## 2. Color palette

Color is defined as **semantic tokens** (role-based), each mapped to a raw value for
light and dark themes. Always reference the token, never the hex, in design or code.

### 2.1 Brand & accent

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `brand/primary` | `#E94E77` (rose) | `#F2779A` | Primary actions, brand, active states |
| `brand/primaryContainer` | `#FFD9E2` | `#5A1A2E` | Filled chips, soft highlights |
| `brand/onPrimary` | `#FFFFFF` | `#3A0A18` | Text/icon on primary |
| `brand/secondary` | `#6C5CE7` (violet) | `#A99BFF` | Secondary accent, links, premium cues |
| `brand/tertiary` | `#00B894` (teal) | `#3FD0AE` | Success / positive accent |

> **Why rose + violet, not pure red?** Red signals alarm/error; a warmer **rose**
> conveys romance while staying calm, and the violet secondary reads "premium." Error
> red is reserved exclusively for genuine errors so warnings remain meaningful.

### 2.2 Trust & verification (dedicated, never reused)

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `trust/verified` | `#1E88E5` (blue) | `#64B5F6` | Verified badge & verified labels ONLY |
| `trust/verifiedContainer` | `#E3F0FB` | `#11324D` | Verified badge background |
| `trust/shield` | `#2E7D6B` | `#5BC6AC` | Safety/security iconography |

> Verification uses a **blue** check — a globally understood "verified" signal (distinct
> from brand rose) so users instantly trust it. It is **never** used for any other purpose.

### 2.3 Neutrals (surfaces & text)

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `surface/background` | `#FBF7F8` | `#121013` | App background |
| `surface/default` | `#FFFFFF` | `#1C1A1E` | Cards, sheets |
| `surface/raised` | `#FFFFFF` | `#26232A` | Elevated cards, dialogs |
| `surface/sunken` | `#F2ECEE` | `#0E0C10` | Input fields, wells |
| `border/subtle` | `#ECE2E5` | `#2E2A31` | Dividers, hairlines |
| `border/strong` | `#D8C9CD` | `#433C49` | Focused/active borders |
| `text/primary` | `#1B1418` | `#F4EEF0` | Headings, body |
| `text/secondary` | `#6B5C62` | `#B9AEB4` | Supporting text |
| `text/disabled` | `#A9999F` | `#6A6068` | Disabled |
| `text/inverse` | `#FFFFFF` | `#1B1418` | On dark/accent surfaces |

### 2.4 Semantic status

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `status/success` | `#2E9E6B` | `#5BD49A` | Confirmations, accepted requests |
| `status/warning` | `#E8A33D` | `#F2BE66` | Cautions, pending review |
| `status/error` | `#D64545` | `#F2807F` | Errors, destructive, blocking |
| `status/info` | `#3A8DDE` | `#6FB2EC` | Informational banners |

### 2.5 Contrast rules
- Body text on its background: **≥ 4.5:1**. Large text/icons: **≥ 3:1**.
- Never convey state by color alone — pair with icon/label (color-blind safe).

---

## 3. Typography

**Type family:** `Plus Jakarta Sans` (headings & UI — geometric, premium) with `Inter`
as the body/fallback. Both are free (Google Fonts/OFL). One display family keeps the
brand cohesive; Inter guarantees legibility at small sizes.

Scale (Material 3 roles, tuned). Sizes in `sp`; line-height as multiple.

| Role | Token | Size | Weight | Line | Use |
|------|-------|------|--------|------|-----|
| Display | `display/lg` | 34 | 700 | 1.2 | Onboarding hero, splash |
| Headline | `headline/lg` | 28 | 700 | 1.25 | Screen titles |
| Headline | `headline/md` | 24 | 600 | 1.3 | Section headers |
| Title | `title/lg` | 20 | 600 | 1.35 | Card titles, app bar |
| Title | `title/md` | 16 | 600 | 1.4 | List item titles, names |
| Body | `body/lg` | 16 | 400 | 1.5 | Primary body, chat messages |
| Body | `body/md` | 14 | 400 | 1.5 | Secondary body, captions in flow |
| Label | `label/lg` | 14 | 600 | 1.2 | Buttons |
| Label | `label/md` | 12 | 600 | 1.2 | Chips, tags, badges |
| Caption | `caption` | 12 | 400 | 1.4 | Timestamps, helper text |
| Overline | `overline` | 11 | 600 | 1.2 | Section labels (tracked +0.5) |

Rules: max **two** weights per screen; numerals tabular for counts/timers; respect the
OS text-scale setting (test up to 1.3×).

---

## 4. Spacing system

**Base unit = 4dp.** All margins, padding, and gaps are multiples of 4. Named scale:

| Token | Value | Typical use |
|-------|-------|-------------|
| `space/2xs` | 4 | Icon-to-label, tight gaps |
| `space/xs` | 8 | Chip padding, small gaps |
| `space/sm` | 12 | Compact list gaps |
| `space/md` | 16 | **Default** screen/card padding |
| `space/lg` | 24 | Section spacing |
| `space/xl` | 32 | Group separation |
| `space/2xl` | 48 | Hero/empty-state breathing room |
| `space/3xl` | 64 | Large vertical rhythm |

- **Screen gutters:** 16dp horizontal default.
- **Card internal padding:** 16dp.
- **Vertical rhythm between sections:** 24dp.
- **Min touch target:** 48×48dp regardless of visual size.

## 5. Shape & elevation

**Corner radii** (`radius/*`): `xs` 8 · `sm` 12 · `md` 16 (cards) · `lg` 24 (sheets,
profile cards) · `full` 999 (pills, avatars, FAB).

**Elevation** — soft, premium shadows (low spread, warm tint), 5 levels:

| Level | Token | Use |
|-------|-------|-----|
| 0 | `elev/0` | Background, flush |
| 1 | `elev/1` | Cards at rest |
| 2 | `elev/2` | Raised cards, app bar on scroll |
| 3 | `elev/3` | Bottom sheets, menus |
| 4 | `elev/4` | Dialogs, FAB |

In dark theme, elevation is conveyed by **surface tint** (lighter surface) rather than
heavy shadow, per Material 3.

## 6. Iconography & imagery

- **Icons:** Material Symbols (Rounded), 24dp default, 2dp stroke; `full`-radius friendly.
- **Verified badge:** filled blue shield/check (`trust/verified`) — consistent everywhere.
- **Avatars:** circular, `full` radius; ring uses `trust/verified` for verified users.
- **Photos:** 4:5 portrait for profile cards; rounded `lg`; always lazy-loaded with a
  shimmer placeholder (see Loading states).
- **Illustrations:** soft, inclusive, low-detail line+wash style for empty states.

## 7. Motion

- **Durations:** `fast` 120ms (state), `base` 200ms (transitions), `slow` 320ms (sheets).
- **Easing:** standard `emphasized` (Material 3) for enter; `decelerate` for incoming.
- **Patterns:** shared-axis for tab/flow steps; fade-through for swaps; container
  transform for card→detail (profile card → profile detail).
- **Restraint:** no looping/pulsing attention grabs; motion clarifies, never nags.
- **Reduced motion:** honor the OS setting → cross-fade only.

---

## 8. Component library

Each component lists key states. These become `shared/widgets/`. States referenced:
**default · hover/pressed · focused · disabled · loading · error · selected**.

### 8.1 Buttons
| Variant | Use | Notes |
|---------|-----|-------|
| **Primary (filled)** | Main action (1 per screen) | `brand/primary`; pressed = darken 8%; loading = inline spinner, label hidden; disabled = `text/disabled` on `surface/sunken` |
| **Secondary (tonal)** | Alternate action | `brand/primaryContainer` |
| **Outline** | Low emphasis | `border/strong` outline |
| **Text** | Tertiary/inline | No container |
| **Destructive** | Block, delete, ban | `status/error`, requires confirm dialog |
| **Icon button** | Toolbar/inline | 48dp target, tooltip |
| **FAB** | Discovery primary action | `full` radius, `elev/4` |

Height 48dp, `label/lg`, `radius/full` for pill buttons / `radius/md` for blocks.

### 8.2 Inputs
Text field, OTP code field (6 boxes), search field, dropdown/select, multiline,
date picker (DOB), photo picker tile, toggle/switch, checkbox, radio, slider
(age/distance range), chip (filter & choice).
- States: default, focused (`border/strong` + `brand/primary` label), error
  (`status/error` border + helper), disabled, filled.
- Always show label + helper slot; errors appear inline below.

### 8.3 Cards & tiles
- **Profile card** (discovery): 4:5 photo, gradient scrim, name + age, verified badge,
  distance/city chip, quick actions.
- **User list tile** (connections/requests): avatar, name, verified badge, subtitle, action.
- **Chat list tile:** avatar, name, last message, timestamp, unread count badge.
- **Message bubble:** sent (`brand/primary`, right) vs received (`surface/sunken`, left);
  timestamp, read receipt, image variant.
- **Stat / info card** (admin).

### 8.4 Navigation
- **Bottom navigation bar** (primary): 4 destinations — Discover, Requests, Chats, Profile.
- **Top app bar:** title, optional back, contextual actions.
- **Tabs** (segmented) for sub-views (e.g. Requests: Incoming/Outgoing).
- **Bottom sheet** for actions/filters; **modal dialog** for confirmations.

### 8.5 Feedback & status
- **Snackbar/toast** (transient), **inline banner** (persistent info/warning),
  **badge** (counts, verified), **chip** (filters, status: pending/verified),
  **progress** (linear for steps, circular for waits), **skeleton/shimmer** (loading).

### 8.6 Safety & trust components
- **VerifiedBadge** (sizes sm/md), **SafetyBanner**, **ReportSheet** (reason list),
  **BlockConfirmDialog**, **ConsentCard** (location/permissions). These are first-class,
  reused everywhere a user or message appears.

---

## 9. Global state patterns

A consistent triad applied to **every data surface** (defined once, reused):

### 9.1 Loading states
- **Skeleton/shimmer** mirroring final layout (profile cards, chat list, profile detail) —
  preferred over spinners for content.
- **Inline spinner** inside buttons during submit (label hidden, button width fixed).
- **Full-screen loader** only for initial app/auth bootstrap (logo + subtle progress).
- **Pagination:** footer spinner on infinite lists (discovery, chat history).
- Skeletons use `surface/sunken` → shimmer sweep `surface/default`, 1.2s loop, respecting reduced-motion.

### 9.2 Empty states
Every list/collection defines an empty state: **illustration + title + one-line guidance
+ (optional) primary action.**
| Screen | Title | Action |
|--------|-------|--------|
| Discovery (no results) | "No one nearby yet" | "Widen distance / change city" |
| Requests (incoming) | "No requests yet" | "Complete your profile to get noticed" |
| Connections | "No connections yet" | "Discover people" |
| Chats | "No conversations yet" | "Find someone to talk to" |
| Chat thread (new) | "Say hi 👋" | — (composer focused) |
| Search (no match) | "No results for ‘x’" | "Clear filters" |
| Blocked list | "You haven't blocked anyone" | — |
| Admin queue empty | "All clear — queue is empty" | — |

### 9.3 Error states
Tiered by severity, always **actionable** and **blame-free**:
- **Inline field error:** `status/error` text below input.
- **Form/section error banner:** persistent banner with retry.
- **Full-screen error:** for failed initial load — illustration, cause, **Retry** button.
- **Connectivity:** offline banner ("You're offline — reconnecting…"); Firestore offline
  cache keeps content readable.
- **Permission denied / blocked:** clear explanation + path forward (e.g. "Enable location
  to see nearby people" → settings).
- **Destructive confirmations:** dialog with explicit consequence text before block/ban/delete.
- **Rate-limited:** friendly "Slow down a moment" with cooldown, mapped from
  `resource-exhausted` ([API_Specification.md](API_Specification.md#10-rate-limiting--abuse-cross-cutting)).
- Copy guidelines: human, specific, never expose stack traces or codes to users.

---

## 10. Theming & tokens in code

- Tokens implemented as a `ThemeExtension` (`AppColors`, `AppSpacing`, `AppRadii`) plus a
  Material 3 `ColorScheme`/`TextTheme`, so widgets read `Theme.of(context)` tokens only —
  no hardcoded hex/sizes. Light & dark themes both ship at launch.
- See [FlutterArchitecture.md §7](FlutterArchitecture.md) for where theming lives.

## 11. Accessibility checklist (per screen)
- Contrast AA · touch ≥48dp · text scales to 1.3× · semantic labels on icons/images ·
  focus order logical · state never by color alone · reduced-motion honored · RTL-ready.
