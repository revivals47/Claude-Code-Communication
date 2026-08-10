# notepad follow-up: modal IME plumbing — design proposal (cargo-free survey)

worker2 / 2026-05-23. Independent of worker1 (GPU image-draw); different crate region
(notepad app `src/` vs GUI_kit `hayate-platform/render` + imageview). No shared files.

## 1. The gap (confirmed by reading)

`find_replace.rs:341` and `file_dialog.rs:391` both end their `event()` match with
`_ => EventResponse::Handled` — a modal "swallow everything else." That catch-all eats the
**IME event family** (ImePreedit / ImePreeditClear / ImeCommit / ImeLookupTable /
ImeLookupShow / ImeLookupHide / ImeDeleteSurrounding) instead of forwarding it to the
focused inner `TextInputWidget`. Even the explicit arms only forward `Key` (and to one field).
Result: in the Find/Replace and Save-As fields, Japanese composition (preedit + candidate
window + commit) never reaches the field — only direct ASCII keys land.

## 2. Why this is pure routing — the framework already does the rest

End-to-end IME contract (all verified in current main):

- **down**: `App` (app.rs:2340–2390) converts compositor `ImeEvent` → the 7 `WidgetEvent::Ime*`
  variants and dispatches to the root widget via `event_with_csd`.
- **handling**: `TextInputWidget` (text_input_widget.rs:425–500) already fully handles all 7:
  sets preedit, commits, stores candidates, and — for ImePreedit — returns
  `EventResponse::ImeRect(r.x + cursor_x, r.y, 1, r.height)` from its painted `cached_rect`
  (surface-local coords).
- **up**: a returned `ImeRect` bubbles through whatever returns it. `App` (app.rs:2380–2384)
  reads `EventResponse::ImeRect`, applies CSD/border offset, and positions the candidate window.
- **async paste is the same channel**: Ctrl+V is only a *request*; "the result arrives as an
  `ImeCommit` event" (app.rs:1521). So **forwarding `ImeCommit` covers async paste for free** —
  no separate paste plumbing needed.

The notepad host needs **no change**: the editor path works because
`main.rs:854/864` does `let resp = self.text_area.event(event); … resp` — it returns the
editor's `ImeRect` verbatim. Each modal arm likewise does `… ; return resp;` (main.rs:778–785),
so a modal that returns its focused field's `ImeRect` will bubble correctly to the App today.

**Conclusion: the entire fix lives inside each modal's `event()`** — forward the IME family to
the focused inner field and return (bubble) its response. `shortcut_layer.rs` is the existing
"forward-to-child + return its response verbatim" reference (single-child).

No L2 container currently forwards the IME family (grep: it lives only in the leaf text widgets +
shortcut_layer). So there is no existing container contract to simply delegate to.

## 3. Decision: L2 modal-base pattern vs app-side forward

The missing capability (IME *handling*) is **already in L2** (TextInputWidget). What is missing
is *composite routing* — "send the IME family to the focused child, bubble its ImeRect." Both
notepad modals are app-side hand-rolled composites (each draws its own backdrop + panel +
hit-tested buttons + focus bool); there is **no `ModalBase` in L2 today**. The per-modal
focus decision is app-specific (find_replace routes by `replace_focused`; file_dialog → filename,
Save mode only), so a generic L2 helper could only do forward+bubble *given an already-chosen
field* — the app still picks the field.

### Option A (recommended) — app-side forward, seeded as the future L2 pattern
Add a tiny app-side helper `src/modal_ime.rs`:
```
pub fn forward_ime(event: &WidgetEvent, field: &mut dyn Widget) -> Option<EventResponse>
```
returns `Some(field.event(event))` iff `event` is one of the 7 IME variants, else `None`.
Each modal calls it at the top of `event()` against its focused field:
- find_replace → `replace` if `replace_focused` else `query`
- file_dialog → `filename` in Save mode; in Open mode there is no text field → swallow (correct)
~12-line helper + ~6 lines/modal. **Gate: boss1 approval** (no public L2 API change).

