# FilePicker → full file browser: breadcrumb + sidebar (cargo-free design proposal)

worker2 / 2026-05-24. User (perf now fast): make the picker a full file browser —
(1) **breadcrumb** path bar (clickable ancestor segments → navigate), (2) **sidebar** places
(Home + XDG user dirs → navigate). v1 internal (no public API). Design-heavy (layout + look) →
worker2 proposes, worker1 implements, **user = live-visual arbiter**. Separate from the
button-styling hold (REFRESH/capsule); cargo-free, parallel to worker1's 12s-fix.

## 1. verify-first — both widgets already exist in L2 (reuse, platform principle)

- **`widget/breadcrumb.rs` `BreadcrumbWidget`**: `set_segments(&[str])` / `with_segments`,
  `on_navigate(FnMut(usize))` (callback = clicked segment index), `with_separator`, `with_height`,
  `with_engine`; already hit-tests segments + handles clicks. → the path bar, ready to use.
- **`widget/navigation_list.rs` `NavigationListWidget`**: `NavItem::entry(label)` /
  `entry_with_icon(icon, label)` / `section(label)`, `with_items(Vec<NavItem>)`,
  `with_on_select(FnMut(usize))`, `with_item_height` (32) / `with_section_height` (24), selected
  state + scroll. → the places sidebar, ready to use (and it takes an icon string per item — pairs
  with the new FOLDER icon).
- **`FilePickerWidget`** already exposes the navigation primitives: `current_dir() -> &Path`,
  `navigate_to(&Path)`, `navigate_up()`. So wiring is trivial.

So this is **pure composition** — no new widgets, no hand-rolling. Both features = compose the two
existing widgets into FilePicker's layout, wired to `current_dir` / `navigate_to`.

## 2. Current layout (measure)

`FilePickerWidget::paint` (file_picker.rs:286) is a **single pane**: bg+border, then a vertical
list of rows from `rect.y + PADDING` down, each `ROW_HEIGHT`, full width minus padding. Directories
are suffixed `/` (no icon today). No breadcrumb, no sidebar — navigation is via clicking the `..`
parent row only.

## 3. Proposed layout

```
+-------------------------------------------------------------+
|  ⌂ home › ken › Pictures            (breadcrumb bar, ~30px) |
+--------------------+----------------------------------------+
|  PLACES            |  content (existing entry rows)         |
|  ⌂ Home            |   photo1.jpg                           |
|  ▢ Pictures        |   photo2.png                           |
|  ▢ Downloads       |   subdir/                              |
|  ▢ Desktop         |   ...                                  |
|  ▢ Documents       |                                        |
|  (sidebar ~160px)  |  (fills remaining width)               |
+--------------------+----------------------------------------+
```

- **Breadcrumb** (top, full width, ~30px): segments derived from `current_dir` each paint. Root /
  `$HOME` shown as a home glyph or "Home"; ancestors as path components. `on_navigate(idx)` →
  rebuild the path up to `idx` → `self.navigate_to(ancestor)`. (Already-built widget; we only feed
  segments + the callback.)
- **Sidebar** (left, ~160px, below breadcrumb): a `NavigationListWidget` with
  `section("Places")` + `entry_with_icon(FOLDER, "Home")` and one entry per XDG user dir
  (Pictures/Downloads/Desktop/Documents that exist). `on_select(idx)` → map idx → path →
  `navigate_to`. The FOLDER icon (3ffd90b) is the per-place glyph.
- **Content** (right, fills remaining): the existing entry-row list, shifted into the content
  sub-rect (x += sidebar width, y += breadcrumb height). Unchanged row rendering.

## 4. Responsive (important — FilePicker is shared by imageview AND notepad's FileDialog)

FilePicker is consumed by both imageview's picker and **notepad's FileDialog** (~460×360 panel).
So this layout change affects notepad's open/save dialog too. To not crush the narrow notepad
dialog:
- **Breadcrumb**: always shown (compact, full width). Long paths elide/scroll from the left.
- **Sidebar**: shown only when the picker width ≥ a threshold (e.g. ~420px); below that, hidden
  (content takes full width) — graceful degradation. imageview's big picker shows it; notepad's
  narrow dialog may hide it (or we widen notepad's dialog — user/PRESIDENT call).

## 5. Wiring & data (v1 internal)

- Breadcrumb segments + sidebar places are **computed internally** from `current_dir` and the
  environment ($HOME + standard XDG subdir names; worker1 confirms the mechanism — `$HOME`-relative
  or a dirs crate if already a dep). No public API: the picker just gains private
  `breadcrumb`/`sidebar` child widgets + an internal `refresh_chrome()` that re-derives segments +
  re-selects the active place on each `navigate_to`.
- Clicks: `event()` routes to breadcrumb (top band) → sidebar (left band) → rows (content), and
  applies the resulting `navigate_to`. Mirrors how the current picker already drains a row click.

## 6. API impact + gate

- **v1 = no public API change**: internal child widgets + internal place derivation; reuses
  existing `current_dir`/`navigate_to`. → **boss1 gate** (no codex).
- **Cross-consumer**: changes FilePicker's rendering for *all* consumers (imageview + notepad).
  → any FilePicker golden test re-blesses (intended); notepad's FileDialog visual shifts (sidebar
  hidden at its width, breadcrumb added) — worth a notepad live check too.
- **Future (optional, deferred)**: a `with_sidebar(bool)` / `with_places(...)` builder if a
  consumer wants to opt out / customise — additive, only if needed.

## 7. Hayate aesthetic notes (user is arbiter)

- Sidebar: subtle pane bg (one step off the content bg), `section("PLACES")` header in a muted
  caps label, selected place = the accent highlight already used for rows, FOLDER icon at ~16px in
  the fg-secondary colour, item height 32 (nav default).
- Breadcrumb: chevron `›` separator (not "/"), current segment slightly emphasised, ancestors in
  fg-secondary with hover → fg-primary. Home prefix as a small home glyph for compactness.
- Consistent with the rest of Hayate chrome: same radius family, same accent, geometric icons.

## 8. Open questions for the user (live-visual arbiter)
- Sidebar width (~160px?) and which places (Home + Pictures/Downloads/Desktop/Documents — include
  Music/Videos? Recent? mounted volumes? v1 keep it to Home + the 4).
- Breadcrumb root: a home glyph vs the literal "/" + "home" + "ken" segments (home glyph is
  cleaner; literal is more transparent).
- For notepad's narrow dialog: hide the sidebar (responsive) vs widen the dialog to fit it.

## 9. Impl path (when confirmed)
worker1 implements in L2 `file_picker.rs` (compose BreadcrumbWidget + NavigationListWidget into the
layout + the internal derivation + event routing). cargo serial (-j1). Live-visual judgement (the
browser's look/feel) is the user's gate. Branch off main (FilePicker is L2); coordinate with the
icon/chrome branches at merge.
