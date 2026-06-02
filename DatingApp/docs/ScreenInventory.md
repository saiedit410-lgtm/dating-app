# Screen Inventory

The complete, exhaustive list of **every screen** in Spark across the mobile app and the
admin dashboard, grouped by area, with purpose, key components, and the empty/loading/
error states each must implement. This is the build checklist that pairs with
[UI_UX_Specification.md](UI_UX_Specification.md) (flows) and
[DesignSystem.md](DesignSystem.md) (components/states).

Legend — **States** column: **L** = loading, **E** = empty, **Err** = error.

---

## Area map

| Area | Screens |
|------|---------|
| A. System / Auth | Splash, Phone, OTP, Auth error |
| B. Onboarding | Welcome, Name, DOB, Gender, Location, Photos, Bio/Interests, Done |
| C. Discovery | Discover, Filters, Profile detail, Search |
| D. Connections | Requests (Incoming/Outgoing), Connections list |
| E. Chat | Chat list, Chat thread, Image viewer |
| F. Profile | My profile, Edit profile, Photo manager, Verification, Verification status |
| G. Safety | Report sheet, Block confirm, Blocked list |
| H. Settings | Settings, Notifications, Privacy, Account, Delete account, Legal |
| I. Admin (web) | Login, Dashboard, Verification queue, Reports queue, User search, User detail, Audit log, Admin settings |

Total: **43 screens** (35 mobile + 8 admin). Per-area counts in the summary table below.

---

## A. System / Authentication

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| A1 | **Splash / Bootstrap** | Init Firebase, check session, route | Logo, full-screen loader | L, Err (init fail → retry) |
| A2 | **Phone Entry** | Capture phone + country code | Country picker, phone field, Primary button | Err (invalid number) |
| A3 | **OTP Verification** | Enter 6-digit code | OTP field, resend timer, Primary button | L (verifying), Err (wrong/expired, lockout) |
| A4 | **Auth Error / Locked** | Too many attempts / blocked | Banner, support link, cooldown | Err only |

## B. Onboarding (first run)

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| B1 | **Welcome / Value props** | Trust + safety intro carousel | Hero illustration, pager, CTA | — |
| B2 | **Name** | Display name | Text field, progress | Err (empty/too long) |
| B3 | **Date of Birth (18+ gate)** | DOB + age gate | Date picker, progress | Err (under 18 → block) |
| B4 | **Gender & Preference** | Gender + interested-in | Choice chips, progress | Err (none selected) |
| B5 | **Location Consent** | Permission + city/state | ConsentCard, permission prompt, manual city/state fallback | E (denied → manual), Err |
| B6 | **Add Photos** | Upload 1–6 photos | Photo grid, picker/cropper, primary toggle | L (upload), E (none yet), Err (size/type/upload) |
| B7 | **Bio & Interests** | Bio + interest tags | Multiline, interest chips, completeness meter | Err (length) |
| B8 | **All Set** | Confirmation → Home | Success illustration, CTA | — |

## C. Discovery

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| C1 | **Discover** | Nearby/city ranked people | Profile cards (grid/stack), FAB filters, verified-first | **L** (skeleton cards), **E** ("No one nearby yet" + widen/change city), **Err** (location off, query fail → retry) |
| C2 | **Filters** (sheet) | City/state, age, gender, verified-only | Sliders, chips, segmented, Apply | — |
| C3 | **Profile Detail** | Full profile + actions | Photo carousel, verified badge, bio/interests, distance/city, Add Friend / Block / Report | L (skeleton), Err (load fail) |
| C4 | **Search** | Search by name/city | Search field, results list, recent | L, E ("No results" + clear filters), Err |

## D. Connections (Friend Requests)

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| D1 | **Requests** | Incoming/outgoing tabs | Segmented tabs, user tiles, Accept/Reject | L (skeleton tiles), E (per tab empty), Err |
| D2 | **Connections List** | Accepted connections | User tiles, open chat | L, E ("No connections yet" + Discover), Err |

