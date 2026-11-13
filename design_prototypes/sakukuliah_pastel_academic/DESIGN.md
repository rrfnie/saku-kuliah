---
name: SakuKuliah Pastel Academic
colors:
  surface: '#fef7ff'
  surface-dim: '#dfd7e2'
  surface-bright: '#fef7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f9f1fc'
  surface-container: '#f3ebf6'
  surface-container-high: '#eee5f0'
  surface-container-highest: '#e8e0ea'
  on-surface: '#1e1a22'
  on-surface-variant: '#504447'
  inverse-surface: '#332f37'
  inverse-on-surface: '#f6eef9'
  outline: '#827377'
  outline-variant: '#d4c2c6'
  surface-tint: '#805063'
  primary: '#805063'
  on-primary: '#ffffff'
  primary-container: '#f4b8cd'
  on-primary-container: '#744658'
  inverse-primary: '#f2b6cb'
  secondary: '#6b5a60'
  on-secondary: '#ffffff'
  secondary-container: '#f4dce4'
  on-secondary-container: '#716066'
  tertiary: '#8b4969'
  on-tertiary: '#ffffff'
  tertiary-container: '#ffb2d3'
  on-tertiary-container: '#7f3e5e'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9e4'
  primary-fixed-dim: '#f2b6cb'
  on-primary-fixed: '#320f1f'
  on-primary-fixed-variant: '#65394b'
  secondary-fixed: '#f4dce4'
  secondary-fixed-dim: '#d7c1c8'
  on-secondary-fixed: '#25181e'
  on-secondary-fixed-variant: '#524249'
  tertiary-fixed: '#ffd8e6'
  tertiary-fixed-dim: '#ffafd2'
  on-tertiary-fixed: '#3a0524'
  on-tertiary-fixed-variant: '#6f3251'
  background: '#fef7ff'
  on-background: '#1e1a22'
  surface-variant: '#e8e0ea'
typography:
  display-lg:
    fontFamily: Epilogue
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Epilogue
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Epilogue
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Epilogue
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Epilogue
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1.25rem
  margin-sm: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system defines an offline-first academic planner crafted for Indonesian university students navigating campus routines, study deadlines, and semester benchmarks (KRS, SKS, IPK, Tugas, Jadwal). The personality balances modern academic rigor with a gentle, feminine pastel atmosphere: structured yet soft, approachable, and calming during high-stress exam and assignment periods.

The aesthetic leans into a modern pastel interpretation of Android Material You conventions:
- Softened structural cards with generous inner margins and rounded profiles.
- Tactile, quiet interfaces with ample whitespace that mitigate cognitive fatigue.
- Clean linear iconography (Lucide style, 1.75px–2px stroke) paired with localized student touchpoints like semester trackers, course credit cards, and status pill badges.
- Offline-first visual transparency, utilizing subtle synced/local status markers that never break visual serenity.

## Colors

The palette relies on gentle rose and blush accents against a crisp, warm-toned foundation. Contrast is maintained strictly for academic legibility while avoiding stark blacks or abrasive neon highlights.

- **Primary (`#F4B8CD` - Blush Pink):** Key interactive focal points, prominent floating action buttons (FAB), primary tabs, and milestone highlights.
- **Secondary (`#FCE4EC` - Soft Pink):** Container surfaces, selected chip fills, passive card backgrounds, and schedule item blocks.
- **Tertiary / Accent (`#D98BAE` - Dusty Rose):** High-importance text links, active navigation icons, urgent deadline indicators, and progress ring strokes.
- **Background (`#FFF8FA` - Off White):** Canvas ground tone, tinted with a faint warm blush to reduce eye strain in daylight and indoor study areas.
- **Surface (`#FFFFFF` - Pure White):** Elevated cards, bottom navigation sheet backgrounds, and modal dialogue surfaces.
- **Neutral Dark (`#343038` - Dark Charcoal):** Primary body and heading copy, replacing pure black with a gentle slate-plum tone.
- **Neutral Muted (`#92909A` - Muted Gray):** Secondary subtitles, course codes, credit counters (SKS), and meta labels.
- **Functional Semantics:**
  - **Success (`#A8CBAF`):** Task completions, target IPK reached, synced offline state.
  - **Warning (`#F5D58A`):** Impending deadline (Tugas H-1), schedule overlaps, incomplete KRS validation.

## Typography

The type scale combines a geometric, structured sans-serif for headings (providing the friendly, modern roundness required for student dashboards) with Inter for body and numeric data.

