# Design System — Jakarta Runner Training Reference

## Product Context
- **What this is:** A personal training reference page for a 17-week 10K plan targeting sub 45:00 at Pocari Sweat Lombok 10K (July 12, 2026)
- **Who it's for:** Personal use only — Jesse Choi
- **Space/industry:** Running / endurance sports / personal training tools
- **Project type:** Single-page reference tool, data-dense, consulted daily

## Aesthetic Direction
- **Direction:** Sports Data Terminal
- **Decoration level:** Minimal — typography and data carry everything. No texture, no paper grain, no ornamental rules.
- **Mood:** Precise, fast, authoritative. Feels like a GPS watch interface or race timing display blown up to a full page. The antithesis of the original editorial cream aesthetic — a tool you check before 6am intervals, not a journal you read in a café.

## Typography
- **Display/Hero:** Fraunces — variable optical serif. Personal and bookish at large sizes. Keeps a human quality that prevents the dark terminal from feeling cold. The variable optical axis makes it look particularly good at hero sizes.
- **Body:** Plus Jakarta Sans — geometric, clean, athletic. Strong at 300–500 weight for dense training descriptions.
- **UI/Labels:** JetBrains Mono — all paces, distances, dates, section numbers, pill tags, and navigation. Every number should look intentional and precise.
- **Data/Tables:** JetBrains Mono — tabular-nums for alignment in training tables.
- **Code:** JetBrains Mono
- **Loading:** Google Fonts — `https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,400;0,9..144,600;1,9..144,300;1,9..144,400&family=Plus+Jakarta+Sans:wght@300;400;500;600&family=JetBrains+Mono:wght@400;500;600&display=swap`
- **Scale:**
  - Hero: 40–88px (clamp), Fraunces 300
  - H2 section titles: 22–26px, Fraunces 300
  - Body: 14–15px, Plus Jakarta Sans 400
  - Small/labels: 11–13px, JetBrains Mono
  - Table data: 12px, JetBrains Mono / Plus Jakarta Sans

## Color
- **Approach:** Restrained — one accent per mode, neutrals do the heavy lifting. Color is rare and meaningful.

### Dark Mode (default)
- **Background:** `#0d0f0e` — near-black with a subtle green tint. Feels like a GPS device, not a generic dark theme.
- **Surface:** `#161a17` — cards, panels, table backgrounds
- **Surface 2:** `#1e2420` — elevated surfaces, table headers
- **Border:** `#252c26` — primary dividers
- **Border 2:** `#303830` — subtle borders, input outlines
- **Text:** `#f0f4f1` — primary
- **Muted:** `#7a8a7c` — dates, labels, secondary descriptions
- **Muted 2:** `#4a5a4c` — ghost text, very secondary

### Accents (per mode)
- **Run / Green:** `#4eff91` — electric green, codes as GPS lock / race-day visibility. Backgrounds: `#0e1f14`. Dim: `#1a4a2e`.
- **Mobility / Amber:** `#ffa94d` — warm amber, kept from original but sharpened. Backgrounds: `#1e1408`. Dim: `#4a3010`.
- **Strength / Blue:** `#5ab0f5` — steel blue, kept from original but cooled. Backgrounds: `#0a1824`. Dim: `#0e2840`.

### Semantic
- **Success:** `#4eff91` (same as run accent)
- **Warning:** `#ffa94d` (same as mobility accent)
- **Error:** `#ff6b6b`
- **Info:** `#5ab0f5` (same as strength accent)

### Light Mode
- **Background:** `#f4f7f5`
- **Surface:** `#ffffff`
- **Text:** `#0d1a10`
- **Muted:** `#5a7060`
- **Run:** `#1a8a40` | **Mobility:** `#c87010` | **Strength:** `#1a6aaa`
- Same accent tints, inverted for light surfaces.

## Spacing
- **Base unit:** 8px
- **Density:** Comfortable — data tables stay dense but sections breathe
- **Scale:** 2xs(4) xs(8) sm(12) md(16) lg(24) xl(32) 2xl(48) 3xl(64) 4xl(80)

## Layout
- **Approach:** Grid-disciplined — strict alignment, predictable columns, no creative asymmetry. The content is dense enough; the layout should be calm.
- **Grid:** Single column for sections, multi-column for timing grids and exercise grids
- **Max content width:** 1200px
- **Border radius:** sm(3px) md(4px) lg(6px) — deliberately small. Sharp edges suit the terminal aesthetic. No bubbly rounding.

## Motion
- **Approach:** Minimal-functional — only transitions that aid comprehension
- **Mode transitions:** `fadeUp` 0.3s ease — content panels animate in on mode switch
- **Interactive states:** 0.15–0.2s transitions on hover/active only
- **No table row animations** — too distracting for reference material

## Decisions Log
| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-18 | Dark mode as default | The original was light/cream. Dark terminal is the sharpest departure and best suits daily pre-run consulting. |
| 2026-03-18 | Fraunces as display font | Keeps personal character. Running apps almost universally use grotesques — Fraunces makes this feel like a personal tool, not a product. |
| 2026-03-18 | JetBrains Mono for all data/labels | Every pace, distance, and date should feel precise and intentional. Monospace enforces visual alignment in tables without CSS hacks. |
| 2026-03-18 | Electric green (#4eff91) as run accent | Codes as GPS signal / race-day visibility gear. Not a lifestyle brand color. |
| 2026-03-18 | Small border radius (3–6px) | Sharp edges suit the terminal aesthetic. Rounded cards would fight the precision of the design. |
| 2026-03-18 | Initial design system created | Created by /design-consultation for training-website. Previous design: warm editorial, DM Serif/DM Mono/DM Sans, cream paper. |
