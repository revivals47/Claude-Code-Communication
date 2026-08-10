# Popup Dispatch 修正 patch 下書き (未コミット)

worker1 / 2026-04-14
対象: `src/platform/popup.rs` の `Dispatch<xdg_popup::XdgPopup, ()>` for `WaylandWindow`
状態: **未適用**。Phase 2-C 着手GOが出るまで温存。

---

## 現状コード（src/platform/popup.rs:226-243）

```rust
impl Dispatch<xdg_popup::XdgPopup, ()> for WaylandWindow {
    fn event(
        _state: &mut Self,
        _popup: &xdg_popup::XdgPopup,
        event: xdg_popup::Event,
        _: &(), _: &Connection, _: &QueueHandle<Self>,
    ) {
        match event {
            xdg_popup::Event::Configure { x: _, y: _, width: _, height: _ } => {
                // Popup was repositioned by compositor
            }
            xdg_popup::Event::PopupDone => {
                // Popup was dismissed (lost focus, ESC, etc.)
            }
            _ => {}
        }
    }
}
```

### 問題 A — `PopupDone` 無視
`PopupDone` イベントは compositor が popup を閉じた通知（フォーカス消失 / ESC / 親クリック 等）。
現状これを捨てているため、`PopupWindow::is_closed()` は明示的な `close()` 呼び出しがない限り永久に false を返す。ユーザーが ESC を押しても widget は「popup 開いたまま」と誤認する。

### 問題 B — `Configure` の `width/height` 破棄
compositor が constraint adjustment（Slide/Flip/Resize）を適用した結果、popup の実サイズは `PopupConfig` に渡した値と異なる場合がある。`Configure` はその新サイズを通知するが、現状はすべて `_` で捨てているため `PopupWindow.width/height` が不整合のまま。描画側は古いサイズで描き、compositor は新サイズで扱うため右下がクリップされる。

---

## 根本的な構造課題

`Dispatch` は `WaylandWindow` に対して実装されており、popup イベントの宛先となる `PopupWindow` インスタンスへの参照が `Dispatch::event` の中から取れない。状態更新には以下いずれかが必要:

1. **UserData ルート** — `get_popup(..., qh, UserData)` の `UserData` に `PopupId` を持たせ、`WaylandWindow` 側で `HashMap<PopupId, PopupWindowState>` を保持。現在 `()` を渡しているのを `PopupId` に変更。
2. **共有セル ルート** — `PopupWindow` 内部を `Rc<RefCell<PopupInner>>` 化し、`Dispatch` の UserData にその弱参照を渡す。

**推奨: ルート 1**。弱参照は `Rc` 前提になり single-thread 制約が更に強まる。`HashMap` 記帳は `WindowManager` と同じ設計で一貫性が取れる。

---

## Patch 下書き（ルート1 前提・最小差分）

### Step 1: PopupId 導入

```diff
 //! Popup windows via the `xdg_popup` Wayland protocol.

+use std::collections::HashMap;
 use wayland_client::protocol::{wl_compositor, wl_surface};
 use wayland_client::{Connection, Dispatch, QueueHandle};
 use wayland_protocols::xdg::shell::client::{xdg_popup, xdg_positioner, xdg_surface, xdg_wm_base};

 use crate::platform::WaylandWindow;

+/// Identifier passed to `xdg_popup` Dispatch as UserData so `WaylandWindow`
+/// can route Configure / PopupDone back to the right `PopupWindow` entry.
+#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
+pub struct PopupId(pub usize);
+
+/// State a popup needs to update in response to Dispatch events. Lives on
+/// `WaylandWindow` (not `PopupWindow`) because Dispatch only sees the
+/// former. `PopupWindow` reads it lazily through `WaylandWindow::popup_state`.
+#[derive(Debug, Default, Clone, Copy)]
+pub struct PopupState {
+    pub width: i32,
+    pub height: i32,
+    pub dismissed: bool,
+}
```

### Step 2: `PopupWindow` に id を持たせ、state を外部から読む

```diff
 pub struct PopupWindow {
+    pub id: PopupId,
     surface: wl_surface::WlSurface,
     xdg_surface: xdg_surface::XdgSurface,
     popup: xdg_popup::XdgPopup,
     pub width: i32,
     pub height: i32,
     pub dismissed: bool,
 }

 impl PopupWindow {
     pub fn create(
         compositor: &wl_compositor::WlCompositor,
         wm_base: &xdg_wm_base::XdgWmBase,
         parent_xdg_surface: &xdg_surface::XdgSurface,
         config: &PopupConfig,
         qh: &QueueHandle<WaylandWindow>,
+        id: PopupId,
     ) -> Self {
         let surface = compositor.create_surface(qh, ());
         let xdg_surf = wm_base.get_xdg_surface(&surface, qh, ());

         let positioner = wm_base.create_positioner(qh, ());
         positioner.set_size(config.width, config.height);
         ...
-        let popup = xdg_surf.get_popup(Some(parent_xdg_surface), &positioner, qh, ());
+        let popup = xdg_surf.get_popup(Some(parent_xdg_surface), &positioner, qh, id);
         positioner.destroy();

         surface.commit();

         Self {
+            id,
             surface, xdg_surface: xdg_surf, popup,
             width: config.width, height: config.height, dismissed: false,
         }
     }

+    /// Sync locally-cached width/height/dismissed from the WaylandWindow's
+    /// Dispatch-updated table. Call once per frame or after event pump.
+    pub fn sync_from(&mut self, state: PopupState) {
+        if state.width > 0 { self.width = state.width; }
+        if state.height > 0 { self.height = state.height; }
+        if state.dismissed { self.dismissed = true; }
+    }
 }
```