- Pro: root-cause fix (抜本解決: full IME family + ImeRect bubble, not a band-aid); lands now,
  fully parallel to worker1, **no codex gate**, zero framework risk; honors 負債先送り禁止.
- Pro: written self-contained so it lifts into L2 verbatim later (clean promotion path).
- Con: the helper lives in the app crate, not L2 — but it is composition glue, not a duplicated
  platform primitive (TextInputWidget is consumed as-is), so it does not violate the platform
  principle.

### Option B — L2 modal-base abstraction (defer)
A real `ModalBase` / focus-group widget in hayate-kit (backdrop + centered panel + focus group +
IME routing + ESC), both modals rebuilt on top. **Gate: codex API-design**, and (per boss order)
must queue *after* worker1's GPU image-draw gate.
- Pro: future modals get IME + focus for free; strongest platform-principle reading.
- Con: large surface restructuring both modals; designing a framework abstraction from n=2
  near-identical modals is premature; out of proportion to "2 modals need IME"; blocked behind
  worker1's priority gate.

### Recommendation
**A now** (fixes the user-meaningful Japanese-input gap immediately, boss1-landable, parallel to
worker1), **flag B for later**: promote `forward_ime` into an L2 `ModalBase`/focus-group when a
3rd modal or another L2 consumer appears (n≥3 gives enough evidence to design the abstraction
right). This is the honest split: the *fix* is small and app-local; the *framework abstraction*
is a separate, larger initiative that should neither block on nor be designed prematurely from
worker1's priority window.

## 4. Correctness notes (for impl + self-review)
- The inner field's `ImeRect` uses its `cached_rect`, which the modal sets correctly each paint
  (`self.query_rect`/`replace_rect`/`field_rect` → `field.paint(renderer, rect)`), so the bubbled
  rect is already surface-local; App applies CSD offset. No coord work in the modal.
- Forward to the **same** field that receives Key (consistency): find_replace `replace_focused`,
  file_dialog filename(Save). Open-mode file_dialog has no compose target → swallow is right.
- modal `dirty()` already ORs inner-field `dirty()`, so repaint follows; still set `is_dirty`.
- Gate order (boss): worker1 GPU image-draw is priority; this proposal gates after. Drafting now
  is parallel. cargo build serial with worker1 (-j1, request before launch). Interactive IME
  verify (Japanese typing in Find/Save fields) is the user-eyes carve-out.

## 5. Implementation status (Option A approved by boss1, 2026-05-23)

Implemented cargo-free, parallel to worker1's track A. All app-side; uses only the existing
public API (no widget-branch change):
- `src/modal_ime.rs` — `forward_ime(event, field)` helper (the 7-variant match + bubble) +
  3 headless unit tests (non-IME → None / ImeCommit reaches field / ImePreedit forwarded).
- `find_replace.rs` — IME guard at the top of `event()` + `focused_field_mut()` (replace iff
  Replace-mode & replace_focused, else query — same target as Key routing).
- `file_dialog.rs` — IME guard gated on Save mode (Open has no compose target → still swallows).
- `main.rs` — `mod modal_ime;`.

Self-review traced all 4 cases (find/query, find/replace-focused, file/Save, file/Open): IME
family reaches the focused field, ImeRect bubbles host→App, paste (ImeCommit) now lands. Borrow
OK (resp is Copy). **Awaiting boss1's cargo-free signal** (after worker1 track A) to run
`cargo build -j1 -p hayate-notepad` + `cargo test -p hayate-notepad` (scoped, GUI-free); on green,
revert Cargo.toml path-dep to ../GUI_kit and commit on `notepad-l2-rebuild` atop 6bd2ab4. Live
Japanese IME typing + candidate-window position = user-eyes gate.
