# PopupConfig ConstraintAdjustment 公開 patch 下書き (未コミット)

worker1 / 2026-04-14
対象: `src/platform/popup.rs` の `PopupConfig` / `PopupWindow::create`
状態: **未適用**。

---

## 背景

`xdg_positioner::ConstraintAdjustment` は **bitflag** で、xdg-shell 仕様の
6ビットが定義されている:

| ビット | 挙動 |
|---|---|
| `SlideX` | 画面端で X 方向に popup をスライドさせる |
| `SlideY` | 画面端で Y 方向にスライド |
| `FlipX` | 画面端で X 方向に anchor/gravity を反転 |
| `FlipY` | 画面端で Y 方向に反転 |
| `ResizeX` | 画面に収まるよう X 方向にリサイズ |
| `ResizeY` | Y 方向にリサイズ |

値 0 (`None`) を含めれば 2^6 = 64 通りの組合せだが、意味ある代表は 7〜8 パターン。

現状 `popup.rs:176-181` で以下が**ハードコード**:
```rust
positioner.set_constraint_adjustment(
    xdg_positioner::ConstraintAdjustment::SlideX
        | xdg_positioner::ConstraintAdjustment::SlideY
        | xdg_positioner::ConstraintAdjustment::FlipX
        | xdg_positioner::ConstraintAdjustment::FlipY,
);
```
→ `ResizeX / ResizeY` と `None` は検証不可能。

---

## API 設計

### 方針
- `PopupConfig` に `constraint: ConstraintAdjustment` フィールドを追加
- `Default` は既存のハードコード値 (`Slide|Flip`) に合わせ、後方互換を保つ
- `wayland_protocols::xdg::shell::client::xdg_positioner::ConstraintAdjustment` を再エクスポート（抽象化はしない。Wayland 型をそのまま使う方が薄い）

### 差分

```diff
 //! Popup windows via the `xdg_popup` Wayland protocol.

 use wayland_client::protocol::{wl_compositor, wl_surface};
 use wayland_client::{Connection, Dispatch, QueueHandle};
 use wayland_protocols::xdg::shell::client::{xdg_popup, xdg_positioner, xdg_surface, xdg_wm_base};

 use crate::platform::WaylandWindow;

+/// Re-exported for callers that want to customise popup constraint
+/// behaviour without pulling in wayland-protocols directly.
+pub use xdg_positioner::ConstraintAdjustment;
+
 /// Anchor edge for popup positioning.
 ...

-pub struct PopupConfig {
+pub struct PopupConfig {
     pub x: i32,
     pub y: i32,
     pub width: i32,
     pub height: i32,
     pub anchor: Anchor,
     pub gravity: Gravity,
     pub anchor_rect: (i32, i32, i32, i32),
+    /// Bitflag of `ConstraintAdjustment` bits the compositor may apply
+    /// when the popup doesn't fit on screen. Defaults to
+    /// `SlideX|SlideY|FlipX|FlipY` — the pre-existing hard-coded value.
+    pub constraint: ConstraintAdjustment,
 }

 impl PopupConfig {
+    fn default_constraint() -> ConstraintAdjustment {
+        ConstraintAdjustment::SlideX
+            | ConstraintAdjustment::SlideY
+            | ConstraintAdjustment::FlipX
+            | ConstraintAdjustment::FlipY
+    }

     pub fn at(x: i32, y: i32, width: i32, height: i32) -> Self {
         Self {
             x, y, width, height,
             anchor: Anchor::TopLeft,
             gravity: Gravity::BottomRight,
             anchor_rect: (x, y, 1, 1),
+            constraint: Self::default_constraint(),
         }
     }

     // tooltip / dropdown / context_menu も同様に `constraint: Self::default_constraint()` を追加
+
+    /// Builder: override the constraint adjustment bitflag.
+    pub fn with_constraint(mut self, constraint: ConstraintAdjustment) -> Self {
+        self.constraint = constraint;
+        self
+    }
+
+    /// Builder: allow the compositor to resize the popup to fit the screen
+    /// (adds `ResizeX|ResizeY` to whatever was there).
+    pub fn allow_resize(mut self) -> Self {
+        self.constraint |= ConstraintAdjustment::ResizeX | ConstraintAdjustment::ResizeY;
+        self
+    }
+
+    /// Builder: disable all compositor adjustments (`None`). The popup will
+    /// be clipped rather than repositioned. Mostly useful for tests.
+    pub fn rigid(mut self) -> Self {
+        self.constraint = ConstraintAdjustment::empty();
+        self
+    }
 }

 impl PopupWindow {
     pub fn create(...) -> Self {
         ...
         positioner.set_anchor(config.anchor.to_xdg());
         positioner.set_gravity(config.gravity.to_xdg());

-        // Allow compositor to reposition if the popup doesn't fit on screen
-        positioner.set_constraint_adjustment(
-            xdg_positioner::ConstraintAdjustment::SlideX
-                | xdg_positioner::ConstraintAdjustment::SlideY
-                | xdg_positioner::ConstraintAdjustment::FlipX
-                | xdg_positioner::ConstraintAdjustment::FlipY,
-        );
+        positioner.set_constraint_adjustment(config.constraint);
         ...
     }
 }
```

