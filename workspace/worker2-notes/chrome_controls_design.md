# SystemLike chrome window-control visibility — survey + proposal (cargo-free)

worker2 / 2026-05-23. User design feedback: the ×/min/max window controls are small, hard to
see, and hard to click across SystemLike apps (notepad included). Framework-level chrome issue.
Survey only — impl is gated (boss1 review; some tiers need codex). Isolated from worker1's
hayate-platform/render work (this touches hayate-kit/widget+style and, for one optional tier,
hayate-platform/widget_themes — a different file region).

## 1. Where the controls live

- `hayate-kit/src/widget/title_bar.rs` — `TitleBar` widget. `button_rects()` computes the three
  control rects from `theme.button_width × button_height`; `hit_test_button()` hit-tests **those
  same rects** → the clickable area equals the painted button, no enlarged target. Glyph drawn by
  `paint_button()`: either a pixel/vector glyph (`win95::draw_*_glyph`, Win95/XP paths) or, for
  the Text path, a font symbol at `title_size * 0.8`.
- `hayate-platform/src/widget_themes/titlebar.rs` — `TitleBarTheme` struct (L1) + the `new()`
  default. All sizes/colours are theme fields.
- `hayate-kit/src/style/widget_theme_presets/titlebar.rs` — the period/vendor presets (L2).
- **notepad uses `WIN95_THEME`** (main.rs:960) → win95 chrome (16×14 buttons). This is almost
  certainly what the user is reacting to.

## 2. Measurements (all presets)

| theme | button W×H | glyph | idle button bg | fg vs bar | idle affordance | hit≥24px? |
|-------|-----------|-------|----------------|-----------|-----------------|-----------|
| `new()` modern dark (DEFAULT) | 46×32 | font ×, 10.4px thin | transparent | #DDDDDD on #1E2230 | **none** (transparent) | ✓ |
| `hayate_original` (1st-party) | 36×28 | font ×, 11.2px thin | #F5F2EE = bar bg | #2A2925 on #F5F2EE | **none** (bg==bar) | ✓ |
| `win10` | 46×30 | font ×, 9.6px thin | transparent | #000 on #FFF | none | ✓ |
| `win11` | 46×32 | font ×, 9.6px thin | transparent | #DDD on #202020 | none | ✓ |
| `win95` (notepad) | **16×14** | pixel X 10×9, chunky | #C0C0C0 + bevel | #000 | ✓ (beveled) | ✗ |
| `xp_luna` | **22×21** | white vector | glossy red/blue body | white | ✓ (glossy) | ✗ |
| `mac_os9` | **14×14** | grey box glyph | #CCC + bevel | #000 | ✓ (beveled) | ✗ |
| `macos` / `macos_big_sur` | **13–14** | hover-only / − + × | colored circle | — | ✓ (color) | ✗ |

WCAG 2.2 SC 2.5.8 *Target Size (Minimum)* = **24×24 CSS px** minimum pointer target. Every period
replica is below it in at least one dimension; the modern Hayate themes meet it on hit area.

## 3. Root-cause: two distinct problems

**(A) 押しづらい / hard to click** — `hit_test == painted button`. The small period replicas
(win95 16×14, mac 13–14, xp 22×21) sit under the WCAG 24px floor. notepad's win95 chrome is the
worst case.

**(B) 見えづらい / hard to see** — afflicts the *modern Hayate Text-path themes* specifically:
the glyph is a thin font symbol (`×` = U+00D7, the light multiplication sign) at `title_size*0.8`
(~10–11px), AND the idle button background is transparent / equal to the bar (`new`, `win10`,
`win11`, `hayate_original`) → **no button shape at rest**, just a faint mark. The period replicas
actually have idle affordance (bevel / gloss / colour); it's Hayate's own chrome that reads weak.

## 4. The design tension (needs a values call, surfaced not decided)

