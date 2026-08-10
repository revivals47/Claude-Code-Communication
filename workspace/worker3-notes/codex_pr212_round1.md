Reading additional input from stdin...
OpenAI Codex v0.133.0
--------
workdir: /home/ken/Documents/GUI_kit-task-a-wave2
model: gpt-5.4
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: medium
reasoning summaries: none
session id: 019e7d99-a78c-7391-8a09-2c6b0d62fae5
--------
user
# PR #212 codex round-1 review

Task: review the diff at /tmp/pr212_diff.patch (259 lines, 2 files, ~197/9 added/modified). Branch fix/task-a-action-priority-race / GUI_kit PR #212 / title "fix(platform): WindowAction priority-based replacement — preserve Maximize from DragMove overwrite (Task A wave 2)".

## Context

Task A wave 2 fix for a confirmed last-write-wins race in `Rc<Cell<WindowAction>>`. PR #211 (now closed) instrumented the chrome action chain with eprintln; the captured trail showed every double-click producing:

```
[task-a] title_bar DoubleClick … action.set(Maximize)
[task-a] title_bar L-press     … action.set(DragMove)   ← same burst
[task-a] connection.run dispatching action=DragMove     ← Maximize lost
```

This PR closes the race by adding `WindowAction::priority()` (None=0 / DragMove,ShowWindowMenu=1 transient / Close,Maximize,Minimize=2 terminal) and a producer-side gate `set_window_action(flag, new)` that writes only when `new.priority() >= current.priority()`. The five direct `self.action.set(…)` callsites in `TitleBar::event` migrate to the gated helper. The platform dispatcher's `Cell::set(WindowAction::None)` reset in connection.rs:662 INTENTIONALLY stays on the direct path — it's single-writer and not a competing request.

Repos: ~/Documents/GUI_kit-task-a-wave2 (worktree on fix/task-a-action-priority-race), base 458d6c5.

## Review focus (4 axes — PRESIDENT-specified)

1. **priority() rank consistency**: None=0 / transient=1 / terminal=2 — does the variant split match the wave-1 race semantics? `Restore` is intentionally NOT a variant (current `Maximize` toggles via `xdg_toplevel::set_maximized`/`unset_maximized`); is the rationale defensible from the enum + dispatcher code, and would adding `Restore` later require any rank reshuffle?

2. **set_window_action gate semantics**: the rule is `new.priority() >= current.priority()` — same-priority replacement is allowed by design so retargets within a class (e.g. Close after Maximize) still win, and a transient overwriting a transient is harmless. Is `>=` (vs `>`) actually correct for the user-visible behavior we want? Any sequence that would surprise a caller?

3. **dispatcher reset bypass invariant**: connection.rs:662 keeps using `wa.set(WindowAction::None)` directly. The claim is that the dispatcher's drain is single-writer (no concurrent producer can race with it within the same frame's poll-then-reset pair) and that the gate would WRONGLY block it (since None.priority()=0 < current.priority()=2 once a request is pending). Verify this invariant from the diff alone — does any external caller have a path to invoke the gate with `WindowAction::None`, and if they did, would they reset a real request by accident?

4. **L2/L3 scope-out + Restore omission**: PR body scope-outs the 5 L2/L3 menu-Exit callsites (hayate-explorer / hayate-notepad{,-l2,-track-r2-1c} / hayate-freecell) that still use plain `.set(WindowAction::Close)` on the grounds they fire isolated terminal writes without in-burst transient racers. Is that defensible (could a future feature land a transient producer in those apps and re-introduce the bug?), and is the "no Restore variant" decision sufficient or should the PR body call out that any *future* terminal variant must land with both a `priority()` arm and a regression test?

## Output format

Per-finding line: `[BLOCKER|MINOR|NIT] file:line — issue + suggested fix (1-2 sentences)`. End with summary: `verdict: LGTM | LGTM-with-NITs | REFLECT-REQUIRED | BLOCK`, followed by finding count by class.

Keep findings actionable. PR scope is small (2 commits, ~250 line diff including comments + tests).
codex
Reviewing `/tmp/pr212_diff.patch` against the current worktree and the touched source files first. I’m checking the four requested axes directly from the diff and surrounding code before I decide whether there are actionable findings.
exec
/bin/bash -lc "sed -n '1,260p' /tmp/pr212_diff.patch" in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
diff --git a/crates/hayate-kit/src/widget/title_bar.rs b/crates/hayate-kit/src/widget/title_bar.rs
index 4300ad2..bb05392 100644
--- a/crates/hayate-kit/src/widget/title_bar.rs
+++ b/crates/hayate-kit/src/widget/title_bar.rs
@@ -19,7 +19,7 @@ use hayate_platform::window_policy::{DoubleClickAction, WindowPolicy};
 // `pub(crate)`, and every internal callsite now reaches them through
 // the new path directly rather than the previous
 // `widget::title_bar::` re-export.
-use hayate_platform::window_action::{WindowAction, WindowActionFlag};
+use hayate_platform::window_action::{set_window_action, WindowAction, WindowActionFlag};
 
 /// Background, hover-background, and foreground colours for one
 /// title-bar button. Grouped so [`TitleBar::paint_button`] takes a