### 注意
- `ConstraintAdjustment` は `wayland-protocols` の bitflags。値比較には `contains(..)` を使う。
- `Default` を `impl` すると自動導出は効かない（`ConstraintAdjustment` が `Copy` でも `Default` 実装の有無は別）。`PopupConfig::default_constraint()` 関数で逃げる。

---

## 未検証だった組合せの全列挙

survey で "5/8" と書いたが正確には **6 ビット** なので合計 64 通り。
"意味ある代表" として以下 8 パターンが examples/popup_constraint_matrix.rs の検証対象:

| # | constraint | 期待挙動 |
|---|---|---|
| 1 | `None` (empty) | 画面端で popup がはみ出したままクリップ（ネイティブ compositor 依存） |
| 2 | `SlideX` 単独 | 水平方向のみスライド補正、縦は固定 |
| 3 | `SlideY` 単独 | 縦方向のみスライド補正 |
| 4 | `FlipX` 単独 | 水平方向のみ anchor/gravity を反転 |
| 5 | `FlipY` 単独 | 縦方向のみ反転 |
| 6 | `ResizeX|ResizeY` | 画面に収まるよう popup 自体をリサイズ |
| 7 | `Slide|Flip` (既存デフォルト) | 既存挙動 |
| 8 | 全部入り (`all()` 相当) | すべての補正を許容 |

`examples/popup_constraint_matrix.rs` はこれら 8 パターンを 8ボタンで切替えて動作確認するのが妥当。

---

## 呼び出し側への影響

`PopupConfig` を構築しているのは内部テスト5件のみ（`popup_config_at / tooltip / dropdown / context_menu / anchor_to_xdg`）。いずれもフィールド比較で `constraint` を見ていないので回帰はゼロ。

既存コード (`popup.rs` 外) で `PopupConfig { .. }` を直接構築している箇所は **grep 結果ゼロ**。ビルダー `PopupConfig::at(..)` / `tooltip(..)` / `dropdown(..)` / `context_menu(..)` しか使われていないため、フィールド追加の破壊的影響なし。

---

## 単体テスト追加案

```rust
#[test]
fn default_constraint_matches_previous_hardcoded() {
    let cfg = PopupConfig::at(0, 0, 10, 10);
    assert!(cfg.constraint.contains(ConstraintAdjustment::SlideX));
    assert!(cfg.constraint.contains(ConstraintAdjustment::SlideY));
    assert!(cfg.constraint.contains(ConstraintAdjustment::FlipX));
    assert!(cfg.constraint.contains(ConstraintAdjustment::FlipY));
    assert!(!cfg.constraint.contains(ConstraintAdjustment::ResizeX));
}

#[test]
fn allow_resize_adds_resize_bits() {
    let cfg = PopupConfig::at(0, 0, 10, 10).allow_resize();
    assert!(cfg.constraint.contains(ConstraintAdjustment::ResizeX));
    assert!(cfg.constraint.contains(ConstraintAdjustment::ResizeY));
}

#[test]
fn rigid_clears_all_bits() {
    let cfg = PopupConfig::at(0, 0, 10, 10).rigid();
    assert!(cfg.constraint.is_empty());
}

#[test]
fn with_constraint_overrides_default() {
    let cfg = PopupConfig::at(0, 0, 10, 10)
        .with_constraint(ConstraintAdjustment::FlipX);
    assert_eq!(cfg.constraint, ConstraintAdjustment::FlipX);
}
```

全て構築テストで Wayland サーバー不要、既存テスト構成に即追加可能。

---

## 残課題

- compositor ごとの constraint 実装差（Mutter vs KWin vs sway vs Hyprland）は実機チェックリスト化
- `ResizeX/Y` を有効にした際の `Configure` width/height 追随は `popup_dispatch_fix_patch.md` の修正とペアで検証する
