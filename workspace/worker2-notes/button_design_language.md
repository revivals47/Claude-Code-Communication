# Cohesive Hayate button design language — toolbar + chrome (cargo-free survey + proposal)

worker2 / 2026-05-24. User feedback: imageview's Open/Reset toolbar buttons are functionally fine
and well-placed (top-left, OK) but **look ugly** — a *visual* problem (icon/shape/contrast/
spacing), not placement. Task: a cohesive button design language unifying the imageview toolbar
(Open/Reset) AND the window chrome (×/min/max), in Hayate's own aesthetic (reject egui flatness +
mac copy), measure-first, prior-art-researched, escaping egui-tier maturity. Survey only — user is
the design arbiter; impl after the proposal is confirmed (separate worktree, cargo serial with
worker1, who is doing icon-view v0.2 + L2 impl in parallel — cargo-free survey doesn't conflict).

## 1. Measurements (current)

**imageview toolbar (5855df7, `viewer.rs:511-542`, hand-rolled):**
- Open 56×26, Reset 60×26; `pad 8` from the top-left corner, `6px` between.
- fill = `fill_rect(32,34,40, 210)` — a **flat, sharp-cornered, semi-transparent dark rect**.
- label = text only ("Open"/"Reset"), SansSerif 12px, `(220,220,225)`. **No icon, no radius, no
  border, no hover, no pressed state.**
- Drawn directly over the image → contrast is **unpredictable** (light grey text + 82%-opaque
  dark rect floating over arbitrary photo content).
- In-picker Open (`viewer.rs:488`): 84×28, solid `theme.accent`, white text, sharp, no icon.

**chrome ×/min/max (0084ea9, after Tier A+B1):** default `new()` 46×32 button, idle **rounded
pill** `#2A2F3D` (radius 6) + hover `#3A3E4A` / red close, font glyph `×`/`□`/`─` ~10px; themed,
hover states. `hayate_original` 36×28 warm pill.

**The mismatch IS the "ダサい":** chrome = rounded, themed, hover-aware, idle affordance; toolbar
= flat sharp rect, no hover, no icon, no radius, image-dependent contrast. Two unrelated button
looks in the same app.

## 2. Key finding — the design language already exists in L2 (and imageview ignores it)

L2 (`hayate-kit`) already ships the whole vocabulary:
- `widget/button.rs` **`ButtonWidget` + `ButtonTheme`** — rounded (`border_radius` / `pill`),
  themed, idle/hover/pressed fills (`bg (40,42,50)` / `bg_hover (52,56,72)` / accent-pressed),
  fg/fg_hover, border, optional glow, tween, `no_hover`, icon-child via `with_child`.
- `widget/icon.rs` **`IconWidget` + `draw_icon` + `IconPath`** — a normalised-coordinate vector
  icon system (`Line`/`Disc`/`Circle`/`Fill/StrokeRect`), `with_size`/`with_color`/`with_stroke`.
  Built-ins: GEAR/PALETTE/GLOBE/ACCESSIBILITY/KEYBOARD/SAVE/PLUS/MINUS/CLOSE/CHECK/TEXT.
- `widget/toolbar.rs` **`Toolbar`** container, `widget/tooltip.rs` **`Tooltip`**.

imageview uses **none** of these — it hand-rolls `fill_rect`. Tellingly its `fill_rect(32,34,40)`
*approximates* `ButtonTheme.bg (40,42,50)` by eye but throws away the rounding, hover, border, and
icon that `ButtonWidget` would give for free. **So the ugliness is largely a platform-principle
gap** ([[feedback_apps_on_l2]] / [[feedback_platform_principle]]): the consumer reimplemented a
worse button instead of consuming the L2 one. The cohesive language is therefore mostly
"consume L2 `ButtonWidget` + `IconWidget` everywhere," not "invent new app styling."

Critically: the **L2 vector-icon system is also exactly what chrome B2 (crisp vector glyph) needs**
— so one icon vocabulary serves both the toolbar icons AND the chrome ×/min/max glyphs = the
deepest cohesion lever.

## 3. Prior art (researched; user is the arbiter, this only informs)

- **GNOME Loupe** (the user's desktop image viewer): semi-transparent **floating button overlay**
  that follows the system colour scheme, non-intrusive, revealed on hover over the image — the
  canonical "controls over content" pattern. Confirms a *translucent capsule of flat icon buttons*
  for the over-image toolbar.
- **GNOME/libadwaita header bars**: flat icon buttons (~16px symbolic glyph, ~34px hit area), no
  border at rest, subtle rounded hover bg — the same flat-button treatment used for window
  controls (toolbar ↔ chrome already unified there).
- **macOS** (Preview/Photos): translucent rounded capsule of icon buttons floating over content;
  unified toolbar with SF Symbols ~16–18px.
- Common thread: **flat icon buttons, rounded hover highlight, a translucent group scrim only when
  floating over content** (for legibility). Hayate's take: this, but in its warm-neutral / cool-
  dark palette and a clean geometric icon stroke — not mac's exact capsule, not egui's bare grey.

## 4. Proposed cohesive Hayate button language

One button vocabulary, expressed by both surfaces, anchored on L2 `ButtonWidget` + `IconWidget`:

- **Shape**: rounded-rect, radius **6px** (matches the chrome B1 pill + `ButtonTheme.border_radius`
  family) — one corner radius everywhere.
- **Icon**: crisp geometric vector glyph from the L2 icon system, **~16px, consistent ~1.75px
  stroke**, centred. Toolbar: Open = a **folder/open-folder** icon, Reset = a **circular-arrow
  (refresh)** icon (both need adding to `icon.rs` — additive consts). Chrome: ×/−/□ from the same
  vector system (CLOSE exists; add box/minus-rail variants). Icon-first; text optional.
- **Contrast / fills**: idle = subtle themed fill; hover = brighter; pressed = accent. Same
  idle<hover<pressed ramp as chrome B1 + `ButtonTheme`. Glyph colour ≥ WCAG AA 3:1 on both.
- **Over-content legibility (imageview toolbar)**: group the toolbar buttons in a **translucent
  rounded "capsule" scrim** (one rounded panel behind the row, e.g. `#1E2230` @ ~70% + 1px subtle
  border), so contrast is independent of the image behind — the Loupe/Preview pattern. Buttons
  inside the capsule use the shared idle/hover language.
- **Sizing / spacing**: button **30×30** (icon-only) or 30px-tall with label; ≥ WCAG 24px target;
  internal padding 8px; inter-button gap 6px; capsule padding 6px. Toolbar height ~42px capsule.
- **Identity**: geometric, minimal, warm-neutral/cool-dark palette, hover that *reveals* rather
  than shouts — distinct from egui's flat grey boxes and from mac's exact traffic-light/capsule.

This makes the toolbar and chrome read as the same family: rounded, icon-led, the same fill ramp,
the same icon stroke.

## 5. Where it lives + API impact + gate (for the impl phase)

**Phase 1 — imageview toolbar consumes L2 (biggest visual win, low/no L2 API):**
- Replace the hand-rolled `fill_rect` toolbar with L2 `ButtonWidget` (icon child via `with_child`
  / `IconWidget`) inside a translucent capsule (L2 `Toolbar` or an app-drawn scrim panel). App-side
  change in `imageview/src/viewer.rs` → **no L2 API change** for consuming existing widgets.
- Add **FOLDER + REFRESH icon consts** to `hayate-kit/src/widget/icon.rs` — **additive `pub const
  IconPath`** (low BC risk; no struct/enum change). boss1-gateable as additive.
- → **boss1 gate** (app-side + additive consts).

**Phase 2 — chrome glyphs adopt the same vector icons (full cohesion, public API):**
- `title_bar.rs` draws ×/−/□ via `draw_icon` (the shared vocabulary) instead of the font symbol,
  selected by a new `CaptionGlyphStyle` variant (e.g. `HayateVector`) or a glyph field on
  `TitleBarTheme`. This is the same change as the deferred **chrome B2** — now unified with the
  toolbar icon work. Public surface change (no `#[non_exhaustive]` → locally compatible /
  theoretically semver-breaking) → **codex API-design gate**.

Recommend **Phase 1 first** — it resolves the imageview "ダサい" directly, aligns the toolbar with
the L2 button language (so it's automatically cohesive with everything else using `ButtonWidget`),
and only adds additive icons. Phase 2 (chrome vector glyph = B2) folds in afterward for ×/min/max
↔ toolbar icon identity, behind the codex gate.

## 6. Impl isolation (when confirmed)

- imageview Phase 1: branch in the imageview repo (worker1's active tree — coordinate; likely a
  branch off `5855df7` or rebased onto worker1's icon-view v0.2 to avoid stepping on it). The L2
  icon-const additions: branch `feat/chrome-controls` (already off main, where the chrome work
  lives) or a fresh `feat/button-icons` off main + worktree.
- Phase 2 chrome: continues on `feat/chrome-controls` (the B2 slot).
- cargo serial with worker1 (-j1, request before launch). **Live visual judgement is the user's**
  (design arbiter) — propose, show, iterate.

## 7. Open question for the user (design arbiter)
- Icon-only toolbar buttons (Open/Reset as folder/refresh icons, label in a tooltip) vs icon+label
  (icon + "Open"/"Reset" text). Icon-only is cleaner/more GNOME-like; icon+label is more
  discoverable. Recommend **icon + label** for the toolbar (two actions, discoverability) and
  icon-only for chrome — but this is the user's aesthetic call.