@@ -891,11 +891,11 @@ impl Widget for TitleBar {
                 ..
             } => {
                 if let Some(action) = self.hit_test_button(*x, *y) {
-                    self.action.set(action);
+                    set_window_action(&self.action, action);
                     return EventResponse::Handled;
                 }
                 if self.is_in_bar_non_button(*x, *y) {
-                    self.action.set(WindowAction::DragMove);
+                    set_window_action(&self.action, WindowAction::DragMove);
                     return EventResponse::Handled;
                 }
                 EventResponse::Ignored
@@ -907,10 +907,13 @@ impl Widget for TitleBar {
                 ..
             } => {
                 if self.policy.right_click_menu && self.is_in_bar_non_button(*x, *y) {
-                    self.action.set(WindowAction::ShowWindowMenu {
-                        x: *x as i32,
-                        y: *y as i32,
-                    });
+                    set_window_action(
+                        &self.action,
+                        WindowAction::ShowWindowMenu {
+                            x: *x as i32,
+                            y: *y as i32,
+                        },
+                    );
                     return EventResponse::Handled;
                 }
                 EventResponse::Ignored
@@ -919,11 +922,11 @@ impl Widget for TitleBar {
                 if self.is_in_bar_non_button(*x, *y) {
                     match self.policy.double_click_action {
                         DoubleClickAction::ToggleMaximize => {
-                            self.action.set(WindowAction::Maximize);
+                            set_window_action(&self.action, WindowAction::Maximize);
                             return EventResponse::Handled;
                         }
                         DoubleClickAction::Minimize => {
-                            self.action.set(WindowAction::Minimize);
+                            set_window_action(&self.action, WindowAction::Minimize);
                             return EventResponse::Handled;
                         }
                         DoubleClickAction::None => {}
diff --git a/crates/hayate-platform/src/window_action.rs b/crates/hayate-platform/src/window_action.rs
index 4427ff4..2119d46 100644
--- a/crates/hayate-platform/src/window_action.rs
+++ b/crates/hayate-platform/src/window_action.rs
@@ -53,6 +53,31 @@ pub enum WindowAction {
     },
 }
 
+impl WindowAction {
+    /// Priority level used by [`set_window_action`] to resolve the producer-side
+    /// write race documented on that function.
+    ///
+    /// - **0 — empty slot**: [`WindowAction::None`] is the initial / drained
+    ///   value and never wins a race with a real request.
+    /// - **1 — transient**: [`WindowAction::DragMove`] and
+    ///   [`WindowAction::ShowWindowMenu`] are compositor-driven gestures that
+    ///   stop the moment the user releases / dismisses; they must not displace
+    ///   a pending terminal action queued by the same input burst (the
+    ///   double-click → press race that motivates this gate).
+    /// - **2 — terminal**: [`WindowAction::Close`], [`WindowAction::Maximize`],
+    ///   and [`WindowAction::Minimize`] change persistent window state and
+    ///   must reach the platform dispatcher. Same-priority replacement is
+    ///   allowed so a deliberate Close-then-Maximize tap sequence resolves
+    ///   on the latest request.
+    pub const fn priority(&self) -> u8 {
+        match self {
+            WindowAction::None => 0,
+            WindowAction::DragMove | WindowAction::ShowWindowMenu { .. } => 1,
+            WindowAction::Close | WindowAction::Maximize | WindowAction::Minimize => 2,
+        }
+    }
+}
+
 /// Shared single-cell flag the title bar writes into and the platform layer reads.
 /// Constructed via [`new_window_action_flag`].
 pub type WindowActionFlag = Rc<Cell<WindowAction>>;
@@ -61,3 +86,163 @@ pub type WindowActionFlag = Rc<Cell<WindowAction>>;
 pub fn new_window_action_flag() -> WindowActionFlag {
     Rc::new(Cell::new(WindowAction::None))
 }
+
+/// Priority-aware producer-side setter for [`WindowActionFlag`].
+///
+/// **Use this from every producer site** (title-bar arms, menu / shortcut
+/// handlers) instead of `flag.set(action)` directly. The platform dispatcher
+/// resets the cell with a plain `flag.set(WindowAction::None)` after consuming,
+/// which is intentional: the reset is a single-writer "I've drained this slot"
+/// signal, not a competing request, so it does not flow through this gate.
+///
+/// **The race this guards** (Task A wave 2, root cause from the diagnostic
+/// PR's stderr capture): a single user gesture can fire two writes into the
+/// shared `Cell<WindowAction>` between dispatcher polls — e.g. the
+/// `DoubleClick` arm sets `Maximize`, then the trailing `PointerPress` arm in
+/// the same burst sets `DragMove`. With a plain `Cell::set` the second write
+/// silently drops the first (last-write-wins) and the dispatcher reads the
+/// transient `DragMove` instead of the user's terminal request. Gating on
+/// `priority()` makes a terminal request immune to a transient overwrite.
+///
+/// **Replacement rule**: `new` is written only when
+/// `new.priority() >= current.priority()`. The equality case lets the user
+/// retarget within the same priority class (e.g. tapping Close after
+/// Maximize) — the most recent same-priority intent wins.
+pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
+    if new.priority() >= flag.get().priority() {
+        flag.set(new);
+    }
+}
+
+#[cfg(test)]
+mod tests {
+    use super::*;
+
+    // ── priority classification ──────────────────────────────────────
+
+    #[test]
+    fn none_has_lowest_priority() {
+        assert_eq!(WindowAction::None.priority(), 0);
+    }
+
+    #[test]
+    fn transient_actions_share_priority_1() {
+        assert_eq!(WindowAction::DragMove.priority(), 1);
+        assert_eq!(
+            WindowAction::ShowWindowMenu { x: 0, y: 0 }.priority(),
+            1
+        );
+    }
+
+    #[test]
+    fn terminal_actions_share_priority_2() {
+        assert_eq!(WindowAction::Close.priority(), 2);
+        assert_eq!(WindowAction::Maximize.priority(), 2);
+        assert_eq!(WindowAction::Minimize.priority(), 2);
+    }
+
+    #[test]
+    fn terminal_priority_strictly_dominates_transient() {
+        // The whole point of the gate: a same-burst DoubleClick→press
+        // sequence whose second event is transient must NOT eat the first
+        // event's terminal request.
+        assert!(WindowAction::Maximize.priority() > WindowAction::DragMove.priority());
+        assert!(WindowAction::Close.priority() > WindowAction::ShowWindowMenu { x: 0, y: 0 }.priority());
+    }
+
+    // ── set_window_action — the producer-side race gate ──────────────
+
+    #[test]
+    fn set_from_none_accepts_any_request() {
+        // The empty / freshly-drained slot must accept the very first
+        // producer write of the frame.
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::DragMove);
+        assert_eq!(flag.get(), WindowAction::DragMove);
+
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::Maximize);
+        assert_eq!(flag.get(), WindowAction::Maximize);
+    }
+
+    #[test]
+    fn transient_does_not_overwrite_terminal() {
+        // The Task A wave 2 root cause: DoubleClick→Maximize then trailing
+        // PointerPress→DragMove. Pre-fix, last-write-wins lost the Maximize;
+        // post-fix the gate rejects the DragMove write.
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::Maximize);
+        set_window_action(&flag, WindowAction::DragMove);
+        assert_eq!(
+            flag.get(),
+            WindowAction::Maximize,
+            "DragMove (priority 1) must not displace Maximize (priority 2)"
+        );
+
+        // Same for the other transient variant.
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::Close);
+        set_window_action(&flag, WindowAction::ShowWindowMenu { x: 10, y: 20 });
+        assert_eq!(flag.get(), WindowAction::Close);
+    }
+
+    #[test]
+    fn terminal_overwrites_transient() {
+        // The reverse arrival order is fine — a real state-change request
+        // arriving after a pending bar-drag stamp must take precedence so
+        // the user's Maximize / Close intent doesn't get stuck behind a
+        // gesture they've since abandoned.
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::DragMove);
+        set_window_action(&flag, WindowAction::Maximize);
+        assert_eq!(flag.get(), WindowAction::Maximize);
+    }
+
+    #[test]
+    fn same_priority_replacement_is_allowed() {
+        // Within a priority class the most recent intent wins — tapping
+        // Close after Maximize, or starting a window-menu after a bar-drag,
+        // must retarget the slot.
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::Maximize);
+        set_window_action(&flag, WindowAction::Close);
+        assert_eq!(flag.get(), WindowAction::Close);
+
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::DragMove);
+        set_window_action(&flag, WindowAction::ShowWindowMenu { x: 5, y: 7 });
+        assert_eq!(flag.get(), WindowAction::ShowWindowMenu { x: 5, y: 7 });
+    }
+
+    #[test]
+    fn set_window_action_to_none_is_a_noop_against_pending_request() {
+        // The gate routes producer writes; the dispatcher's "I've drained
+        // this slot" reset uses `flag.set(WindowAction::None)` directly
+        // (single-writer, not a competing request) and does not flow
+        // through this helper. So if a producer ever passes None through
+        // here, the gate must NOT clear a real pending action.
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::Maximize);
+        set_window_action(&flag, WindowAction::None);
+        assert_eq!(
+            flag.get(),
+            WindowAction::Maximize,
+            "set_window_action(None) must not displace a pending request — the dispatcher uses Cell::set directly to reset"
+        );
+    }
+
+    #[test]
+    fn dispatcher_reset_pattern_still_works_post_gate() {
+        // Sanity: the existing platform-side drain pattern
+        // (`let action = wa.get(); ...; wa.set(WindowAction::None);`) is
+        // unchanged by this PR. It uses Cell::set directly, not the gated
+        // helper, so the reset always succeeds regardless of what was
+        // pending.
+        let flag = new_window_action_flag();
+        set_window_action(&flag, WindowAction::Maximize);
+        let drained = flag.get();
+        flag.set(WindowAction::None); // ← dispatcher pattern, gate-bypassing
+        assert_eq!(drained, WindowAction::Maximize);
+        assert_eq!(flag.get(), WindowAction::None);
+    }
+}

exec
/bin/bash -lc 'git status --short' in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
?? workspace/worker3-notes/codex_pr212_round1.md

exec
/bin/bash -lc "rg -n \"enum WindowAction|set_window_action|action\\.set\\(|WindowAction::None|WindowAction::Maximize|WindowAction::ShowWindowMenu|WindowAction::DragMove\" src" in /home/ken/Documents/GUI_kit-task-a-wave2
 exited 1 in 0ms:
codex
The diff is narrowly scoped to `title_bar.rs` and `window_action.rs`. I’m pulling the surrounding platform dispatcher and current `WindowAction` callsites now to verify the reset invariant and whether any ungated producers remain in the relevant path.
exec
/bin/bash -lc "sed -n '1,180p' crates/hayate-platform/src/window_action.rs" in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
//! Window action signal — the shared cell the title bar writes into and the
//! platform layer reads to drive `xdg_toplevel` close / maximise / minimise /
//! move / window-menu requests.
//!
//! Phase 2 split: these types previously lived in
//! [`crate::widget::title_bar`] alongside [`TitleBar`](super::title_bar::TitleBar).
//! Promoting them to their own module is what makes the
//! `widget::title_bar` module itself internal (`pub(crate)`) — external
//! users that wire `WindowAction` from menu / shortcut handlers (the
//! Phase 1 dogfood pattern) no longer have to pull in the whole title
//! bar surface to do it, and the internal platform layer can keep a
//! stable path that survives any future internal reshuffles of the
//! title-bar widget itself.
//!
//! The shape is intentionally minimal:
//! - [`WindowAction`] is a `Copy` enum with one variant per Wayland
//!   action plus a `None` sentinel for the empty cell;
//! - [`WindowActionFlag`] is a shared single-cell typedef
//!   (`Rc<Cell<WindowAction>>`) so producers (title bar buttons, menu /
//!   shortcut handlers) and the platform-layer consumer can hold their
//!   own clones without ownership friction;
//! - [`new_window_action_flag`] is the one constructor that seeds the
//!   cell with `WindowAction::None`.

use std::cell::Cell;
use std::rc::Rc;

/// Action requested by a title bar button click, a window-menu entry,
/// or a keyboard shortcut handler.
///
/// The producer writes the next action into a [`WindowActionFlag`]; the
/// platform layer drains the cell once per frame and dispatches the
/// matching `xdg_toplevel` request, then resets the cell to
/// [`WindowAction::None`] so subsequent frames start clean.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WindowAction {
    /// No action pending — the platform layer has nothing to do this frame.
    None,
    /// Close the window.
    Close,
    /// Toggle the maximised state.
    Maximize,
    /// Minimise the window to the taskbar.
    Minimize,
    /// Begin a compositor-driven window move (raised when the user drags the title bar).
    DragMove,
    /// Show the window menu (right-click on title bar) at the given screen coordinates.
    ShowWindowMenu {
        /// X coordinate where the window menu should appear, in screen pixels.
        x: i32,
        /// Y coordinate where the window menu should appear, in screen pixels.
        y: i32,
    },
}

impl WindowAction {
    /// Priority level used by [`set_window_action`] to resolve the producer-side
    /// write race documented on that function.
    ///
    /// - **0 — empty slot**: [`WindowAction::None`] is the initial / drained
    ///   value and never wins a race with a real request.
    /// - **1 — transient**: [`WindowAction::DragMove`] and
    ///   [`WindowAction::ShowWindowMenu`] are compositor-driven gestures that
    ///   stop the moment the user releases / dismisses; they must not displace
    ///   a pending terminal action queued by the same input burst (the
    ///   double-click → press race that motivates this gate).
    /// - **2 — terminal**: [`WindowAction::Close`], [`WindowAction::Maximize`],
    ///   and [`WindowAction::Minimize`] change persistent window state and
    ///   must reach the platform dispatcher. Same-priority replacement is
    ///   allowed so a deliberate Close-then-Maximize tap sequence resolves
    ///   on the latest request.
    pub const fn priority(&self) -> u8 {
        match self {
            WindowAction::None => 0,
            WindowAction::DragMove | WindowAction::ShowWindowMenu { .. } => 1,
            WindowAction::Close | WindowAction::Maximize | WindowAction::Minimize => 2,
        }
    }
}

/// Shared single-cell flag the title bar writes into and the platform layer reads.
/// Constructed via [`new_window_action_flag`].
pub type WindowActionFlag = Rc<Cell<WindowAction>>;

/// Construct a fresh [`WindowActionFlag`] initialised to [`WindowAction::None`].
pub fn new_window_action_flag() -> WindowActionFlag {
    Rc::new(Cell::new(WindowAction::None))
}

