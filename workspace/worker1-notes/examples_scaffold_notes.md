# Phase 2-C Examples 骨組み (未コミット)

worker1 / 2026-04-14
目的: worker2 が Phase 2-C 着手時にコピペ起点として使える最小骨組み。
状態: **未適用**。examples/ に置いてもビルドが通らないため workspace/ に温存。

各ファイルは冒頭に `// TODO(worker2, phase-2C):` コメントを入れ、
未実装箇所を明示。

---

## L1. `examples/multi_window_smoke.rs`

**前提**: `WaylandWindow` を `WindowManager` と結合する platform 層の作業が先行して必要。
骨組みだけ先に書いておく。

```rust
//! Multi-window smoke test — opens two windows via WindowManager and
//! closes one to verify gc(). Phase 2-C L1.
//!
//! Run: cargo run --example multi_window_smoke
//! (Requires Wayland session)

use hayate_ui::platform::multi_window::{WindowConfig, WindowManager};

fn main() {
    let mut wm = WindowManager::new();

    let main = wm.create_window(WindowConfig::new("Main", 800, 600));
    let side = wm.create_window(WindowConfig::new("Side", 400, 300)
        .with_resizable(false));

    // TODO(worker2, phase-2C):
    //   1. Spin up a WaylandWindow for each ManagedWindow in wm
    //      (platform integration glue currently missing — see
    //       workspace/worker1-notes/multiwindow_popup_survey.md §1)
    //   2. Run the event loop until user clicks the "close side" button
    //      on main.
    //   3. Call wm.request_close(side) → wm.close_window(side) → wm.gc()
    //   4. Confirm wm.count() == 1 and main is still alive.

    assert_eq!(wm.count(), 2);
    assert!(wm.has_open_windows());
    let _ = (main, side);
    eprintln!("multi_window_smoke: WindowManager bookkeeping OK, event loop TODO");
}
```

**必要な実装**:
- `WaylandWindow::new_for_managed(&ManagedWindow)` 的な結合 API
- `WindowManager::event_pump()` のようなイベントループ統合
- 両方ともこの example の責務外

---

## L2. `examples/popup_anchor_matrix.rs`

**前提**: `popup_dispatch_fix_patch.md` 適用後。そうでないと popup が閉じられない。

```rust
//! Popup anchor × gravity matrix — 4x4 = 16 combinations exercised by
//! clicking a button that spawns a popup with the selected pair.
//! Phase 2-C L2.
//!
//! Run: cargo run --example popup_anchor_matrix
//! (Requires Wayland session)

use hayate_ui::app::App;
use hayate_ui::platform::popup::{Anchor, Gravity, PopupConfig};
use hayate_ui::widget::basic::TextWidget;
use hayate_ui::widget::layout::{Padding, VStack};

const MAIN_ANCHORS: &[Anchor] = &[
    Anchor::TopLeft, Anchor::TopRight,
    Anchor::BottomLeft, Anchor::BottomRight,
];
const MAIN_GRAVITIES: &[Gravity] = &[
    Gravity::TopLeft, Gravity::TopRight,
    Gravity::BottomLeft, Gravity::BottomRight,
];

fn main() {
    // TODO(worker2, phase-2C):
    //   1. Build a 4x4 grid of buttons. Each button captures (anchor, gravity).
    //   2. On click, create PopupConfig with those values + anchor_rect
    //      set to the button's paint rect (translate_stack::transform_rect
    //      will hand back the surface-local coords automatically).
    //   3. Spawn PopupWindow with parent = main xdg_surface.
    //   4. Poll wayland_window.popup_states each frame, sync into popup,
    //      and destroy when popup.is_closed() (i.e. PopupDone received).
    //   5. Deliberately place buttons near all four screen edges so
    //      Flip/Slide kick in.

    let root = Padding::all(16.0,
        Box::new(VStack::new(8.0)
            .add(Box::new(TextWidget::new("anchor × gravity matrix", 18.0)))));

    let _ = (MAIN_ANCHORS, MAIN_GRAVITIES, root);
    eprintln!("popup_anchor_matrix: scaffold only — needs dispatch fix + popup integration");
}
```

**検証ポイント**（worker2 がレポートに書くべき項目）:
- 各 (anchor, gravity) ペアで popup が期待方向に伸びるか
- 画面右端近傍で `FlipX` が発火するか
- 画面下端近傍で `FlipY` が発火するか
- `PopupDone` で popup が確実に閉じるか（Dispatch 修正の動作確認）

---

## L3. `examples/popup_constraint_matrix.rs`

**前提**: `popup_constraint_api_patch.md` 適用後（`PopupConfig::constraint` フィールド公開）。