- **Headings (Epilogue):** Chosen for its rounded geometric proportions, structured personality, and legible weight distribution across screen sizes. Applied to student metrics (IPK 3.92), screen titles (Jadwal Kuliah), and primary card headers.
- **Body & Metadata (Inter):** Highly legible at small sizes on varied density Android displays. Powers course schedules, lecturer names, assignment briefs, and timestamps.
- **Data Clarity Rules:** SKS counts and deadline dates use `label-md` with semi-bold weighting to ensure immediate scanning. IPK metrics employ tabular numerals to avoid baseline shift during semester calculations.

## Layout & Spacing

The layout is built for fluid mobile-first Android viewport bounds, strictly scaled on an 8-point base grid (with a 4-point micro-step for compact badges and tight inputs).

- **Grid & Margins:** Standard mobile canvas uses `margin: 1.25rem` (20px) to give content a comfortable breathing room away from display bezels. Internal card gutters maintain `gutter: 1rem` (16px) separation.
- **Touch Ergonomics:** All interactive buttons, navigation icons, and schedule list triggers maintain a minimum touch bounding box of 48×48dp, even when visual badges appear smaller (`label-sm`).
- **Responsive Adaptations:**
  - **Phone (<600dp):** Single-column layout. Bottom bar navigation with integrated quick-add FAB for new tasks (Tugas Baru).
  - **Tablet (≥600dp):** Two-column split-view featuring schedule/calendar on the left pane and task/course breakdown on the right pane, scaling gutters to 24px.

## Elevation & Depth

Visual hierarchy uses delicate tonal layering and warm, diffuse ambient drop shadows rather than heavy industrial borders.

- **Layer 0 (Canvas):** Off White background (`#FFF8FA`).
- **Layer 1 (Cards & Modules):** Pure White (`#FFFFFF`) with a diffuse warm drop shadow:
  - `box-shadow: 0 4px 16px -2px rgba(217, 139, 174, 0.08), 0 2px 6px -1px rgba(52, 48, 56, 0.03)`
- **Layer 2 (Floating Action Buttons & Dialogs):** Soft Pink gradient-tinted shadow:
  - `box-shadow: 0 8px 24px -4px rgba(217, 139, 174, 0.24)`
- **Tonal Borders:** Where contrast against white canvas is needed, cards use a 1px border colored with `#FCE4EC` at 80% opacity, maintaining separation without visual harshness.

## Shapes

The design system embraces a generous, organic roundedness inspired by modern touch interfaces:
- **Standard Cards:** 16px to 20px radius (`rounded-lg` to custom surface rounding) to convey softness and approachability.
- **Chips, Pills, & Badges:** Fully circular / pill geometry (`rounded-full`) for status indicators (e.g., "3 SKS", "Selesai", "KRS Disetujui").
- **Bottom Navigation Sheet:** 24px top border radius with a subtle centered grab handle.
- **Text Inputs:** 12px to 14px radius (`rounded-md`), pairing cleanly with soft pill buttons.

## Components

### Buttons
- **Primary Action (e.g., "Simpan KRS", "Tambah Tugas"):** Background `#F4B8CD`, text `#343038` (semi-bold), 14px height padding (`space-md`), pill or 16px roundedness. Active state transforms with `#D98BAE` tint.
- **Secondary Action:** Background `#FCE4EC`, text `#D98BAE`, no outline.
- **Outlined / Tertiary:** Transparent background, 1.5px border `#F4B8CD`, text `#343038`.

### Chips & Badges
- **Status Pills:** Background `#FCE4EC` with `#D98BAE` text for general metadata.
- **Academic Metrics (SKS / IPK):** Elevated micro-chips with `#FFF8FA` ground, 1px border in `#F4B8CD`, and Dark Charcoal label values.
- **Deadline Tag (Tugas):**
  - Urgent (<24h): Soft Yellow `#F5D58A` with deep amber text.
  - Selesai (Completed): Soft Green `#A8CBAF` with muted forest text.

### Schedule & Course Cards (Jadwal Card)
- Surface `#FFFFFF` with 16px radius, featuring a 4px solid left indicator strip colored by course category (Dusty Rose, Soft Green, Soft Yellow).
- Displays course title in `headline-sm`, room code and time in `body-sm`, and lecturer name in `body-md` with muted color.

### Form Inputs
- Background `#FFFFFF`, 1.5px subtle border `#FCE4EC`, transitioning to `#D98BAE` on focus.
- Inner padding `12px 16px`. Floating label styled in Inter with clear helper text below for offline-sync notices.

### Bottom Navigation & FAB
- 4-destination Android bottom bar (Jadwal, Tugas, KRS/Akademik, Profil).
- Active item uses a circular Blush Pink indicator behind the line icon.
- Docked or floating pill-shaped FAB utilizing `#D98BAE` with white icon for creating schedules and assignments.