## E. Chat

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| E1 | **Chat List** | All conversations | Chat tiles, unread badges, search | L (skeleton), E ("No conversations yet"), Err |
| E2 | **Chat Thread** | Real-time 1:1 messaging | Message bubbles, composer, typing (P1), read receipts, header (name/badge/menu: Block/Report) | L (history skeleton), E ("Say hi 👋"), Err (send failed → retry chip, offline banner) |
| E3 | **Image Viewer** | Full-screen message image | Zoomable image, save/report | L (load), Err |

## F. Profile

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| F1 | **My Profile** | View own profile + completeness | Photo, badge, stats, completeness meter, Edit/Get Verified | L, Err |
| F2 | **Edit Profile** | Edit fields | Inputs, interest chips, Save | L (save), Err (validation/save) |
| F3 | **Photo Manager** | Add/reorder/delete/set primary | Drag grid, picker/cropper | L (upload), E (no photos), Err |
| F4 | **Get Verified** | Selfie capture + submit | Camera guide, pose prompt, Submit | L (submitting), Err (camera/upload) |
| F5 | **Verification Status** | Pending/approved/rejected | Status chip, timeline, retry-if-rejected | E (not started), Err |

## G. Safety

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| G1 | **Report (sheet)** | Report user/message | Reason radio list, details, Submit | L (submitting), Err |
| G2 | **Block Confirm (dialog)** | Confirm block + consequences | Destructive dialog | L, Err |
| G3 | **Blocked List** | Manage blocks | User tiles, Unblock | L, E ("You haven't blocked anyone"), Err |

## H. Settings

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| H1 | **Settings** | Hub | Grouped list, sign out | — |
| H2 | **Notification Preferences** | Toggle categories | Switches | L (save), Err |
| H3 | **Privacy** | Location sharing, discoverability | Switches, ConsentCard | Err |
| H4 | **Account** | Phone/email, status | Read-only + manage | Err |
| H5 | **Delete Account** | Re-auth + irreversible delete | Warning, re-auth, Destructive confirm | L (deleting), Err |
| H6 | **Legal** | Privacy policy, terms, guidelines | Webview/links | Err (load) |

## I. Admin Dashboard (Web — see [AdminPanel.md](AdminPanel.md))

| # | Screen | Purpose | Key components | States |
|---|--------|---------|----------------|--------|
| I1 | **Admin Login** | Auth + admin-claim gate | Login form | Err (not admin → denied) |
| I2 | **Dashboard** | Health + queue counts | Stat cards, quick links | L, E (no data), Err |
| I3 | **Verification Queue** | Approve/reject selfies | Side-by-side compare, Approve/Reject, FIFO list | L, E ("Queue empty"), Err |
| I4 | **Reports Queue** | Triage reports | List + filters, detail, Warn/Suspend/Ban/Dismiss | L, E ("All clear"), Err |
| I5 | **User Search** | Find users | Search, results table | L, E ("No results"), Err |
| I6 | **User Detail** | Inspect + act | Profile, history, Suspend/Ban/Restore, audit trail | L, Err |
| I7 | **Audit Log** | Accountability stream | Filterable log table | L, E, Err |
| I8 | **Admin Settings** | Admins + kill-switches (super-admin) | Admin list, Remote Config toggles | L, Err |

---

## Coverage matrix (every screen has its triad)

- **Loading:** every data-backed screen specifies a skeleton or spinner pattern above.
- **Empty:** every list/collection screen (C1, C4, D1, D2, E1, E2, F3, F5, G3, I2–I7)
  has a defined empty state in [DesignSystem.md §9.2](DesignSystem.md#92-empty-states).
- **Error:** every screen defines inline/banner/full-screen error per
  [DesignSystem.md §9.3](DesignSystem.md#93-error-states).

## Screen-count summary

| Area | Count |
|------|------:|
| A. Auth | 4 |
| B. Onboarding | 8 |
| C. Discovery | 4 |
| D. Connections | 2 |
| E. Chat | 3 |
| F. Profile | 5 |
| G. Safety | 3 |
| H. Settings | 6 |
| **Mobile subtotal** | **35** |
| I. Admin | 8 |
| **Total** | **43** |