```rust
//! Popup constraint adjustment matrix — 8 representative bitmasks from
//! the xdg_positioner spec. Phase 2-C L3.
//!
//! Run: cargo run --example popup_constraint_matrix

use hayate_ui::platform::popup::{ConstraintAdjustment, PopupConfig};

fn preset_constraints() -> [(&'static str, ConstraintAdjustment); 8] {
    [
        ("None (rigid)",    ConstraintAdjustment::empty()),
        ("SlideX only",     ConstraintAdjustment::SlideX),
        ("SlideY only",     ConstraintAdjustment::SlideY),
        ("FlipX only",      ConstraintAdjustment::FlipX),
        ("FlipY only",      ConstraintAdjustment::FlipY),
        ("Resize X+Y",      ConstraintAdjustment::ResizeX | ConstraintAdjustment::ResizeY),
        ("Slide+Flip (default)",
            ConstraintAdjustment::SlideX | ConstraintAdjustment::SlideY
            | ConstraintAdjustment::FlipX | ConstraintAdjustment::FlipY),
        ("All bits",        ConstraintAdjustment::all()),
    ]
}

fn main() {
    // TODO(worker2, phase-2C):
    //   1. Build 8 buttons labelled per preset_constraints().
    //   2. Each button spawns a popup near the *bottom-right* screen edge
    //      so the chosen constraint has something to adjust against.
    //   3. Use PopupConfig::at(..).with_constraint(mask) to apply.
    //   4. Record the compositor's Configure width/height (via
    //      wayland_window.popup_states) to see which constraints caused
    //      Resize vs Slide vs Flip.
    //   5. Log a table:
    //        preset | requested (w,h) | configured (w,h) | observed placement
    //      into workspace/worker2-notes/popup_constraint_results.md.

    for (name, mask) in preset_constraints() {
        let cfg = PopupConfig::at(0, 0, 200, 120).with_constraint(mask);
        eprintln!("{name}: bits = {:?}", cfg.constraint);
    }
}
```

**注意**:
- compositor 依存が強い。Mutter / KWin / sway / Hyprland で挙動が違うので、worker2 はレポートに使用した compositor を明記すること。
- `ConstraintAdjustment::all()` が `wayland-protocols` で提供されているかは未確認。無ければ全ビット OR で代替。

---

## L4. `examples/dropdown_popup_migration.rs`

**前提**: L2 / L3 完了後、かつ Phase 2-B（アニメーション）の実装方針確定後。

```rust
//! PoC: replace the in-surface DropdownWidget overlay with a real
//! xdg_popup surface. Phase 2-C L4.
//!
//! Run: cargo run --example dropdown_popup_migration

// TODO(worker2, phase-2C):
//   Step 1: create PopupDropdownWidget as a parallel type to DropdownWidget.
//           Key differences:
//             - paint() renders only the closed header rect.
//             - on open: spawns PopupWindow with anchor_rect = transformed
//               header rect (translate_stack::transform_rect).
//             - list items are painted into the popup's surface via a
//               dedicated sub-Renderer.
//           Phase 1 translate_stack is the bridge — widget-local header
//           coords go through transform_rect() to hand xdg_positioner
//           the parent-surface-local anchor_rect it expects.
//
//   Step 2: the popup surface starts a fresh coordinate system. Call
//           translate_stack::reset() when entering the popup render
//           context, and push whatever offset the popup needs (typically
//           (0, 0)). Matching pop on exit.
//
//   Step 3: hit-test clicks via the popup's own event stream — the popup
//           surface gets its own wl_pointer, so coordinates already arrive
//           in popup-local space. No CSD offset applies to popups.
//
//   Step 4: on PopupDone (Dispatch fix), fire on_select(None) so the
//           parent widget can close itself cleanly.
//
//   Step 5: run both the existing DropdownWidget and the new
//           PopupDropdownWidget side-by-side in the demo so reviewers
//           can A/B compare — behavior should match modulo the fact
//           that popup variant can overflow the window.

use hayate_ui::app::App;

fn main() {
    // TODO: construct an App with both widgets stacked vertically.
    eprintln!("dropdown_popup_migration: scaffold only — needs Phase 2-B coordination");
}
```

**設計判断の論点**（worker2 / boss1 が着手前に決めるべき）:
- `PopupDropdownWidget` と `DropdownWidget` を並存させるか、完全に置き換えるか
- popup 内描画は既存 `Renderer` を流用するか、popup 専用の新 backend を切り出すか
- アニメーション（Phase 2-B）との連携：popup の create/destroy は離散的なので、open/close のフェードは parent 側で行うべきか popup 側で行うべきか

---

## 共通備考

- 4本すべて `examples/` 直下に単独ファイルとして置けば `cargo run --example` で個別起動可能
- `hayate-ui` クレート側の features は現状 default で可。GPU/Vulkan feature は popup examples では不要
- worker2 着手時は本ドキュメントの該当セクションをコピーして `.rs` 化、`// TODO(worker2, phase-2C)` を実装で置換する流れを想定
- 各 example 完了時は `workspace/worker2-notes/<name>_results.md` に compositor 別の観察レポートを残す