/// Priority-aware producer-side setter for [`WindowActionFlag`].
///
/// **Use this from every producer site** (title-bar arms, menu / shortcut
/// handlers) instead of `flag.set(action)` directly. The platform dispatcher
/// resets the cell with a plain `flag.set(WindowAction::None)` after consuming,
/// which is intentional: the reset is a single-writer "I've drained this slot"
/// signal, not a competing request, so it does not flow through this gate.
///
/// **The race this guards** (Task A wave 2, root cause from the diagnostic
/// PR's stderr capture): a single user gesture can fire two writes into the
/// shared `Cell<WindowAction>` between dispatcher polls — e.g. the
/// `DoubleClick` arm sets `Maximize`, then the trailing `PointerPress` arm in
/// the same burst sets `DragMove`. With a plain `Cell::set` the second write
/// silently drops the first (last-write-wins) and the dispatcher reads the
/// transient `DragMove` instead of the user's terminal request. Gating on
/// `priority()` makes a terminal request immune to a transient overwrite.
///
/// **Replacement rule**: `new` is written only when
/// `new.priority() >= current.priority()`. The equality case lets the user
/// retarget within the same priority class (e.g. tapping Close after
/// Maximize) — the most recent same-priority intent wins.
pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
    if new.priority() >= flag.get().priority() {
        flag.set(new);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── priority classification ──────────────────────────────────────

    #[test]
    fn none_has_lowest_priority() {
        assert_eq!(WindowAction::None.priority(), 0);
    }

    #[test]
    fn transient_actions_share_priority_1() {
        assert_eq!(WindowAction::DragMove.priority(), 1);
        assert_eq!(
            WindowAction::ShowWindowMenu { x: 0, y: 0 }.priority(),
            1
        );
    }

    #[test]
    fn terminal_actions_share_priority_2() {
        assert_eq!(WindowAction::Close.priority(), 2);
        assert_eq!(WindowAction::Maximize.priority(), 2);
        assert_eq!(WindowAction::Minimize.priority(), 2);
    }

    #[test]
    fn terminal_priority_strictly_dominates_transient() {
        // The whole point of the gate: a same-burst DoubleClick→press
        // sequence whose second event is transient must NOT eat the first
        // event's terminal request.
        assert!(WindowAction::Maximize.priority() > WindowAction::DragMove.priority());
        assert!(WindowAction::Close.priority() > WindowAction::ShowWindowMenu { x: 0, y: 0 }.priority());
    }

    // ── set_window_action — the producer-side race gate ──────────────

    #[test]
    fn set_from_none_accepts_any_request() {
        // The empty / freshly-drained slot must accept the very first
        // producer write of the frame.
        let flag = new_window_action_flag();
        set_window_action(&flag, WindowAction::DragMove);
        assert_eq!(flag.get(), WindowAction::DragMove);

        let flag = new_window_action_flag();
        set_window_action(&flag, WindowAction::Maximize);
        assert_eq!(flag.get(), WindowAction::Maximize);
    }

    #[test]
    fn transient_does_not_overwrite_terminal() {
        // The Task A wave 2 root cause: DoubleClick→Maximize then trailing
        // PointerPress→DragMove. Pre-fix, last-write-wins lost the Maximize;
        // post-fix the gate rejects the DragMove write.
        let flag = new_window_action_flag();
        set_window_action(&flag, WindowAction::Maximize);
        set_window_action(&flag, WindowAction::DragMove);
        assert_eq!(
            flag.get(),
            WindowAction::Maximize,
            "DragMove (priority 1) must not displace Maximize (priority 2)"
        );

exec
/bin/bash -lc "sed -n '620,700p' crates/hayate-platform/src/wayland/connection.rs" in /home/ken/Documents/GUI_kit-task-a-wave2
 exited 2 in 0ms:
sed: crates/hayate-platform/src/wayland/connection.rs を読み込めません: そのようなファイルやディレクトリはありません

exec
/bin/bash -lc "rg -n \"enum WindowAction|set_window_action|action\\.set\\(|WindowAction::None|WindowAction::Maximize|WindowAction::ShowWindowMenu|WindowAction::DragMove|new_window_action_flag|wa\\.set\\(WindowAction::None\\)\" crates" in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
crates/hayate-kit/src/widget/title_bar.rs:14:// (`WindowAction`, `WindowActionFlag`, `new_window_action_flag`) live
crates/hayate-kit/src/widget/title_bar.rs:22:use hayate_platform::window_action::{set_window_action, WindowAction, WindowActionFlag};
crates/hayate-kit/src/widget/title_bar.rs:370:            return Some(WindowAction::Maximize);
crates/hayate-kit/src/widget/title_bar.rs:894:                    set_window_action(&self.action, action);
crates/hayate-kit/src/widget/title_bar.rs:898:                    set_window_action(&self.action, WindowAction::DragMove);
crates/hayate-kit/src/widget/title_bar.rs:910:                    set_window_action(
crates/hayate-kit/src/widget/title_bar.rs:912:                        WindowAction::ShowWindowMenu {
crates/hayate-kit/src/widget/title_bar.rs:925:                            set_window_action(&self.action, WindowAction::Maximize);
crates/hayate-kit/src/widget/title_bar.rs:929:                            set_window_action(&self.action, WindowAction::Minimize);
crates/hayate-kit/src/widget/title_bar.rs:1098:    // `new_window_action_flag` is only consumed by tests; importing it
crates/hayate-kit/src/widget/title_bar.rs:1101:    use hayate_platform::window_action::new_window_action_flag;
crates/hayate-kit/src/widget/title_bar.rs:1130:        let flag = new_window_action_flag();
crates/hayate-kit/src/widget/title_bar.rs:1133:        assert_eq!(flag.get(), WindowAction::None);
crates/hayate-kit/src/widget/title_bar.rs:1140:        let mut tb = TitleBar::new("x", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1153:        let tb = TitleBar::new("Untitled", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1161:        let flag = new_window_action_flag();
crates/hayate-kit/src/widget/title_bar.rs:1183:        let flag = new_window_action_flag();
crates/hayate-kit/src/widget/title_bar.rs:1187:        assert_eq!(flag.get(), WindowAction::Maximize);
crates/hayate-kit/src/widget/title_bar.rs:1194:        let flag = new_window_action_flag();
crates/hayate-kit/src/widget/title_bar.rs:1201:        assert_eq!(flag.get(), WindowAction::DragMove);
crates/hayate-kit/src/widget/title_bar.rs:1206:        let mut tb = TitleBar::new("x", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1226:        let flag = new_window_action_flag();
crates/hayate-kit/src/widget/title_bar.rs:1230:        assert!(matches!(flag.get(), WindowAction::ShowWindowMenu { .. }));
crates/hayate-kit/src/widget/title_bar.rs:1233:        let flag2 = new_window_action_flag();
crates/hayate-kit/src/widget/title_bar.rs:1238:        assert_eq!(flag2.get(), WindowAction::None);
crates/hayate-kit/src/widget/title_bar.rs:1250:        let mut tb = TitleBar::new("static fallback", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1287:    use hayate_platform::window_action::new_window_action_flag;
crates/hayate-kit/src/widget/title_bar.rs:1327:        let tb = TitleBar::new("x", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1336:        let tb = TitleBar::new("Doc", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1349:        let flag = new_window_action_flag();
crates/hayate-kit/src/widget/title_bar.rs:1365:        let mut tb = TitleBar::new("x", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1376:        let mut tb = TitleBar::new("x", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1390:        let mut tb = TitleBar::new("x", new_window_action_flag());
crates/hayate-kit/src/widget/title_bar.rs:1410:        let flag = new_window_action_flag();
crates/hayate-kit/src/widget/title_bar.rs:1443:        let flag = new_window_action_flag();
crates/hayate-kit/src/widget/default_chrome.rs:15://! use hayate_ui::window_action::new_window_action_flag;
crates/hayate-kit/src/widget/default_chrome.rs:20://! let action_flag = new_window_action_flag();
crates/hayate-kit/src/lib.rs:102:    new_window_action_flag, WindowAction, WindowActionFlag,
crates/hayate-kit/tests/golden_a11y_chrome.rs:27:use hayate_platform::window_action::new_window_action_flag;
crates/hayate-kit/tests/golden_a11y_chrome.rs:89:        let title = TitleBar::new("App", new_window_action_flag());
crates/hayate-kit/tests/golden_a11y_chrome.rs:132:        let title = TitleBar::new("App", new_window_action_flag());
crates/hayate-kit/tests/golden_systemlike_chrome.rs:39:use hayate_platform::window_action::new_window_action_flag;
crates/hayate-kit/tests/golden_systemlike_chrome.rs:48:    let mut tb = TitleBar::new(title, new_window_action_flag());
crates/hayate-platform/src/app.rs:1295:            window_action: crate::window_action::new_window_action_flag(),
crates/hayate-platform/src/app_tests_inline.rs:1449:    // (L2 widget) + `use crate::window_action::new_window_action_flag` は
crates/hayate-platform/src/platform/connection.rs:661:                if action != WindowAction::None {
crates/hayate-platform/src/platform/connection.rs:662:                    wa.set(WindowAction::None);
crates/hayate-platform/src/platform/connection.rs:669:                        WindowAction::Maximize => {
crates/hayate-platform/src/platform/connection.rs:684:                        WindowAction::DragMove => {
crates/hayate-platform/src/platform/connection.rs:692:                        WindowAction::ShowWindowMenu { x, y } => {
crates/hayate-platform/src/platform/connection.rs:700:                        WindowAction::None => {}
crates/hayate-platform/src/window_action.rs:22://! - [`new_window_action_flag`] is the one constructor that seeds the
crates/hayate-platform/src/window_action.rs:23://!   cell with `WindowAction::None`.
crates/hayate-platform/src/window_action.rs:34:/// [`WindowAction::None`] so subsequent frames start clean.
crates/hayate-platform/src/window_action.rs:36:pub enum WindowAction {
crates/hayate-platform/src/window_action.rs:57:    /// Priority level used by [`set_window_action`] to resolve the producer-side
crates/hayate-platform/src/window_action.rs:60:    /// - **0 — empty slot**: [`WindowAction::None`] is the initial / drained
crates/hayate-platform/src/window_action.rs:62:    /// - **1 — transient**: [`WindowAction::DragMove`] and
crates/hayate-platform/src/window_action.rs:63:    ///   [`WindowAction::ShowWindowMenu`] are compositor-driven gestures that
crates/hayate-platform/src/window_action.rs:67:    /// - **2 — terminal**: [`WindowAction::Close`], [`WindowAction::Maximize`],
crates/hayate-platform/src/window_action.rs:74:            WindowAction::None => 0,
crates/hayate-platform/src/window_action.rs:75:            WindowAction::DragMove | WindowAction::ShowWindowMenu { .. } => 1,
crates/hayate-platform/src/window_action.rs:76:            WindowAction::Close | WindowAction::Maximize | WindowAction::Minimize => 2,
crates/hayate-platform/src/window_action.rs:82:/// Constructed via [`new_window_action_flag`].
crates/hayate-platform/src/window_action.rs:85:/// Construct a fresh [`WindowActionFlag`] initialised to [`WindowAction::None`].
crates/hayate-platform/src/window_action.rs:86:pub fn new_window_action_flag() -> WindowActionFlag {
crates/hayate-platform/src/window_action.rs:87:    Rc::new(Cell::new(WindowAction::None))
crates/hayate-platform/src/window_action.rs:94:/// resets the cell with a plain `flag.set(WindowAction::None)` after consuming,
crates/hayate-platform/src/window_action.rs:111:pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
crates/hayate-platform/src/window_action.rs:125:        assert_eq!(WindowAction::None.priority(), 0);
crates/hayate-platform/src/window_action.rs:130:        assert_eq!(WindowAction::DragMove.priority(), 1);
crates/hayate-platform/src/window_action.rs:132:            WindowAction::ShowWindowMenu { x: 0, y: 0 }.priority(),
crates/hayate-platform/src/window_action.rs:140:        assert_eq!(WindowAction::Maximize.priority(), 2);
crates/hayate-platform/src/window_action.rs:149:        assert!(WindowAction::Maximize.priority() > WindowAction::DragMove.priority());
crates/hayate-platform/src/window_action.rs:150:        assert!(WindowAction::Close.priority() > WindowAction::ShowWindowMenu { x: 0, y: 0 }.priority());
crates/hayate-platform/src/window_action.rs:153:    // ── set_window_action — the producer-side race gate ──────────────
crates/hayate-platform/src/window_action.rs:159:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:160:        set_window_action(&flag, WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:161:        assert_eq!(flag.get(), WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:163:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:164:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:165:        assert_eq!(flag.get(), WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:173:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:174:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:175:        set_window_action(&flag, WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:178:            WindowAction::Maximize,
crates/hayate-platform/src/window_action.rs:183:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:184:        set_window_action(&flag, WindowAction::Close);
crates/hayate-platform/src/window_action.rs:185:        set_window_action(&flag, WindowAction::ShowWindowMenu { x: 10, y: 20 });
crates/hayate-platform/src/window_action.rs:195:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:196:        set_window_action(&flag, WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:197:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:198:        assert_eq!(flag.get(), WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:206:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:207:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:208:        set_window_action(&flag, WindowAction::Close);
crates/hayate-platform/src/window_action.rs:211:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:212:        set_window_action(&flag, WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:213:        set_window_action(&flag, WindowAction::ShowWindowMenu { x: 5, y: 7 });
crates/hayate-platform/src/window_action.rs:214:        assert_eq!(flag.get(), WindowAction::ShowWindowMenu { x: 5, y: 7 });
crates/hayate-platform/src/window_action.rs:218:    fn set_window_action_to_none_is_a_noop_against_pending_request() {
crates/hayate-platform/src/window_action.rs:220:        // this slot" reset uses `flag.set(WindowAction::None)` directly
crates/hayate-platform/src/window_action.rs:224:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:225:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:226:        set_window_action(&flag, WindowAction::None);
crates/hayate-platform/src/window_action.rs:229:            WindowAction::Maximize,
crates/hayate-platform/src/window_action.rs:230:            "set_window_action(None) must not displace a pending request — the dispatcher uses Cell::set directly to reset"
crates/hayate-platform/src/window_action.rs:237:        // (`let action = wa.get(); ...; wa.set(WindowAction::None);`) is
crates/hayate-platform/src/window_action.rs:241:        let flag = new_window_action_flag();
crates/hayate-platform/src/window_action.rs:242:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:244:        flag.set(WindowAction::None); // ← dispatcher pattern, gate-bypassing
crates/hayate-platform/src/window_action.rs:245:        assert_eq!(drained, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:246:        assert_eq!(flag.get(), WindowAction::None);

exec
/bin/bash -lc "sed -n '860,940p' crates/hayate-kit/src/widget/title_bar.rs" in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
                tcol.r,
                tcol.g,
                tcol.b,
                max_w,
            );
        }

        // Bottom border
        if th.border_width > 0.0 {
            let br = ItemRect::new(
                rect.x,
                rect.y + th.height - th.border_width,
                rect.width,
                th.border_width,
            );
            renderer.fill_rect(
                &br,
                th.border_color.r,
                th.border_color.g,
                th.border_color.b,
                255,
            );
        }
    }

    fn event(&mut self, event: &WidgetEvent) -> EventResponse {
        match event {
            WidgetEvent::PointerPress {
                x,
                y,
                button: 0x110,
                ..
            } => {
                if let Some(action) = self.hit_test_button(*x, *y) {
                    set_window_action(&self.action, action);
                    return EventResponse::Handled;
                }
                if self.is_in_bar_non_button(*x, *y) {
                    set_window_action(&self.action, WindowAction::DragMove);
                    return EventResponse::Handled;
                }
                EventResponse::Ignored
            }
            WidgetEvent::PointerPress {
                x,
                y,
                button: 0x111,
                ..
            } => {
                if self.policy.right_click_menu && self.is_in_bar_non_button(*x, *y) {
                    set_window_action(
                        &self.action,
                        WindowAction::ShowWindowMenu {
                            x: *x as i32,
                            y: *y as i32,
                        },
                    );
                    return EventResponse::Handled;
                }
                EventResponse::Ignored
            }
            WidgetEvent::DoubleClick { x, y, .. } => {
                if self.is_in_bar_non_button(*x, *y) {
                    match self.policy.double_click_action {
                        DoubleClickAction::ToggleMaximize => {
                            set_window_action(&self.action, WindowAction::Maximize);
                            return EventResponse::Handled;
                        }
                        DoubleClickAction::Minimize => {
                            set_window_action(&self.action, WindowAction::Minimize);
                            return EventResponse::Handled;
                        }
                        DoubleClickAction::None => {}
                    }
                }
                EventResponse::Ignored
            }
            WidgetEvent::PointerMove { x, y } => {
                let in_bar = *y >= self.bar_rect.y && *y < self.bar_rect.y + self.theme.height;
                let (close_r, max_r, min_r) = self.button_rects();
                let nc = in_bar && close_r.contains(*x, *y);

codex
The relevant dispatcher is in `crates/hayate-platform/src/platform/connection.rs`, not a Wayland subdir. I’m checking that drain/reset path and then scanning the repo for any other `WindowActionFlag` producers that still bypass the helper, because that’s the main place this pattern could still be fragile.
exec
/bin/bash -lc "sed -n '648,708p' crates/hayate-platform/src/platform/connection.rs" in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
            //   compositor handles translation → works correctly.
            // - ibus D-Bus SetCursorLocation: skipped on Wayland to avoid wrong position.
            //   ibus will use its default placement (usually near input focus).
            if let Some(ref cr) = window!(self).ime_cursor_rect
                && let Some((x, y, w, h)) = cr.take()
            {
                self.ime_state.set_cursor_rect(x, y, w, h);
            }

            // Process CSD window actions
            if let Some(ref wa) = window!(self).window_action {
                use crate::window_action::WindowAction;
                let action = wa.get();
                if action != WindowAction::None {
                    wa.set(WindowAction::None);
                    match action {
                        WindowAction::Close => {
                            if let Some(ref qf) = window!(self).quit_flag {
                                qf.set(true);
                            }
                        }
                        WindowAction::Maximize => {
                            if let Some(ref toplevel) = window!(self).xdg_toplevel {
                                if window!(self).is_maximized {
                                    toplevel.unset_maximized();
                                } else {
                                    toplevel.set_maximized();
                                }
                                window_mut!(self).is_maximized = !window_mut!(self).is_maximized;
                            }
                        }
                        WindowAction::Minimize => {
                            if let Some(ref toplevel) = window!(self).xdg_toplevel {
                                toplevel.set_minimized();
                            }
                        }
                        WindowAction::DragMove => {
                            let serial = window!(self).pointer_serial;
                            // Strategy (b) clone-snapshot.
                            let toplevel_snap = window!(self).xdg_toplevel.clone();
                            if let (Some(toplevel), Some(seat)) = (toplevel_snap.as_ref(), self.seat.as_ref()) {
                                toplevel._move(seat, serial);
                            }
                        }
                        WindowAction::ShowWindowMenu { x, y } => {
                            let serial = window!(self).pointer_serial;
                            // Strategy (b) clone-snapshot.
                            let toplevel_snap = window!(self).xdg_toplevel.clone();
                            if let (Some(toplevel), Some(seat)) = (toplevel_snap.as_ref(), self.seat.as_ref()) {
                                toplevel.show_window_menu(seat, serial, x, y);
                            }
                        }
                        WindowAction::None => {}
                    }
                }
            }

            // Process pending DnD drop — read parsed payload now that we have
            // Connection access. App-managed conn (RFC v0.2 §9.4 option C):
            // platform layer reads all standard MIMEs, then hands parsed data
            // to widget tier via `WindowEvent::DragDrop`. Legacy `FileDrop` is

exec
/bin/bash -lc "rg -n \"WindowAction::(Close|Maximize|Minimize|DragMove|ShowWindowMenu|None)|set_window_action\\(|window_action.*set\\(|action\\.set\\(|\\.set\\(WindowAction::\" crates apps examples" in /home/ken/Documents/GUI_kit-task-a-wave2
 exited 2 in 0ms:
rg: apps: No such file or directory (os error 2)
rg: examples: No such file or directory (os error 2)
crates/hayate-kit/src/widget/title_bar.rs:367:            return Some(WindowAction::Close);
crates/hayate-kit/src/widget/title_bar.rs:370:            return Some(WindowAction::Maximize);
crates/hayate-kit/src/widget/title_bar.rs:373:            return Some(WindowAction::Minimize);
crates/hayate-kit/src/widget/title_bar.rs:894:                    set_window_action(&self.action, action);
crates/hayate-kit/src/widget/title_bar.rs:898:                    set_window_action(&self.action, WindowAction::DragMove);
crates/hayate-kit/src/widget/title_bar.rs:910:                    set_window_action(
crates/hayate-kit/src/widget/title_bar.rs:912:                        WindowAction::ShowWindowMenu {
crates/hayate-kit/src/widget/title_bar.rs:925:                            set_window_action(&self.action, WindowAction::Maximize);
crates/hayate-kit/src/widget/title_bar.rs:929:                            set_window_action(&self.action, WindowAction::Minimize);
crates/hayate-kit/src/widget/title_bar.rs:1133:        assert_eq!(flag.get(), WindowAction::None);
crates/hayate-kit/src/widget/title_bar.rs:1170:        assert_eq!(flag.get(), WindowAction::Close);
crates/hayate-kit/src/widget/title_bar.rs:1187:        assert_eq!(flag.get(), WindowAction::Maximize);
crates/hayate-kit/src/widget/title_bar.rs:1189:        assert_eq!(flag.get(), WindowAction::Minimize);
crates/hayate-kit/src/widget/title_bar.rs:1201:        assert_eq!(flag.get(), WindowAction::DragMove);
crates/hayate-kit/src/widget/title_bar.rs:1230:        assert!(matches!(flag.get(), WindowAction::ShowWindowMenu { .. }));
crates/hayate-kit/src/widget/title_bar.rs:1238:        assert_eq!(flag2.get(), WindowAction::None);
crates/hayate-kit/src/widget/title_bar.rs:1347:        // plus the `WindowAction::Close` flag — i.e. the same end-to-end
crates/hayate-kit/src/widget/title_bar.rs:1357:        assert_eq!(flag.get(), WindowAction::Close);
crates/hayate-kit/src/widget/default_chrome.rs:60:///   raises [`WindowAction::Close`](hayate_platform::window_action::WindowAction::Close)
crates/hayate-platform/src/platform/connection.rs:661:                if action != WindowAction::None {
crates/hayate-platform/src/platform/connection.rs:662:                    wa.set(WindowAction::None);
crates/hayate-platform/src/platform/connection.rs:664:                        WindowAction::Close => {
crates/hayate-platform/src/platform/connection.rs:669:                        WindowAction::Maximize => {
crates/hayate-platform/src/platform/connection.rs:679:                        WindowAction::Minimize => {
crates/hayate-platform/src/platform/connection.rs:684:                        WindowAction::DragMove => {
crates/hayate-platform/src/platform/connection.rs:692:                        WindowAction::ShowWindowMenu { x, y } => {
crates/hayate-platform/src/platform/connection.rs:700:                        WindowAction::None => {}
crates/hayate-platform/src/window_action.rs:23://!   cell with `WindowAction::None`.
crates/hayate-platform/src/window_action.rs:34:/// [`WindowAction::None`] so subsequent frames start clean.
crates/hayate-platform/src/window_action.rs:60:    /// - **0 — empty slot**: [`WindowAction::None`] is the initial / drained
crates/hayate-platform/src/window_action.rs:62:    /// - **1 — transient**: [`WindowAction::DragMove`] and
crates/hayate-platform/src/window_action.rs:63:    ///   [`WindowAction::ShowWindowMenu`] are compositor-driven gestures that
crates/hayate-platform/src/window_action.rs:67:    /// - **2 — terminal**: [`WindowAction::Close`], [`WindowAction::Maximize`],
crates/hayate-platform/src/window_action.rs:68:    ///   and [`WindowAction::Minimize`] change persistent window state and
crates/hayate-platform/src/window_action.rs:74:            WindowAction::None => 0,
crates/hayate-platform/src/window_action.rs:75:            WindowAction::DragMove | WindowAction::ShowWindowMenu { .. } => 1,
crates/hayate-platform/src/window_action.rs:76:            WindowAction::Close | WindowAction::Maximize | WindowAction::Minimize => 2,
crates/hayate-platform/src/window_action.rs:85:/// Construct a fresh [`WindowActionFlag`] initialised to [`WindowAction::None`].
crates/hayate-platform/src/window_action.rs:87:    Rc::new(Cell::new(WindowAction::None))
crates/hayate-platform/src/window_action.rs:94:/// resets the cell with a plain `flag.set(WindowAction::None)` after consuming,
crates/hayate-platform/src/window_action.rs:111:pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
crates/hayate-platform/src/window_action.rs:125:        assert_eq!(WindowAction::None.priority(), 0);
crates/hayate-platform/src/window_action.rs:130:        assert_eq!(WindowAction::DragMove.priority(), 1);
crates/hayate-platform/src/window_action.rs:132:            WindowAction::ShowWindowMenu { x: 0, y: 0 }.priority(),
crates/hayate-platform/src/window_action.rs:139:        assert_eq!(WindowAction::Close.priority(), 2);
crates/hayate-platform/src/window_action.rs:140:        assert_eq!(WindowAction::Maximize.priority(), 2);
crates/hayate-platform/src/window_action.rs:141:        assert_eq!(WindowAction::Minimize.priority(), 2);
crates/hayate-platform/src/window_action.rs:149:        assert!(WindowAction::Maximize.priority() > WindowAction::DragMove.priority());
crates/hayate-platform/src/window_action.rs:150:        assert!(WindowAction::Close.priority() > WindowAction::ShowWindowMenu { x: 0, y: 0 }.priority());
crates/hayate-platform/src/window_action.rs:160:        set_window_action(&flag, WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:161:        assert_eq!(flag.get(), WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:164:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:165:        assert_eq!(flag.get(), WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:174:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:175:        set_window_action(&flag, WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:178:            WindowAction::Maximize,
crates/hayate-platform/src/window_action.rs:184:        set_window_action(&flag, WindowAction::Close);
crates/hayate-platform/src/window_action.rs:185:        set_window_action(&flag, WindowAction::ShowWindowMenu { x: 10, y: 20 });
crates/hayate-platform/src/window_action.rs:186:        assert_eq!(flag.get(), WindowAction::Close);
crates/hayate-platform/src/window_action.rs:196:        set_window_action(&flag, WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:197:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:198:        assert_eq!(flag.get(), WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:207:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:208:        set_window_action(&flag, WindowAction::Close);
crates/hayate-platform/src/window_action.rs:209:        assert_eq!(flag.get(), WindowAction::Close);
crates/hayate-platform/src/window_action.rs:212:        set_window_action(&flag, WindowAction::DragMove);
crates/hayate-platform/src/window_action.rs:213:        set_window_action(&flag, WindowAction::ShowWindowMenu { x: 5, y: 7 });
crates/hayate-platform/src/window_action.rs:214:        assert_eq!(flag.get(), WindowAction::ShowWindowMenu { x: 5, y: 7 });
crates/hayate-platform/src/window_action.rs:220:        // this slot" reset uses `flag.set(WindowAction::None)` directly
crates/hayate-platform/src/window_action.rs:225:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:226:        set_window_action(&flag, WindowAction::None);
crates/hayate-platform/src/window_action.rs:229:            WindowAction::Maximize,
crates/hayate-platform/src/window_action.rs:230:            "set_window_action(None) must not displace a pending request — the dispatcher uses Cell::set directly to reset"
crates/hayate-platform/src/window_action.rs:237:        // (`let action = wa.get(); ...; wa.set(WindowAction::None);`) is
crates/hayate-platform/src/window_action.rs:242:        set_window_action(&flag, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:244:        flag.set(WindowAction::None); // ← dispatcher pattern, gate-bypassing
crates/hayate-platform/src/window_action.rs:245:        assert_eq!(drained, WindowAction::Maximize);
crates/hayate-platform/src/window_action.rs:246:        assert_eq!(flag.get(), WindowAction::None);

exec
/bin/bash -lc "sed -n '340,380p' crates/hayate-kit/src/widget/title_bar.rs" in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
                    let max = ItemRect::new(min.x + bw + gap, by, bw, bh);
                    (close, max, min)
                } else {
                    let close = ItemRect::new(rect.x + 4.0, by, bw, bh);
                    let min = ItemRect::new(close.x + bw + 2.0, by, bw, bh);
                    let max = ItemRect::new(min.x + bw, by, bw, bh);
                    (close, max, min)
                }
            }
            ButtonSide::MacClassic => {
                // Platinum split: close box on the left; on the right the zoom
                // (maximize) box then the rightmost WindowShade collapse
                // (minimize) box — matching a real Mac OS 9 capture.
                let close = ItemRect::new(rect.x + 6.0, by, bw, bh);
                let min = ItemRect::new(rect.x + rect.width - bw - 6.0, by, bw, bh);
                let max = ItemRect::new(min.x - bw - 4.0, by, bw, bh);
                (close, max, min)
            }
        }
    }

    fn hit_test_button(&self, x: f32, y: f32) -> Option<WindowAction> {
        if y < self.bar_rect.y || y >= self.bar_rect.y + self.theme.height {
            return None;
        }
        let (close, max, min) = self.button_rects();
        if close.contains(x, y) {
            return Some(WindowAction::Close);
        }
        if max.contains(x, y) {
            return Some(WindowAction::Maximize);
        }
        if min.contains(x, y) {
            return Some(WindowAction::Minimize);
        }
        None
    }

    fn is_in_bar_non_button(&self, x: f32, y: f32) -> bool {
        if y < self.bar_rect.y || y >= self.bar_rect.y + self.theme.height {
            return false;

codex
I’ve confirmed the dispatcher drains by `get()` then unconditional direct reset before dispatch, which makes the `None` bypass argument internally consistent. The remaining question is whether the helper’s “use this from every producer site” claim matches the actual repo, especially in the L2/L3 app code the PR body scopes out.
exec
/bin/bash -lc "find . -maxdepth 3 -type d | sed -n '1,200p'" in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
.
./.codex
./.agents
./docs
./docs/archive
./docs/archive/handoff
./docs/phase3b
./paper
./crates
./crates/hayate-ui
./crates/hayate-ui/tests
./crates/hayate-ui/src
./crates/hayate-platform
./crates/hayate-platform/examples
./crates/hayate-platform/benches
./crates/hayate-platform/shaders
./crates/hayate-platform/tests
./crates/hayate-platform/assets
./crates/hayate-platform/src
./crates/hayate-kit
./crates/hayate-kit/examples
./crates/hayate-kit/benches
./crates/hayate-kit/tests
./crates/hayate-kit/src
./tools
./tools/dead-callsite-check
./tools/dead-callsite-check/src
./bench_runs
./bench_runs/2026-04-16
./bench_runs/baseline
./bench_runs/2026-04-15
./scripts
./src
./src/widget
./workspace
./workspace/boss1-notes
./workspace/worker1-notes
./workspace/worker3-notes
./workspace/worker2-notes
./workspace/worker2-notes/_archive
./workspace/president-notes
./target
./target/tmp
./target/debug
./target/debug/deps
./target/debug/incremental
./target/debug/examples
./target/debug/.fingerprint
./target/debug/build
./.github
./.github/workflows

exec
/bin/bash -lc 'git diff --stat 458d6c5..HEAD' in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
 crates/hayate-kit/src/widget/title_bar.rs   |  21 ++--
 crates/hayate-platform/src/window_action.rs | 185 ++++++++++++++++++++++++++++
 2 files changed, 197 insertions(+), 9 deletions(-)

exec
/bin/bash -lc "rg -n \"\\.set\\(WindowAction::Close\\)|\\.set\\(WindowAction::Maximize\\)|\\.set\\(WindowAction::Minimize\\)|\\.set\\(WindowAction::DragMove\\)|\\.set\\(WindowAction::ShowWindowMenu|WindowActionFlag|new_window_action_flag\\(\" ." in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
./crates/hayate-kit/src/widget/title_bar.rs:14:// (`WindowAction`, `WindowActionFlag`, `new_window_action_flag`) live
./crates/hayate-kit/src/widget/title_bar.rs:22:use hayate_platform::window_action::{set_window_action, WindowAction, WindowActionFlag};
./crates/hayate-kit/src/widget/title_bar.rs:173:    action: WindowActionFlag,
./crates/hayate-kit/src/widget/title_bar.rs:191:    /// [`WindowActionFlag`]. Uses the default [`WindowPolicy`].
./crates/hayate-kit/src/widget/title_bar.rs:192:    pub fn new(title: impl Into<String>, action: WindowActionFlag) -> Self {
./crates/hayate-kit/src/widget/title_bar.rs:201:        action: WindowActionFlag,
./crates/hayate-kit/src/widget/title_bar.rs:1130:        let flag = new_window_action_flag();
./crates/hayate-kit/src/widget/title_bar.rs:1140:        let mut tb = TitleBar::new("x", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1153:        let tb = TitleBar::new("Untitled", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1161:        let flag = new_window_action_flag();
./crates/hayate-kit/src/widget/title_bar.rs:1183:        let flag = new_window_action_flag();
./crates/hayate-kit/src/widget/title_bar.rs:1194:        let flag = new_window_action_flag();
./crates/hayate-kit/src/widget/title_bar.rs:1206:        let mut tb = TitleBar::new("x", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1226:        let flag = new_window_action_flag();
./crates/hayate-kit/src/widget/title_bar.rs:1233:        let flag2 = new_window_action_flag();
./crates/hayate-kit/src/widget/title_bar.rs:1250:        let mut tb = TitleBar::new("static fallback", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1327:        let tb = TitleBar::new("x", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1336:        let tb = TitleBar::new("Doc", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1349:        let flag = new_window_action_flag();
./crates/hayate-kit/src/widget/title_bar.rs:1365:        let mut tb = TitleBar::new("x", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1376:        let mut tb = TitleBar::new("x", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1390:        let mut tb = TitleBar::new("x", new_window_action_flag());
./crates/hayate-kit/src/widget/title_bar.rs:1410:        let flag = new_window_action_flag();
./crates/hayate-kit/src/widget/title_bar.rs:1443:        let flag = new_window_action_flag();
./crates/hayate-kit/src/widget/default_chrome.rs:20://! let action_flag = new_window_action_flag();
./crates/hayate-kit/src/widget/default_chrome.rs:42:use hayate_platform::window_action::WindowActionFlag;
./crates/hayate-kit/src/widget/default_chrome.rs:59:/// - `window_action` — shared [`WindowActionFlag`] the title bar
./crates/hayate-kit/src/widget/default_chrome.rs:74:    window_action: &WindowActionFlag,
./crates/hayate-kit/src/lib.rs:102:    new_window_action_flag, WindowAction, WindowActionFlag,
./crates/hayate-kit/tests/golden_a11y_chrome.rs:89:        let title = TitleBar::new("App", new_window_action_flag());
./crates/hayate-kit/tests/golden_a11y_chrome.rs:132:        let title = TitleBar::new("App", new_window_action_flag());
./crates/hayate-kit/tests/golden_systemlike_chrome.rs:48:    let mut tb = TitleBar::new(title, new_window_action_flag());
./crates/hayate-platform/src/widget/adapter.rs:32://! `WindowActionFlag`) that are `!Send` by design (Rc/RefCell chosen
./crates/hayate-platform/src/lib.rs:21://! - `window_action` (WindowAction enum + WindowActionFlag、L0 v2.1 §14.1
./workspace/president-notes/hayate-kit-settings-rfc-v0.1.md:354:2. ✅ **GUI_kit hayate-kit public API extension** = GUI_kit `d64cd87` (= 14 件 re-export、 App / AppConfig / Decorations / Theme / Color / set_active_theme / WindowAction / WindowActionFlag / new_window_action_flag / WindowPolicy / ButtonSide / DoubleClickAction / ButtonOrder / BitmapTextStyle / FontFamily / Reactive subscription model + Widget trait + 関連 type は後段 `0e49927` で追加)
./crates/hayate-platform/src/app.rs:1233:    window_action: crate::window_action::WindowActionFlag,
./crates/hayate-platform/src/app.rs:1295:            window_action: crate::window_action::new_window_action_flag(),
./crates/hayate-platform/src/app.rs:1669:    pub fn window_action(&self) -> crate::window_action::WindowActionFlag {
./crates/hayate-platform/src/window_action.rs:18://! - [`WindowActionFlag`] is a shared single-cell typedef
./crates/hayate-platform/src/window_action.rs:31:/// The producer writes the next action into a [`WindowActionFlag`]; the
./crates/hayate-platform/src/window_action.rs:83:pub type WindowActionFlag = Rc<Cell<WindowAction>>;
./crates/hayate-platform/src/window_action.rs:85:/// Construct a fresh [`WindowActionFlag`] initialised to [`WindowAction::None`].
./crates/hayate-platform/src/window_action.rs:86:pub fn new_window_action_flag() -> WindowActionFlag {
./crates/hayate-platform/src/window_action.rs:90:/// Priority-aware producer-side setter for [`WindowActionFlag`].
./crates/hayate-platform/src/window_action.rs:111:pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
./crates/hayate-platform/src/window_action.rs:159:        let flag = new_window_action_flag();
./crates/hayate-platform/src/window_action.rs:163:        let flag = new_window_action_flag();
./crates/hayate-platform/src/window_action.rs:173:        let flag = new_window_action_flag();
./crates/hayate-platform/src/window_action.rs:183:        let flag = new_window_action_flag();
./crates/hayate-platform/src/window_action.rs:195:        let flag = new_window_action_flag();
./crates/hayate-platform/src/window_action.rs:206:        let flag = new_window_action_flag();
./crates/hayate-platform/src/window_action.rs:211:        let flag = new_window_action_flag();
./crates/hayate-platform/src/window_action.rs:224:        let flag = new_window_action_flag();
./crates/hayate-platform/src/window_action.rs:241:        let flag = new_window_action_flag();
./workspace/worker2-notes/L1-commit-7-decorations-breaking-draft.md:54:    window_action: &crate::widget::window_action::WindowActionFlag,
./workspace/worker3-notes/codex_pr212_round1.md:40:4. **L2/L3 scope-out + Restore omission**: PR body scope-outs the 5 L2/L3 menu-Exit callsites (hayate-explorer / hayate-notepad{,-l2,-track-r2-1c} / hayate-freecell) that still use plain `.set(WindowAction::Close)` on the grounds they fire isolated terminal writes without in-burst transient racers. Is that defensible (could a future feature land a transient producer in those apps and re-introduce the bug?), and is the "no Restore variant" decision sufficient or should the PR body call out that any *future* terminal variant must land with both a `priority()` arm and a regression test?
./workspace/worker3-notes/codex_pr212_round1.md:60:-use hayate_platform::window_action::{WindowAction, WindowActionFlag};
./workspace/worker3-notes/codex_pr212_round1.md:61:+use hayate_platform::window_action::{set_window_action, WindowAction, WindowActionFlag};
./workspace/worker3-notes/codex_pr212_round1.md:74:-                    self.action.set(WindowAction::DragMove);
./workspace/worker3-notes/codex_pr212_round1.md:83:-                    self.action.set(WindowAction::ShowWindowMenu {
./workspace/worker3-notes/codex_pr212_round1.md:101:-                            self.action.set(WindowAction::Maximize);
./workspace/worker3-notes/codex_pr212_round1.md:106:-                            self.action.set(WindowAction::Minimize);
./workspace/worker3-notes/codex_pr212_round1.md:146: pub type WindowActionFlag = Rc<Cell<WindowAction>>;
./workspace/worker3-notes/codex_pr212_round1.md:147:@@ -61,3 +86,163 @@ pub type WindowActionFlag = Rc<Cell<WindowAction>>;
./workspace/worker3-notes/codex_pr212_round1.md:148: pub fn new_window_action_flag() -> WindowActionFlag {
./workspace/worker3-notes/codex_pr212_round1.md:152:+/// Priority-aware producer-side setter for [`WindowActionFlag`].
./workspace/worker3-notes/codex_pr212_round1.md:173:+pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
./workspace/worker3-notes/codex_pr212_round1.md:221:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:225:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:235:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:245:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:257:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:268:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:273:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:286:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:303:+        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:342://! - [`WindowActionFlag`] is a shared single-cell typedef
./workspace/worker3-notes/codex_pr212_round1.md:355:/// The producer writes the next action into a [`WindowActionFlag`]; the
./workspace/worker3-notes/codex_pr212_round1.md:407:pub type WindowActionFlag = Rc<Cell<WindowAction>>;
./workspace/worker3-notes/codex_pr212_round1.md:409:/// Construct a fresh [`WindowActionFlag`] initialised to [`WindowAction::None`].
./workspace/worker3-notes/codex_pr212_round1.md:410:pub fn new_window_action_flag() -> WindowActionFlag {
./workspace/worker3-notes/codex_pr212_round1.md:414:/// Priority-aware producer-side setter for [`WindowActionFlag`].
./workspace/worker3-notes/codex_pr212_round1.md:435:pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
./workspace/worker3-notes/codex_pr212_round1.md:483:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:487:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:497:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:514:crates/hayate-kit/src/widget/title_bar.rs:14:// (`WindowAction`, `WindowActionFlag`, `new_window_action_flag`) live
./workspace/worker3-notes/codex_pr212_round1.md:515:crates/hayate-kit/src/widget/title_bar.rs:22:use hayate_platform::window_action::{set_window_action, WindowAction, WindowActionFlag};
./workspace/worker3-notes/codex_pr212_round1.md:525:crates/hayate-kit/src/widget/title_bar.rs:1130:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:527:crates/hayate-kit/src/widget/title_bar.rs:1140:        let mut tb = TitleBar::new("x", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:528:crates/hayate-kit/src/widget/title_bar.rs:1153:        let tb = TitleBar::new("Untitled", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:529:crates/hayate-kit/src/widget/title_bar.rs:1161:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:530:crates/hayate-kit/src/widget/title_bar.rs:1183:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:532:crates/hayate-kit/src/widget/title_bar.rs:1194:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:534:crates/hayate-kit/src/widget/title_bar.rs:1206:        let mut tb = TitleBar::new("x", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:535:crates/hayate-kit/src/widget/title_bar.rs:1226:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:537:crates/hayate-kit/src/widget/title_bar.rs:1233:        let flag2 = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:539:crates/hayate-kit/src/widget/title_bar.rs:1250:        let mut tb = TitleBar::new("static fallback", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:541:crates/hayate-kit/src/widget/title_bar.rs:1327:        let tb = TitleBar::new("x", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:542:crates/hayate-kit/src/widget/title_bar.rs:1336:        let tb = TitleBar::new("Doc", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:543:crates/hayate-kit/src/widget/title_bar.rs:1349:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:544:crates/hayate-kit/src/widget/title_bar.rs:1365:        let mut tb = TitleBar::new("x", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:545:crates/hayate-kit/src/widget/title_bar.rs:1376:        let mut tb = TitleBar::new("x", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:546:crates/hayate-kit/src/widget/title_bar.rs:1390:        let mut tb = TitleBar::new("x", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:547:crates/hayate-kit/src/widget/title_bar.rs:1410:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:548:crates/hayate-kit/src/widget/title_bar.rs:1443:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:550:crates/hayate-kit/src/widget/default_chrome.rs:20://! let action_flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:551:crates/hayate-kit/src/lib.rs:102:    new_window_action_flag, WindowAction, WindowActionFlag,
./workspace/worker3-notes/codex_pr212_round1.md:553:crates/hayate-kit/tests/golden_a11y_chrome.rs:89:        let title = TitleBar::new("App", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:554:crates/hayate-kit/tests/golden_a11y_chrome.rs:132:        let title = TitleBar::new("App", new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:556:crates/hayate-kit/tests/golden_systemlike_chrome.rs:48:    let mut tb = TitleBar::new(title, new_window_action_flag());
./workspace/worker3-notes/codex_pr212_round1.md:557:crates/hayate-platform/src/app.rs:1295:            window_action: crate::window_action::new_window_action_flag(),
./workspace/worker3-notes/codex_pr212_round1.md:578:crates/hayate-platform/src/window_action.rs:85:/// Construct a fresh [`WindowActionFlag`] initialised to [`WindowAction::None`].
./workspace/worker3-notes/codex_pr212_round1.md:579:crates/hayate-platform/src/window_action.rs:86:pub fn new_window_action_flag() -> WindowActionFlag {
./workspace/worker3-notes/codex_pr212_round1.md:582:crates/hayate-platform/src/window_action.rs:111:pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
./workspace/worker3-notes/codex_pr212_round1.md:590:crates/hayate-platform/src/window_action.rs:159:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:593:crates/hayate-platform/src/window_action.rs:163:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:596:crates/hayate-platform/src/window_action.rs:173:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:600:crates/hayate-platform/src/window_action.rs:183:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:603:crates/hayate-platform/src/window_action.rs:195:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:607:crates/hayate-platform/src/window_action.rs:206:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:610:crates/hayate-platform/src/window_action.rs:211:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:616:crates/hayate-platform/src/window_action.rs:224:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:622:crates/hayate-platform/src/window_action.rs:241:        let flag = new_window_action_flag();
./workspace/worker3-notes/codex_pr212_round1.md:714:The relevant dispatcher is in `crates/hayate-platform/src/platform/connection.rs`, not a Wayland subdir. I’m checking that drain/reset path and then scanning the repo for any other `WindowActionFlag` producers that still bypass the helper, because that’s the main place this pattern could still be fragile.
./workspace/worker3-notes/codex_pr212_round1.md:822:crates/hayate-platform/src/window_action.rs:85:/// Construct a fresh [`WindowActionFlag`] initialised to [`WindowAction::None`].
./workspace/worker3-notes/codex_pr212_round1.md:825:crates/hayate-platform/src/window_action.rs:111:pub fn set_window_action(flag: &WindowActionFlag, new: WindowAction) {
./workspace/worker1-notes/window-decoration-unification-rfc-draft.md:67:    pub fn new(title: impl Into<String>, action: WindowActionFlag) -> Self;
./workspace/worker1-notes/window-decoration-unification-rfc-draft.md:77:pub fn new_window_action_flag() -> WindowActionFlag;
./workspace/worker1-notes/window-decoration-unification-rfc-draft.md:96:    pub fn with_action(self, action: WindowActionFlag) -> Self;
./workspace/worker1-notes/window-decoration-unification-rfc-draft.md:97:    pub fn action_flag(&self) -> WindowActionFlag;
./workspace/worker1-notes/window-decoration-unification-rfc-draft.md:215:- TitleBar が WindowAction 等を `WindowActionFlag` 経由で App と共有する pattern は維持可
./workspace/worker2-notes/L1-adapter-trait-draft.md:398:   - TitleBar の `bound_title: Rc<RefCell<String>>` / `engine: Rc<RefCell<TextEngine>>` / `WindowActionFlag (Rc<Cell<WindowAction>>)` 3 fields = !Send
./docs/L0-layer-separation-spec.md:1418:- `src/widget/window_action.rs` (v2.1 訂正、§14.2.9 から L1 配置に再分類、Phase L1 Stage 3 commit 11 で hayate-platform/src/window_action.rs へ move): WindowAction enum + WindowActionFlag (platform-facing signal、module doc 「the title bar writes into and the platform layer reads to drive xdg_toplevel」明記)

codex
The code search shows no other `WindowAction` producers under `crates/`; the scope-out references appear to live outside the library crates. I’m checking the app tree under `src/` to see whether those direct `Close` writes still exist and whether they’re structurally isolated from title-bar gesture producers.
exec
/bin/bash -lc "find src -maxdepth 2 -type f | sed -n '1,200p'" in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
src/lib.rs
src/widget/mod.rs

exec
/bin/bash -lc "rg -n \"WindowAction::Close|window_action\\(|new_window_action_flag|\\.set\\(WindowAction::Close\\)\" src" in /home/ken/Documents/GUI_kit-task-a-wave2
 exited 1 in 0ms:
exec
/bin/bash -lc 'git branch --show-current && git rev-parse --short HEAD && git merge-base --short HEAD 458d6c5' in /home/ken/Documents/GUI_kit-task-a-wave2
 exited 129 in 0ms:
fix/task-a-action-priority-race
b0df4a9
error: unknown option `short'
usage: git merge-base [-a | --all] <commit> <commit>...
   or: git merge-base [-a | --all] --octopus <commit>...
   or: git merge-base --is-ancestor <commit> <commit>
   or: git merge-base --independent <commit>...
   or: git merge-base --fork-point <ref> [<commit>]

    -a, --[no-]all        output all common ancestors
    --octopus             find ancestors for a single n-way merge
    --independent         list revs not reachable from others
    --is-ancestor         is the first one ancestor of the other?
    --fork-point          find where <commit> forked from reflog of <ref>


codex
I haven’t found a semantic break in the priority split or the dispatcher bypass. I’m running the narrowest relevant tests now so the review isn’t just static inspection.
exec
/bin/bash -lc 'git merge-base HEAD 458d6c5' in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 0ms:
458d6c5fc0368ed6aae25a7d711036539d6a77ff

exec
/bin/bash -lc 'cargo test -p hayate-platform window_action' in /home/ken/Documents/GUI_kit-task-a-wave2
exec
/bin/bash -lc 'cargo test -p hayate-kit title_bar' in /home/ken/Documents/GUI_kit-task-a-wave2
 succeeded in 4116ms:
    Blocking waiting for file lock on package cache
   Compiling hayate-kit v0.1.0 (/home/ken/Documents/GUI_kit-task-a-wave2/crates/hayate-kit)
warning: unexpected `cfg` condition value: `vulkan`
   --> crates/hayate-kit/tests/csd_coord_unification.rs:524:7
    |
524 | #[cfg(feature = "vulkan")]
    |       ^^^^^^^^^^^^^^^^^^
    |
    = note: expected values for `feature` are: `media`, `perf`, and `popup-legacy`
    = help: consider adding `vulkan` as a feature in `Cargo.toml`
    = note: see <https://doc.rust-lang.org/nightly/rustc/check-cfg/cargo-specifics.html> for more information about checking conditional configuration
    = note: `#[warn(unexpected_cfgs)]` on by default

warning: `hayate-kit` (test "csd_coord_unification") generated 1 warning
    Finished `test` profile [unoptimized + debuginfo] target(s) in 3.60s
     Running unittests src/lib.rs (target/debug/deps/hayate_kit-418a9e34dbd39832)

running 17 tests
test widget::title_bar::chrome_adapter_tests::a11y_node_has_title_bar_role ... ok
test widget::title_bar::chrome_adapter_tests::dirty_flow_matches_widget_trait ... ok
test widget::title_bar::chrome_adapter_tests::as_trait_object ... ok
test widget::title_bar::chrome_adapter_tests::update_propagates_dt ... ok
test widget::title_bar::chrome_adapter_tests::preferred_height_matches_inherent ... ok
test widget::title_bar::tests::accessible_emits_title_bar_role_with_title ... ok
test widget::title_bar::chrome_adapter_tests::handle_event_returns_close_for_close_button ... ok
test widget::title_bar::chrome_adapter_tests::paint_through_trait_does_not_panic ... ok
test widget::title_bar::tests::dirty_polls_bound_title ... ok
test widget::title_bar::tests::close_button_press_emits_close_action ... ok
test widget::title_bar::tests::maximize_and_minimize_button_press_emit_respective_actions ... ok
test widget::title_bar::tests::new_uses_theme_defaults_and_starts_idle ... ok
test widget::title_bar::tests::drag_region_press_emits_drag_move ... ok
test widget::title_bar::tests::set_theme_updates_height_and_marks_dirty ... ok
test widget::title_bar::tests::pointer_move_over_close_button_marks_dirty ... ok
test widget::title_bar::tests::right_click_window_menu_respects_policy ... ok
test widget::title_bar::chrome_adapter_tests::inject_engine_through_trait_object_reaches_inner_widget ... ok

test result: ok. 17 passed; 0 failed; 0 ignored; 0 measured; 991 filtered out; finished in 0.43s

     Running tests/csd_coord_unification.rs (target/debug/deps/csd_coord_unification-ded6c9f9a08fd5f1)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 26 filtered out; finished in 0.00s

     Running tests/golden_a11y_chrome.rs (target/debug/deps/golden_a11y_chrome-38bf2b0b821ba841)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 4 filtered out; finished in 0.00s

     Running tests/golden_a11y_focus_scale.rs (target/debug/deps/golden_a11y_focus_scale-594df41f8d9745ca)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 2 filtered out; finished in 0.00s

     Running tests/golden_smoke.rs (target/debug/deps/golden_smoke-86f4f57c4773a4e8)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s

     Running tests/golden_systemlike_chrome.rs (target/debug/deps/golden_systemlike_chrome-236f3b0f33c0907e)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 5 filtered out; finished in 0.00s

     Running tests/golden_widgets.rs (target/debug/deps/golden_widgets-3a46f85af76fdf97)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 14 filtered out; finished in 0.00s

     Running tests/popup_validation.rs (target/debug/deps/popup_validation-1aafdf15326b41e9)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 31 filtered out; finished in 0.00s

     Running tests/styled_coverage.rs (target/debug/deps/styled_coverage-64e30334bcb1d4bf)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 8 filtered out; finished in 0.00s

     Running tests/toast_widget_lifecycle.rs (target/debug/deps/toast_widget_lifecycle-07e4e5d085ef3157)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 3 filtered out; finished in 0.00s

     Running tests/widget_id_uniqueness.rs (target/debug/deps/widget_id_uniqueness-6885baa9976b8f93)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 4 filtered out; finished in 0.00s


 succeeded in 9199ms:
    Blocking waiting for file lock on package cache
    Blocking waiting for file lock on package cache
    Blocking waiting for file lock on package cache
    Blocking waiting for file lock on shared package cache
    Blocking waiting for file lock on build directory
   Compiling hayate-platform v0.1.0 (/home/ken/Documents/GUI_kit-task-a-wave2/crates/hayate-platform)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 9.15s
     Running unittests src/lib.rs (target/debug/deps/hayate_platform-cd28fb92c1b50437)

running 10 tests
test window_action::tests::none_has_lowest_priority ... ok
test window_action::tests::dispatcher_reset_pattern_still_works_post_gate ... ok
test window_action::tests::same_priority_replacement_is_allowed ... ok
test window_action::tests::set_window_action_to_none_is_a_noop_against_pending_request ... ok
test window_action::tests::set_from_none_accepts_any_request ... ok
test window_action::tests::terminal_actions_share_priority_2 ... ok
test window_action::tests::terminal_overwrites_transient ... ok
test window_action::tests::terminal_priority_strictly_dominates_transient ... ok
test window_action::tests::transient_actions_share_priority_1 ... ok
test window_action::tests::transient_does_not_overwrite_terminal ... ok

test result: ok. 10 passed; 0 failed; 0 ignored; 0 measured; 808 filtered out; finished in 0.00s

     Running tests/animation_coverage.rs (target/debug/deps/animation_coverage-cf0469328c212b09)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 6 filtered out; finished in 0.00s

     Running tests/bidi_rtl_verification.rs (target/debug/deps/bidi_rtl_verification-73ba26f93429ebfe)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 25 filtered out; finished in 0.00s

     Running tests/multi_window_lifecycle.rs (target/debug/deps/multi_window_lifecycle-9517f9fa3a590ae4)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 7 filtered out; finished in 0.00s

     Running tests/platform_input_coverage.rs (target/debug/deps/platform_input_coverage-bbef0ce98c86e8e6)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 9 filtered out; finished in 0.00s

     Running tests/reactive_coverage.rs (target/debug/deps/reactive_coverage-045fd9dc904b7b9f)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 15 filtered out; finished in 0.00s

     Running tests/render_clip.rs (target/debug/deps/render_clip-58a5ab52102720cb)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 7 filtered out; finished in 0.00s

     Running tests/scroll_internals_coverage.rs (target/debug/deps/scroll_internals_coverage-b07763e24fb58056)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 5 filtered out; finished in 0.00s

     Running tests/scroll_physics.rs (target/debug/deps/scroll_physics-342ed1a5351cd66c)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 15 filtered out; finished in 0.00s

     Running tests/scroll_viewport_coverage.rs (target/debug/deps/scroll_viewport_coverage-fca3eab37be11cbd)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 5 filtered out; finished in 0.00s

     Running tests/shape_cache_production_path.rs (target/debug/deps/shape_cache_production_path-c5e3679b414de3d0)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 4 filtered out; finished in 0.00s

     Running tests/text_and_stack_coverage.rs (target/debug/deps/text_and_stack_coverage-887819846c7a8279)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 8 filtered out; finished in 0.00s

     Running tests/text_core_axis1_roundtrip.rs (target/debug/deps/text_core_axis1_roundtrip-9278bd731b535a13)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 5 filtered out; finished in 0.00s

     Running tests/text_core_axis2_multibyte.rs (target/debug/deps/text_core_axis2_multibyte-35d9901932566ccb)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 13 filtered out; finished in 0.00s

     Running tests/text_core_axis3_trailing_newline.rs (target/debug/deps/text_core_axis3_trailing_newline-21b19a55889716ca)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 10 filtered out; finished in 0.00s

     Running tests/text_core_axis4_empty_lines.rs (target/debug/deps/text_core_axis4_empty_lines-01a77f52a3763031)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 16 filtered out; finished in 0.00s

     Running tests/text_core_axis5_undo_coalescing.rs (target/debug/deps/text_core_axis5_undo_coalescing-5c745df0c7dd471b)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 12 filtered out; finished in 0.00s

     Running tests/text_core_regression_floor.rs (target/debug/deps/text_core_regression_floor-3f668972fb97de64)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 22 filtered out; finished in 0.00s


codex
No findings.

verdict: LGTM, BLOCKER 0, MINOR 0, NIT 0

Checked against the four requested axes plus surrounding code. The `priority()` split matches the current dispatcher semantics (`Maximize` is already a maximize/restore toggle in [connection.rs](/home/ken/Documents/GUI_kit-task-a-wave2/crates/hayate-platform/src/platform/connection.rs:669), so a future `Restore` can join priority `2` without reshuffling); `>=` is the right gate for same-class retargeting; the dispatcher’s direct `wa.set(WindowAction::None)` reset at [connection.rs](/home/ken/Documents/GUI_kit-task-a-wave2/crates/hayate-platform/src/platform/connection.rs:662) is intentionally outside the producer path and would be incorrectly blocked if routed through the helper; and the scoped-out L2/L3 `Close` producers are defensible as isolated terminal writes, though any future non-title-bar producer that can share a burst with transient writes should adopt `set_window_action` and add a regression test.

Verification: `cargo test -p hayate-platform window_action` and `cargo test -p hayate-kit title_bar` both passed.
tokens used
36,958
No findings.

verdict: LGTM, BLOCKER 0, MINOR 0, NIT 0

Checked against the four requested axes plus surrounding code. The `priority()` split matches the current dispatcher semantics (`Maximize` is already a maximize/restore toggle in [connection.rs](/home/ken/Documents/GUI_kit-task-a-wave2/crates/hayate-platform/src/platform/connection.rs:669), so a future `Restore` can join priority `2` without reshuffling); `>=` is the right gate for same-class retargeting; the dispatcher’s direct `wa.set(WindowAction::None)` reset at [connection.rs](/home/ken/Documents/GUI_kit-task-a-wave2/crates/hayate-platform/src/platform/connection.rs:662) is intentionally outside the producer path and would be incorrectly blocked if routed through the helper; and the scoped-out L2/L3 `Close` producers are defensible as isolated terminal writes, though any future non-title-bar producer that can share a burst with transient writes should adopt `set_window_action` and add a regression test.

Verification: `cargo test -p hayate-platform window_action` and `cargo test -p hayate-kit title_bar` both passed.