Period-replica skins (win95/xp/mac_os9/win10/macos/big_sur) are **fidelity-locked**: their small
buttons + period glyphs are deliberate (see the period-accuracy + Solitaire-fidelity feedback —
enlarging a clone's controls reads as "not actually Win95" and gets rejected). Their bars are also
genuinely short (win95 = 18px tall), so a 24×24 target **cannot** fit without changing bar height
= a fidelity break.

Hayate's **first-party identity themes** (`new()` default + `hayate_original`) carry no fidelity
constraint — this is where Hayate expresses its own aesthetic (not egui-flat-grey, not a mac copy)
and where visibility/affordance should be optimised freely.

## 5. Reference implementations (researched before proposing)

- **Windows 11**: caption buttons 46×32 logical px, ~10px Segoe Fluent glyph, idle transparent →
  **persistent hover highlight** (close → red). So Win is small-glyph too, but the hover fill +
  the consistently-reserved 46px cell give a clear target.
- **macOS**: traffic lights ~12px diameter, ~8px gaps, **always colour-filled** → affordance comes
  from persistent colour, not size.
- **GNOME / libadwaita** (the user's actual desktop): symbolic ~16px glyph inside a flat
  **circular button with a subtly-visible persistent background**, ~34–38px control area. This is
  the "comfortable Linux desktop" reference the user is implicitly comparing against — and exactly
  where Hayate's transparent-idle + 10px thin glyph feels worse.
- **WCAG 2.2 SC 2.5.8**: 24×24 CSS px minimum pointer target (the objective anchor for "hard to
  click").

Takeaway: the affordance gap is *persistent visible button shape + a crisp ~16px glyph*, not raw
button size. GNOME's pattern (subtle persistent pill + clean symbolic glyph) is the closest fit
for a Hayate identity — rendered in Hayate's warm-neutral / cool-dark palette, not mac circles.

## 6. Proposal (Hayate aesthetic, phased by gate)

### Tier A — hit-target decoupling (framework-wide, fidelity-SAFE, no public API)
In `title_bar.rs`, separate the **hit rect** from the **painted rect**: `hit_test_button()` and the
`PointerMove` hover test expand each control's hit area to fill the bar vertically and claim the
inter-button gaps + a few px past the outer edge, **clamped by the neighbour gap** so adjacent
small buttons never overlap. The painted glyph/button is byte-for-byte unchanged → **period
fidelity untouched**, win95/xp/mac just get a comfortable click area (bounded by their short bar
height). Biggest, safest usability win; fixes notepad directly. **Gate: boss1** (internal change,
no `TitleBarTheme` field, no signature change).
- Open values question for user/PRESIDENT: for period skins the bar height itself caps the target
  (win95 18px < 24). Accept the bounded improvement (fidelity kept), or allow taller period bars
  to reach WCAG 24px (fidelity break)? Tier A delivers the fidelity-safe maximum; the rest is a
  deliberate fidelity-vs-ergonomics choice, not mine to make.

### Tier B — Hayate first-party affordance + glyph (DEFAULT `new()` + `hayate_original` ONLY)
Leave every period replica's *visuals* untouched. For Hayate's own chrome:
- **Persistent idle affordance**: a soft rounded "pill" behind each control in a low-contrast
  surface tint (cool tint on the dark default, warm neutral on `hayate_original`) so the button is
  visible at rest — GNOME-style affordance in the Hayate palette (not mac circles, not egui grey).
- **Crisp geometric glyph** at ~16px with a consistent stroke weight — a clean vector × (and ⊏⊐ /
  − marks), not the thin U+00D7 font symbol; reuses the `win95::draw_*_glyph` vector precedent but
  in Hayate's lighter modern stroke. Decouples glyph size from `title_size` (today's `*0.8`).
- **Verified contrast**: glyph vs idle-bg and vs hover-bg both ≥ WCAG AA 3:1.
- **B1 (no API)**: the idle-pill + colour/contrast tuning is achievable as **value-only edits** to
  the two presets (close_bg/hover/fg + a faint idle fill drawn from existing fields). → boss1.
- **B2 (touches public API → codex API-design gate)**: the crisp vector glyph + decoupled glyph
  metric needs *either* a new `CaptionGlyphStyle` variant (e.g. `HayateVector`) *or* a glyph-size
  field on `TitleBarTheme`. Both are public-surface changes.

## 7. API impact + BC (explicit, for the gate decision)

- **Tier A**: no public API change (internal hit-rect computation from a const min-target +
  neighbour clamp). boss1-gateable.
- **Tier B1**: value-only edits to two preset constructors. No struct/enum change. boss1-gateable.
- **Tier B2**: public surface change in `hayate-platform/src/widget_themes/titlebar.rs` —
  - adding a `CaptionGlyphStyle::HayateVector` variant, **or**
  - adding a `glyph_size: f32` (or similar) field to `TitleBarTheme`.
  Neither `CaptionGlyphStyle` nor `TitleBarTheme` is `#[non_exhaustive]` (and we should NOT add
  that — it itself breaks external construction). So honestly: a field add is **locally compatible**
  (all in-repo presets/literals updated in the same change) but **theoretically semver-breaking**
  for any external struct-literal constructor; an enum-variant add is additive but breaks external
  *exhaustive* matches. → **codex API-design gate**.

## 8. Recommendation

Ship **Tier A + Tier B1 first** (both no-API, boss1-gateable): A fixes "hard to click" framework-
wide and fidelity-safe (incl. notepad's win95); B1 gives Hayate's own chrome a visible rest-state
affordance + contrast — together this resolves the bulk of the user complaint without any API
churn and without touching period fidelity. Defer **Tier B2** (crisp vector glyph + glyph-metric
decoupling) as a codex-gated follow-up — it's the polish tier and the only part with API/BC
weight. Surface the period-skin bar-height values question to user/PRESIDENT before assuming any
fidelity break.

## 9. Impl isolation (when gated)

Branch `feat/chrome-controls` off main + dedicated worktree. Tier A + B1 are entirely in
`hayate-kit` (widget/title_bar.rs + style/widget_theme_presets/titlebar.rs) → no overlap with
worker1's hayate-platform/render. Tier B2 touches `hayate-platform/src/widget_themes/titlebar.rs`
(L1) — same crate as worker1 but a different file region; branch+worktree isolation keeps them
apart. cargo serial with worker1 (-j1, request before launch). Live visual judgement of the new
chrome is the user-eyes carve-out.

## 10. Implementation status — A + B1 done cargo-free (PRESIDENT (a) confirmed, 2026-05-23)

Worktree `~/Documents/GUI_kit-w2-chrome`, branch `feat/chrome-controls` off main `f1f04db`.
PRESIDENT confirmed values (a): period skins (win95/xp/mac) stay fidelity-locked — Tier A already
honours this (painted button untouched, hit-rect bounded by bar height, period skins remain <24px
by design, accepted).

**Tier A (hit-rect decoupling, no-API, `title_bar.rs`)** — added `HIT_GROW_CAP` (6px),
`edge_grow()` (split a near neighbour gap / claim a small bar-edge margin / leave the drag region
alone), and `hit_rects()` (full bar height + per-edge horizontal grow). `hit_test_button()` and
the `PointerMove` hover now use `hit_rects()`; `paint()` still uses `button_rects()` →
**painted button is byte-identical** (period fidelity intact). Self-reviewed against the 6
existing `title_bar` tests by tracing coords: close/max/min press + hover still resolve, and
critically `drag_region_press_emits_drag_move` (x=20) stays a drag because `min`'s left edge faces
an open drag region (edge_dist ≫ cap) → grows 0, no intrusion.

**Tier B1 (Hayate identity affordance, no-API, value + render-gate)** — discovered a clean no-API
way to get a real rounded *pill* (not just a square fill) confined to the Hayate themes: in
`paint_button` the flat fill now uses radius 6 **iff `colors.bg.a > 0`** (the theme defines a
visible idle background), else radius 0. Vendor flat skins (win10/win11) keep transparent-idle →
square (e.g. win10's square red close-hover preserved). Then value edits:
- default `new()` (L1): idle `close/max/min_bg` → `#2A2F3D` (faint cool tint over the #1E2230 bar)
  → ramp bar < idle < hover < red-close; opts into the pill.
- `hayate_original` (L2): idle bg → `#ECE7DE` (faint warm tint, was bar-colour = invisible).
- `win11` (L2): rewritten to **reset** idle bg to transparent, so it does NOT inherit the new
  default tint — win11 stays visually unchanged (only `new()` and `hayate_original` change). macos
  already overrides idle bg (traffic lights), so it's unaffected.

**Golden impact (scope confirmed by survey):** the ONLY golden to bless is
`tests/golden_systemlike_chrome.rs::systemlike_titlebar_default` (intentional) — re-bless with
`GOLDEN_BLESS=1 cargo test --test golden_systemlike_chrome`. Verified the rest:
- period-skin goldens (`titlebar_win95` / `_macos9` / `_macos_big_sur` / `_win95_inactive`)
  **must stay green without blessing** = the proof B1 left period fidelity untouched. (Confirmed
  in code: win95→`Win95Pixel`, xp→`caption_button_style`, mac9→`Mac9Box`, macos→`MacTrafficLight`
  all return *before* the flat fill, so the B1 radius gate never runs for them.)
- `golden_a11y_chrome.rs` is **a11y-tree only** (no `GoldenSnapshot` pixel check; asserts
  `AccessibleRole::TitleBar`), and B1 doesn't touch `accessible()` → unaffected.
- `golden_widgets.rs` renders **no titlebar** (the `window_frame_*` goldens were retired, per its
  own comment) → unaffected.
- hayate-ui `app_tests.rs` constructs `TitleBar` but is out of scope (full-workspace GUI-hang
  rule) and logically unaffected (no API change).

**Headless test added** (`title_bar.rs`): `hit_target_spans_full_bar_height_and_spares_drag_region`
— Win95 (14px button in 18px bar) close press at y=0 and y=17 (outside the painted [2,16] button,
inside the bar) now resolves to Close, and the far-left drag region still drags. Locks Tier A's
benefit + the no-intrusion guarantee.

cargo HELD until boss1's cargo-free signal (worker1 HIGH-1/HIGH-2 track-B fixes + re-launch
first); plan: `cargo build/test -j1 -p hayate-kit` (scoped, CPU harness, no GUI/Vulkan) → expect
title_bar unit tests green (incl. the new one) + period goldens green + only `titlebar_default`
diff → bless. B2 (crisp vector glyph + glyph-metric, public API) remains codex-gated, deferred.