### Step 3: `Dispatch` を `PopupId` UserData に切り替えて Configure / PopupDone を保存

```diff
-impl Dispatch<xdg_popup::XdgPopup, ()> for WaylandWindow {
+impl Dispatch<xdg_popup::XdgPopup, PopupId> for WaylandWindow {
     fn event(
-        _state: &mut Self,
+        state: &mut Self,
         _popup: &xdg_popup::XdgPopup,
         event: xdg_popup::Event,
-        _: &(), _: &Connection, _: &QueueHandle<Self>,
+        id: &PopupId, _: &Connection, _: &QueueHandle<Self>,
     ) {
+        let entry = state.popup_states.entry(*id).or_default();
         match event {
-            xdg_popup::Event::Configure { x: _, y: _, width: _, height: _ } => {
-                // Popup was repositioned by compositor
-            }
-            xdg_popup::Event::PopupDone => {
-                // Popup was dismissed (lost focus, ESC, etc.)
-            }
+            xdg_popup::Event::Configure { x: _, y: _, width, height } => {
+                // Compositor may have applied Slide/Flip/Resize — the
+                // authoritative size lives here, not in PopupConfig.
+                entry.width = width;
+                entry.height = height;
+            }
+            xdg_popup::Event::PopupDone => {
+                // User pressed ESC, lost focus, or clicked outside the popup.
+                // The xdg_popup protocol object is implicitly invalidated
+                // after this — callers must stop using it.
+                entry.dismissed = true;
+            }
             _ => {}
         }
     }
 }
```

### Step 4: `WaylandWindow` に `popup_states` を保持（platform 本体側の改修）

この差分は `src/platform/` の `WaylandWindow` 構造体本体に追加する。ファイルは未確認だが:

```diff
 pub struct WaylandWindow {
     // ... 既存フィールド ...
+    pub popup_states: HashMap<PopupId, PopupState>,
 }
```
初期化箇所で `popup_states: HashMap::new()` を足す。

### Step 5: PopupWindow::create 呼び出し側は id を払い出す

```rust
let id = PopupId(next_popup_id());
let mut popup = PopupWindow::create(&compositor, &wm_base, &parent_xdg_surface, &config, &qh, id);

// Event pump 後
if let Some(state) = wayland_window.popup_states.get(&id).copied() {
    popup.sync_from(state);
}
```

---

## 単体テスト追加案

Wayland サーバーを立てずに Dispatch を直接叩く mock は重い。以下が現実的:

```rust
#[test]
fn popup_state_default_is_zero_and_not_dismissed() {
    let s = PopupState::default();
    assert_eq!((s.width, s.height, s.dismissed), (0, 0, false));
}

#[test]
fn sync_from_preserves_existing_when_state_is_zero() {
    let mut p = PopupWindow {
        id: PopupId(0), width: 300, height: 200, dismissed: false,
        // surface/xdg_surface/popup は mock 困難 → 代わりに small struct を用意
        // （sync_from のロジックを inner method に切り出せばテスト可能）
        ..
    };
    p.sync_from(PopupState::default());
    assert_eq!(p.width, 300);  // ゼロ値は上書きしない
}

#[test]
fn sync_from_marks_dismissed() {
    let mut p = ...;
    p.sync_from(PopupState { width: 0, height: 0, dismissed: true });
    assert!(p.dismissed);
}

#[test]
fn sync_from_updates_size_on_configure() {
    let mut p = ...;  // width=300, height=200
    p.sync_from(PopupState { width: 320, height: 180, dismissed: false });
    assert_eq!((p.width, p.height), (320, 180));
}
```

`sync_from` を独立メソッドに切り出しておけば Wayland object 不要で検証可能。

---

## 適用順序

1. `PopupId` + `PopupState` の追加（型導入のみ、既存テスト影響ゼロ）
2. `PopupWindow::create` のシグネチャ変更（呼び出し側ゼロのため回帰リスクゼロ）
3. `Dispatch` UserData を `()` → `PopupId` に切替
4. `WaylandWindow::popup_states` 追加
5. `sync_from` + unit test 4件

CI 影響: なし（実 Wayland 不要のテストのみ）。既存テスト5件（`popup_config_*`）は触らない。

---

## 残課題（この patch では扱わない）

- compositor が送る `Configure` の `x/y` は popup の最終位置。使いたいなら `PopupState` に `x/y` も足す
- popup のネスト（popup の上に popup）は xdg_popup 仕様的に可能だが、今回はスコープ外
- `xdg_popup::reposition` (v3) — 既存 popup の再配置。Phase 2-C 本実装時に検討
