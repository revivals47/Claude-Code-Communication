# S1 Design Draft — multi-window L1 Stage 1

> Status: v0.1 (Phase A pre-review)
> Date: 2026-05-29
> Author: worker1 (S1 dispatch)
> Branch: track-multiwindow/s1-connection (worktree ~/Documents/GUI_kit-mw-s1)
> Base: GUI_kit main 786630d (S0 land 直後)
> ★ Phase B atomic commits は本 doc の boss1 review 通過後に着手

---

## A0. Pre-existing fail baseline (Pattern 5)

`cd ~/Documents/GUI_kit-mw-s1 && cargo test -j1 -p hayate-platform --lib --no-fail-fast`

→ **806 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out** (S0 land 直後と bit-exact 同一)。
本 dispatch 起因否定の baseline = 806/0 維持を AC5 で確認する。

---

## A1. WaylandWindow field 全分類

現 `WaylandWindow` (wayland.rs:111-392) は **89 field** (cfg-gated 含む)。RFC §0.2-a の principle (connection-global / seat-global / per-window) + 実コード参照を grep して分類した。

### A1.1 per-window (新 `Window` struct へ移管)

| field | type | wayland.rs line | 理由 |
|---|---|---|---|
| width | u32 | 113 | per-window size |
| height | u32 | 115 | per-window size |
| running | bool | 117 | per-window lifecycle |
| configured | bool | 119 | per-window xdg_surface configure 状態 |
| surface | Option\<WlSurface\> | 125 | per-window protocol obj |
| xdg_surface | Option\<XdgSurface\> | 126 | per-window |
| xdg_toplevel | Option\<XdgToplevel\> | 127 | per-window |
| layer_surface | Option\<LayerSurfaceV1\> | 135 | per-window |
| layer_shell_config | Option\<LayerSurfaceConfig\> | 136 | per-window layer-shell config |
| pointer_serial | u32 | 151 | RFC §0.2-a 暗黙 per-window (last pointer event for this window) |
| pointer_surface_offset | (f64, f64) | 164 | RFC §0.2-a 明示 per-window |
| popup_surface_to_id | HashMap\<u32, PopupId\> | 174 | RFC §0.2-a 明示 per-window (popup chain は親窓所属) |
| keyboard_focus | KeyboardFocusKind | 188 | RFC §0.2-a 明示 per-window |
| last_press_pointer_serial | u32 | 197 | RFC §0.2-a 明示 per-window |
| resize_edge | Option\<ResizeEdge\> | 199 | per-window resize 状態 |
| events | HayateEventQueue | 213 | per-window event queue |
| drop_target | DropTargetState | 216 | per-window DnD destination (drop happens on a surface) |
| pending_drop | Option\<DropData\> | 217 | per-window |
| last_frame_time | Option\<Instant\> | 231 | per-window frame timing |
| frame_dt | f32 | 232 | per-window |
| damage | DamageTracker | 235 | per-window damage |
| buffer_pool | BufferPool | 238 | per-window double buffer |
| frame_pending | bool | 239 | per-window |
| frame_pending_since | Option\<Instant\> | 242 | per-window |
| draw_fn | Option\<DrawFn\> | 245 | per-window paint callback |
| popup_phase_fn | Option\<PopupPhaseFn\> | 262 | per-window popup chain hook |
| title_buffer | Option\<Rc\<RefCell\<Option\<String\>\>\>\> | 266 | per-window title |
| cursor_shape_buffer | Option\<Rc\<Cell\<Option\<CursorShape\>\>\>\> | 296 | per-window cursor (set on pointer-enter into this window) |
| window_size | Option\<Rc\<Cell\<(u32,u32)\>\>\> | 298 | per-window dynamic size |
| move_request | Option\<Rc\<Cell\<bool\>\>\> | 299 | per-window move req |
| window_action | Option\<Rc\<Cell\<WindowAction\>\>\> | 300 | per-window action (maximize/min/close) |
| ime_enable_request | Option\<Rc\<Cell\<bool\>\>\> | 302 | per-window IME enable (IME ties to focused surface) |
| ime_cursor_rect | ImeCursorRectSlot | 303 | per-window IME cursor rect |
| min_size | Option\<(u32,u32)\> | 304 | per-window size policy |
| max_size | Option\<(u32,u32)\> | 305 | per-window size policy |
| is_maximized | bool | 306 | per-window maximize state |
| popup_states | HashMap\<PopupId, PopupState\> | 310 | per-window popup chain |
| popup_frame_pending | HashSet\<PopupId\> | 320 | per-window popup frame cadence |
| released_popup_buffers | Vec\<WlBuffer\> | 329 | per-window popup buffer release queue |
| next_popup_id | usize | 331 | per-window popup id alloc |
| next_reposition_token | u32 | 335 | per-window reposition token alloc |
| ready_fn | ReadyFn | 343 | per-window (fires after this window's first configure) |
| gpu_surface (cfg gpu) | Option\<GpuSurface\> | 350 | RFC §0.2-a + R4 per-window GPU surface |
| gpu_draw_fn (cfg gpu) | Option\<Box\<...\>\> | 352 | per-window GPU draw |
| vk_renderer (cfg vulkan) | Option\<VulkanRenderer\> | 357 | per-window Vulkan |
| vk_draw_fn (cfg vulkan) | VkDrawFn | 359 | per-window Vulkan draw |
| dmabuf_buffers (cfg vulkan) | [Option\<DmaBufBuffer\>; 2] | 368 | per-window Vulkan dmabuf |
| dmabuf_buffer_size (cfg vulkan) | (i32, i32) | 371 | per-window |
| dmabuf_slot_in_use (cfg vulkan) | [bool; 2] | 380 | per-window |
| vulkan_disabled (cfg vulkan) | bool | 385 | per-window Vulkan terminal state (#25, RFC R4) |
| device_lost_repaint | Option\<Rc\<Cell\<bool\>\>\> | 391 | per-window device-lost trigger (RFC R4) |

→ **52 fields → Window**

### A1.2 connection-global (新 `WaylandConnection` struct へ移管)

| field | type | wayland.rs line | 理由 |
|---|---|---|---|
| compositor | Option\<WlCompositor\> | 122 | RFC §0.2-a 明示 connection-global |
| shm | Option\<WlShm\> | 123 | RFC §0.2-a 明示 |
| seat | Option\<WlSeat\> | 124 | RFC §0.2-a 明示 (seat singleton) |
| wm_base | Option\<XdgWmBase\> | 128 | RFC §0.2-a 明示 |
| decoration_manager | Option\<ZxdgDecorationManagerV1\> | 131 | RFC §0.2-a 明示 |
| layer_shell | Option\<ZwlrLayerShellV1\> | 134 | RFC §0.2-a 明示 |
| data_device_manager | Option\<WlDataDeviceManager\> | 149 | RFC §0.2-a 明示 |
| cursor_manager | Option\<CursorManager\> | 143 | RFC §0.2-a 明示 |
| cursor_theme_fallback | Option\<CursorThemeFallback\> | 147 | connection-global (shared 1 instance) |
| dmabuf_manager | Option\<DmaBufManager\> | 142 | connection-global |
| text_input_manager | Option\<ZwpTextInputManagerV3\> | 203 | RFC §0.2-a 明示 |
| keyboard_state | KeyboardState | 139 | RFC §0.2-a seat-global (S1 で connection に同居) |
| pointer_state | PointerState | 140 | RFC §0.2-a seat-global |
| touch_state | TouchState | 141 | RFC §0.2-a seat-global |
| pointer | Option\<WlPointer\> | 150 | RFC §0.2-a seat-global |
| clipboard | Option\<Clipboard\> | 148 | RFC §0.2-a seat-global |
| ime_state | ImeState | 202 | RFC §0.2-a seat-global |
| ibus_client (cfg ibus) | Option\<IBusClient\> | 206 | seat-global (IME backend) |
| key_repeat | KeyRepeatState | 209 | seat-global (keyboard repeat は seat 単位) |
| pending_repeat_action | Option\<RepeatAction\> | 210 | seat-global (key_repeat と一体) |
| dnd_source | Option\<WlDataSource\> | 219 | seat-global (active outgoing drag は seat 単位 1) |
| dnd_uris | Option\<Vec\<String\>\> | 221 | seat-global (dnd_source と一体) |
| dnd_text | Option\<String\> | 223 | seat-global |
| drag_request_buffer | Option\<DragRequestBuffer\> | 225 | seat-global (widget tier drag req buffer) |
| dnd_renegotiate_request | DndRenegotiateChannel | 273 | seat-global (1 active drag/seat) |
| pending_drag_start | PendingDragStartChannel | 279 | seat-global |
| pending_drag_outcome | Option\<Rc\<RefCell\<...\>\>\> | 286-287 | seat-global |
| last_received_dnd_action | Option\<DndAction\> | 295 | seat-global |
| clipboard_copy_buffer | Option\<Rc\<RefCell\<Option\<String\>\>\>\> | 267 | seat-global (clipboard) |
| clipboard_paste_request | Option\<Rc\<Cell\<bool\>\>\> | 268 | seat-global |
| scale_manager | ScaleManager | 228 | ★判断要 (下記 A1.4) — 暫定 connection-global |
| key_fn | Option\<KeyFn\> | 246 | app-global (1 keyboard handler/app) |
| event_fn | Option\<EventFn\> | 247 | app-global (1 event handler/app) |
| event_fn_mut | Option\<EventFnMut\> | 253 | app-global |
| qh_cached | Option\<QueueHandle\<UiState\>\> | 339 | connection-global (1 wl_event_queue/connection) |
| channel_registrations | ChannelRegistrations | 346 | connection-global (EventLoop 起動時 drain) |
| quit_flag | Option\<Rc\<Cell\<bool\>\>\> | 265 | app-global (SIGINT) |

→ **37 fields → Connection**

### A1.3 合計

- per-window (Window): 52
- connection-global (Connection): 37
- 合計: 89 (全 field exhaustive)

### A1.4 ★ 判断要 field: scale_manager

`ScaleManager` (hidpi.rs:140-179 で 4 Dispatch impl が surface に bind) は RFC §0.2-a 表で "per-window (codex F2)" と明示。**ただし S1 single-window では実体 1 個**。

- **A 案 (RFC 厳密)**: scale_manager → Window field。S2+ で per-window scale を窓ごとに保持できる構造。
- **B 案 (S1 pragmatic)**: scale_manager → Connection field。S1 は単一窓ゆえ事実上同義、S2 で Window へ migrate。

★ **worker1 推奨 = A 案** (RFC §0.2-a + codex F2 重視、S2 で migrate 不要、boss1 review で 確定希望)。

### A1.5 ★ 判断要 field: key_fn / event_fn / event_fn_mut

これら 3 callback は app-global (1 keyboard/event handler per app) だが、S2+ で per-window callback 化する余地もある (App::open_window が widget tree を取るので、その widget 群が捕捉する事も可)。

- **A 案**: callback → Connection field (app-global)。S2 で必要なら Window 側に追加 (override mechanism)。
- **B 案**: callback → Window field (per-window)。S1 single window では同義、S2 で自然な per-window 化。

★ **worker1 推奨 = B 案** (per-window callback が S2 の Window struct と整合、S1 single でも behavior 不変)。

### A1.6 ★ 判断要 field: ready_fn / popup_phase_fn / draw_fn

これら 3 callback は明確に per-window:
- ready_fn: window の first xdg_surface configure 後に発火
- popup_phase_fn: window の popup chain に対する per-frame hook
- draw_fn: window's root widget paint

→ Window へ移管 (議論余地なし、A1.1 に既掲)。

### A1.7 ★ 判断要 callback まとめ

A1.5 が B 案採用なら、callback 全 6 件 (draw / key / event / event_mut / popup_phase / ready) が Window field。A1.5 が A 案なら key/event/event_mut のみ Connection、他 3 は Window。

★ A1.4 + A1.5 共に boss1 review で確定希望。

---

## A2. 新 `Window` struct draft

```rust
// crates/hayate-platform/src/platform/wayland.rs (in-place rename)
pub struct Window {
    // ...A1.1 で列挙した 52 field を全て field 名そのまま移管...
}

/// BC alias preserving the historical `WaylandWindow` name.
/// All `WaylandWindow::new(...)` / `WaylandWindow::set_title(...)` etc.
/// keep working through this alias. `pub use wayland::WaylandWindow;`
/// in `platform/mod.rs` also keeps working.
pub type WaylandWindow = Window;

impl Window {
    pub fn new(width: u32, height: u32) -> Self { ... }
    pub(crate) fn set_device_lost_repaint(&mut self, cell: Rc<Cell<bool>>) { ... }
    pub fn alloc_popup_id(&mut self) -> PopupId { ... }
    pub fn alloc_reposition_token(&mut self) -> u32 { ... }
    pub fn popup_state(&self, id: PopupId) -> Option<&PopupState> { ... }
    pub fn on_draw(&mut self, f: impl FnMut(&mut SoftwareRenderer, f32) + 'static) { ... }
    pub fn on_key(&mut self, f: impl FnMut(&KeyEvent) + 'static) { ... }  // ★A1.5 B案採用時
    pub fn on_event(&mut self, f: impl FnMut(&WindowEvent) + 'static) { ... }
    pub fn on_event_mut<F: FnMut(&mut UiState, &WindowEvent) + 'static>(&mut self, f: F) { ... }
    pub fn on_popup_phase<F: FnMut(&mut UiState) + 'static>(&mut self, f: F) { ... }
    pub fn on_ready<F: FnOnce(&mut UiState) + 'static>(&mut self, f: F) { ... }
    pub fn on_gpu_draw(&mut self, f: ...) { ... }
    pub fn on_vk_draw(&mut self, f: ...) { ... }
    pub fn register_channel(&mut self, f: ...) { ... }  // pre-run buffer
    pub fn set_title(&self, title: &str) { ... }
    /// BC trampoline (examples 10+ use this signature unchanged):
    /// constructs a Connection wrapping `self`, runs the Connection's
    /// event loop, then restores `self` from `connection.window`.
    pub fn run(&mut self) -> Result<(), Box<dyn Error>> {
        let window = std::mem::replace(self, Window::new(0, 0));
        let mut connection = WaylandConnection::with_window(window);
        let result = connection.run();
        *self = connection.window;
        result
    }
    // create_popup, draw_frame: 移管予定だが Connection-side method として
    // 再公開 (A4 delegation pattern で詳述)
}
```

### ★ A2.1 design 判断: WaylandWindow → Window 改名 + 型エイリアス

- RFC §6 S1 が「新 Window struct を新設」と明示
- 既存 WaylandWindow は実質「per-window content」(connection-global field を移管後)
- `pub type WaylandWindow = Window;` で全 BC 用法 (test/example/public re-export) を保持
- 将来 (S6+ cleanup phase) で alias 削除可能

★ boss1 review で確定希望: Window rename + BC alias 採用可否。

---

## A3. 新 `WaylandConnection` struct draft

```rust
// crates/hayate-platform/src/platform/connection.rs (新ファイル)
pub struct WaylandConnection {
    // ...A1.2 で列挙した 37 connection-global field を全て移管...

    /// 単一 Window (S1)。S2 で `HashMap<WindowId, Window>` に置換予定。
    pub window: Window,
}

impl WaylandConnection {
    /// Construct a Connection wrapping a fresh Window. All connection-global
    /// fields start as None / default; populated by the registry-bind phase
    /// inside `run()`.
    pub fn with_window(window: Window) -> Self {
        Self {
            compositor: None,
            shm: None,
            // ...37 default-init...
            window,
        }
    }

    /// Connect to Wayland and run the calloop event loop. Takes over
    /// the body of the historical `WaylandWindow::run`.
    pub fn run(&mut self) -> Result<(), Box<dyn Error>> {
        // body migrated from WaylandWindow::run (~600 lines)
        // - signal handler setup
        // - Connection::connect_to_env + EventQueue<UiState> setup
        // - WaylandSource::new + calloop EventLoop<UiState>
        // - drain channel_registrations
        // - while self.window.running { event_loop.dispatch(...); self.tick_frame() }
        // - teardown
    }

    pub(crate) fn draw_frame(&mut self, qh: &QueueHandle<UiState>) { ... }
    // 他、移管 method (cf. A4)
}
```

### ★ A3.1 design 判断: Connection.window は direct field か Option か?

- **direct field (`pub window: Window`)**: S1 always has 1 window. `with_window` 受領で確定。S2 で `HashMap<WindowId, Window>` に置換時 API breakage は許容 (内部のみ)。
- **Option<Window>**: 一時的に window-less 状態 (teardown 中) を表現可。S1 では本質的不要。

★ **worker1 推奨 = direct field** (S1 では teardown も `connection.window.running = false` で表現可、Option 化は overkill)。boss1 review で確定希望。

### ★ A3.2 design 判断: ファイル配置

現 wayland.rs = 1900+ 行。Connection struct + Connection::run (~600 行) を同 file に追加すると ~2500 行。

- **A 案 (split)**: connection.rs を新規作成。Window は wayland.rs に残す (in-place rename)。
- **B 案 (monolith)**: 全て wayland.rs。

★ **worker1 推奨 = A 案 split** ([[feedback_500_line_guideline]] cohesion 主軸、Connection は Wayland integration の独立 unit、wayland.rs は Window 中心の per-window 層に再焦点化)。boss1 review で確定希望。

---

## A4. 35 Dispatch impl delegation pattern

S0 後の状態: 全 35 impl が `for UiState` (= WaylandWindow)。S1 で `UiState = WaylandConnection` flip 後、impl body 内 `state.X` の参照を:

- field が **connection-global** → `state.X` (そのまま)
- field が **per-window** → `state.window.X` (Window への delegation)
- method (e.g. `state.create_popup(...)`) が Window method なら → `state.window.create_popup(...)`
- method が Connection method なら → `state.method(...)` (そのまま)

### A4.1 delegation 例: dispatch_impls.rs:wl_registry (大量 connection-global 操作)

**Before (S0):**
```rust
impl Dispatch<wl_registry::WlRegistry, ()> for UiState {
    fn event(state: &mut Self, registry, event, _, _, qh) {
        if let Global { name, interface, version } = event {
            match interface.as_str() {
                "wl_compositor" => state.compositor = Some(registry.bind(...)),
                "wl_seat" => { let seat = registry.bind(...);
                    if let Some(mgr) = &state.data_device_manager {
                        state.clipboard = Some(Clipboard::new(mgr.clone(), &seat, qh));
                    }
                    state.seat = Some(seat);
                }
                ...
            }
        }
    }
}
```

**After (S1):**
```rust
impl Dispatch<wl_registry::WlRegistry, ()> for UiState {
    fn event(state: &mut Self, registry, event, _, _, qh) {
        if let Global { name, interface, version } = event {
            match interface.as_str() {
                "wl_compositor" => state.compositor = Some(registry.bind(...)),  // unchanged (connection-global)
                "wl_seat" => { let seat = registry.bind(...);
                    if let Some(mgr) = &state.data_device_manager {
                        state.clipboard = Some(Clipboard::new(mgr.clone(), &seat, qh));
                    }
                    state.seat = Some(seat);
                }  // unchanged (all connection-global)
                ...
            }
        }
    }
}
```

→ wl_registry impl body は **全て connection-global field 操作**ゆえ S1 で **変更ゼロ** (UiState flip だけで自動的に WaylandConnection を触る)。

### A4.2 delegation 例: dispatch_impls.rs:xdg_surface (per-window 操作)

**Before:**
```rust
impl Dispatch<xdg_surface::XdgSurface, ()> for UiState {
    fn event(state: &mut Self, surface, event, _, _, qh) {
        if let Configure { serial } = event {
            surface.ack_configure(serial);
            state.configured = true;
            state.width = ...; state.height = ...;
            state.fire_ready_if_pending();
        }
    }
}
```

**After:**
```rust
impl Dispatch<xdg_surface::XdgSurface, ()> for UiState {
    fn event(state: &mut Self, surface, event, _, _, qh) {
        if let Configure { serial } = event {
            surface.ack_configure(serial);
            state.window.configured = true;
            state.window.width = ...; state.window.height = ...;
            state.fire_ready_if_pending();  // method moves: Connection has ready_fn? or window method via .window.fire_ready_if_pending(state-globals)?
        }
    }
}
```

→ field access prefix が `state.window.X` に。method 移管は A4.4 参照。

### A4.3 delegation 例: dispatch_impls.rs:wl_pointer (混在: seat-global + per-window)

```rust
impl Dispatch<wl_pointer::WlPointer, ()> for UiState {
    fn event(state: &mut Self, ptr, event, _, _, qh) {
        match event {
            Enter { surface, surface_x, surface_y, serial } => {
                // seat-global pointer state (Connection):
                state.pointer = Some(ptr.clone());
                state.pointer_serial = ?;  // wait — A1.1 で per-window 分類した
                // per-window pointer state (Window):
                state.window.pointer_serial = serial;
                state.window.last_press_pointer_serial = ?;
                // popup→parent surface offset resolution (per-window):
                if let Some(id) = state.window.popup_surface_to_id.get(&surface.id().protocol_id()) {
                    state.window.pointer_surface_offset = state.window.popup_states[id].offset;
                } else {
                    state.window.pointer_surface_offset = (0.0, 0.0);
                }
                // ...
            }
            ...
        }
    }
}
```

→ split borrow が Rust borrow checker 上 OK (`state` の異なる field path)。

### A4.4 method 移管: Connection-side delegation

```rust
impl WaylandConnection {
    /// Called from Dispatch impls that need both connection-global state
    /// and per-window state. Body originally in WaylandWindow.
    pub(crate) fn fire_ready_if_pending(&mut self) {
        if !self.window.configured { return; }
        if self.window.qh_cached_is_some_and_globals_ready() {
            if let Some(f) = self.window.ready_fn.take() {
                f(self);  // ready callback takes &mut UiState = &mut Self
            }
        }
    }
}
```

→ ready_fn が Window field だが、ready_fn 発火は Connection method (state-globals 確認が必要)。

### A4.5 ★ pending 検討: 大量 method 移管の Connection-side 配置

WaylandWindow に現存する 18 method のうち:
- `Window::new` / `Window::set_title` / `Window::on_*` / `Window::alloc_*` / `Window::popup_state` / `Window::set_device_lost_repaint` (~15) は per-window action ゆえ Window に残置
- `Window::run` は trampoline (A2 既述)
- `Window::create_popup` は connection-global object (wm_base, qh_cached) を要するゆえ Connection method に移管 (`WaylandConnection::create_popup(&mut self, parent_window: &mut Window, config) -> Result<PopupWindow>`)
- `Window::draw_frame(qh)` は同様に Connection method に移管 (`WaylandConnection::draw_frame(qh)` 内で `self.window.X` 参照)

★ create_popup signature 変更は App::run 内呼出も影響 (app.rs 内検索)。

---

## A5. App::run 再構成 plan

### A5.1 現 App::run (app.rs:1797-2575)

```rust
pub fn run(mut self, mut root: Box<dyn Widget>) -> Result<()> {
    // ...setup...
    let mut window = WaylandWindow::new(self.config.width, self.config.height);
    window.set_device_lost_repaint(...);
    window.min_size = self.config.min_size;
    window.max_size = self.config.max_size;
    window.layer_shell_config = self.config.layer_shell;
    window.clipboard_copy_buffer = ...;
    window.clipboard_paste_request = ...;
    window.dnd_renegotiate_request = ...;
    window.pending_drag_start = ...;
    window.pending_drag_outcome = ...;
    window.cursor_shape_buffer = ...;
    window.move_request = ...;
    window.window_action = ...;
    window.ime_enable_request = ...;
    window.ime_cursor_rect = ...;
    for reg in self.channel_registrations { window.register_channel(reg); }
    window.on_draw(...);
    window.on_event(...);
    window.on_event_mut(...);
    window.on_popup_phase(...);
    window.on_gpu_draw(...);
    window.on_vk_draw(...);
    window.set_title(&self.config.title);
    window.run()?;
    Ok(())
}
```

### A5.2 S1 後の App::run

```rust
pub fn run(mut self, mut root: Box<dyn Widget>) -> Result<()> {
    // ...setup...
    let window = Window::new(self.config.width, self.config.height);
    let mut connection = WaylandConnection::with_window(window);

    // per-window field 設定 (Window へ):
    connection.window.set_device_lost_repaint(...);
    connection.window.min_size = self.config.min_size;
    connection.window.max_size = self.config.max_size;
    connection.window.layer_shell_config = self.config.layer_shell;
    connection.window.cursor_shape_buffer = ...;
    connection.window.move_request = ...;
    connection.window.window_action = ...;
    connection.window.ime_enable_request = ...;
    connection.window.ime_cursor_rect = ...;
    connection.window.set_title(&self.config.title);
    connection.window.on_draw(...);
    connection.window.on_popup_phase(...);
    connection.window.on_gpu_draw(...);
    connection.window.on_vk_draw(...);

    // connection-global field 設定 (Connection へ):
    connection.clipboard_copy_buffer = ...;
    connection.clipboard_paste_request = ...;
    connection.dnd_renegotiate_request = ...;
    connection.pending_drag_start = ...;
    connection.pending_drag_outcome = ...;
    connection.quit_flag = Some(...);
    for reg in self.channel_registrations { connection.register_channel(reg); }
    connection.on_key(...);  // ★A1.5 B案なら window.on_key
    connection.on_event(...);  // ★A1.5 B案なら window.on_event
    connection.on_event_mut(...);  // ★A1.5 B案なら window.on_event_mut

    connection.run()?;
    Ok(())
}
```

### A5.3 公開 signature 不変 (AC)

`pub fn App::run(mut self, mut root: Box<dyn Widget>) -> Result<()>` は不変。
`pub fn WaylandWindow::run(&mut self) -> Result<...>` は trampoline で保持 (A2)。

---

## A6. Scope-out 3 helper の正規 rebind plan

### A6.1 reset_keyboard_focus_if_stale (app.rs:2940)

現:
```rust
fn reset_keyboard_focus_if_stale(window: &mut WaylandWindow, surviving: &[PopupId]) {
    // reads/writes window.keyboard_focus only (per-window)
}
```

S1:
```rust
fn reset_keyboard_focus_if_stale(window: &mut Window, surviving: &[PopupId]) {
    // 同一 body (純 per-window)
}
```

→ **trivial rename** (WaylandWindow → Window、type alias 経由で実は変更不要、明示性のため type だけ明示)。

### A6.2 popup_phase_apply (app.rs:2953)

現 body が touch する field/method:
- per-window: `window.popup_state(id)` / `window.released_popup_buffers` / `window.alloc_reposition_token()` / `window.last_press_pointer_serial` / `window.create_popup(req.config)` (← create_popup は A4.5 で Connection method に昇格予定)
- **connection-global**: `window.wm_base` / `window.qh_cached` / `window.seat`

★ **dispatch text と現コードの整合検証 (Pattern 4 push-back)**:
> dispatch: `popup_phase_apply<F>(active_popups, window: &mut Window, ...)`

→ **不整合**: 本関数は wm_base / qh_cached / seat = connection-global 3 field を読む。`&mut Window` だけでは access 不可。

**resolution proposal (worker1 推奨)**:
```rust
fn popup_phase_apply<F>(
    active_popups: &mut Vec<ActivePopup>,
    connection: &mut WaylandConnection,  // ← &mut Window から change
    request: Option<PopupRequest>,
    mut paint_popup: F,
) -> Vec<PopupWidgetToken>
where F: FnMut(&mut Renderer, PopupId),
{
    // connection.window.popup_state(...) など per-window access
    // connection.wm_base, connection.qh_cached, connection.seat: connection-global
}
```

★ alternative (split borrow):
```rust
fn popup_phase_apply<F>(
    active_popups: &mut Vec<ActivePopup>,
    window: &mut Window,
    globals: &ConnectionGlobals,  // wm_base/qh_cached/seat の read-only borrow
    request: Option<PopupRequest>,
    mut paint_popup: F,
) -> ... { ... }
```

→ split borrow は Connection に新 sub-struct 追加 + arg count 増の cost あり。**worker1 推奨 = 上の proposal (Connection 受)** simpler。boss1 review で確定希望。

### A6.3 dnd::start_drag (dnd.rs:203)

現 body が touch する field:
- **connection-global**: `window.clipboard` (seat-bound; A1.2 で Connection 分類)
- per-window: `window.surface` (per-window)

★ **不整合**: 本関数も Window + Connection 両方の access を要する。

**resolution proposal (worker1 推奨)**:
```rust
pub fn start_drag(
    connection: &WaylandConnection,  // ← &Window から change
    mime_types: &[&str],
    serial: u32,
    qh: &QueueHandle<UiState>,
) -> Option<wl_data_source::WlDataSource> {
    let clip = connection.clipboard.as_ref()?;
    let surface = connection.window.surface.as_ref()?;
    // ...
}
```

★ boss1 review で確定希望。

### A6.4 scope-out rebind まとめ

| helper | dispatch 仕様 | worker1 proposal | 理由 |
|---|---|---|---|
| reset_keyboard_focus_if_stale | &mut Window | &mut Window ✓ | 純 per-window |
| popup_phase_apply | &mut Window | **&mut WaylandConnection** ★ | wm_base/qh_cached/seat 要 |
| start_drag | &Window | **&WaylandConnection** ★ | clipboard 要 |

★ **Pattern 4 push-back**: dispatch text の Window 受 spec は popup_phase_apply / start_drag で実コード不整合、Connection 受への変更を提案。

---

## A7. WaylandWindow::run trampoline preservation (BC)

`crates/hayate-platform/examples/*.rs` 10+ files が `WaylandWindow::new(...).run()` 直接呼出。**全 BC 保持**のため trampoline:

```rust
impl Window {
    pub fn run(&mut self) -> Result<(), Box<dyn Error>> {
        // Take ownership of `self` per-window content
        let window = std::mem::replace(self, Window::new(0, 0));
        // Build a Connection wrapping it
        let mut connection = WaylandConnection::with_window(window);
        // Run the Connection's event loop (real run logic)
        let result = connection.run();
        // Restore self (caller may introspect window state after return)
        *self = connection.window;
        result
    }
}
```

→ examples 全件 unchanged compile + run。

---

## A8. inline test migration (必要分のみ)

### A8.1 app_tests_inline.rs:646 (popup_phase_apply_returns_silently_when_shm_not_ready)

現:
```rust
let mut window = WaylandWindow::new(10, 10);
assert!(window.shm.is_none() && window.qh_cached.is_none(), ...);
popup_phase_apply(&mut active, &mut window, None, |_, _| {});
```

S1:
```rust
let window = Window::new(10, 10);
let mut connection = WaylandConnection::with_window(window);
assert!(connection.shm.is_none() && connection.qh_cached.is_none(), ...);
popup_phase_apply(&mut active, &mut connection, None, |_, _| {});
```

### A8.2 他 inline test (popup_phase_apply_no_op_when_empty / no_paint_with_empty / does_not_call_back)

popup_phase_apply 引数が Connection 受に変わるので、これらも:
```rust
let window = Window::new(10, 10);
let mut connection = WaylandConnection::with_window(window);
popup_phase_apply(&mut active, &mut connection, None, |_, _| {});
```

### A8.3 wayland.rs inline test (1722-1900 範囲、vulkan/keyboard_focus 系)

これらは per-window field (vulkan_disabled / dmabuf_* / vk_renderer / keyboard_focus) のみ touch。**変更不要** (Window が今の WaylandWindow と同じ per-window content)。

★ A8.1/A8.2 update は popup_phase_apply signature 変更 (A6.2) に紐付くゆえ Phase B で一斉に。

---

## A9. Phase B (atomic 反映) plan

Phase A (本 doc) review 通過後、以下 small commit chain:

| step | 内容 | cargo check 緑保証 |
|---|---|---|
| B1 | `Window` struct rename in wayland.rs (in-place、52 per-window field のみ残置・37 connection-global field 削除) + `pub type WaylandWindow = Window;` BC alias 追加 | 一時 broken (37 field 未配置)、B2 で復旧 |
| B2 | 新 `WaylandConnection` struct を `platform/connection.rs` に作成、37 connection-global field + `pub window: Window` 配置 + `with_window` constructor + 空 `run()` stub。`UiState = WaylandConnection` flip。`mod.rs` re-export 更新 | broken のまま (Dispatch impl 旧 field 参照) |
| B3 | `WaylandConnection::run` body 移管 (元 WaylandWindow::run の body をそのまま移植、`self.X` → 適切な `self.X` or `self.window.X`) | broken のまま |
| B4 | 35 Dispatch impl body 内 field 参照を `state.X` or `state.window.X` に書換 (file 単位 small commits、dispatch_impls / clipboard / hidpi / popup / ime / dmabuf / cursor 順) | 各 file 完遂で check 緑 |
| B5 | App::run 内部再構成 (A5.2 plan) | check 緑 |
| B6 | scope-out 3 helper rebind (A6 plan、popup_phase_apply + start_drag の Connection 受) + 全 caller 更新 | check 緑 |
| B7 | inline test migration (A8 plan) | check 緑 + test 806 passed 再確認 |
| B8 | WaylandWindow::run trampoline impl (A7) + hayate-kit --lib check 緑 + 最終 cargo test 806 passed 確認 | 全緑 |

★ B1-B3 は intermediate broken state (Pattern 1 sequential rename の Stage 内例外 = [[feedback_cumulative_by_stage_pattern]])。B4 完遂で復旧。

---

## A10. 主要 design 判断サマリ (boss1 review 要請)

| # | 項目 | worker1 推奨 | 理由 |
|---|---|---|---|
| D1 | WaylandWindow → Window rename + BC alias | ✓ 採用 | RFC §6 S1 「新 Window struct」遵守 + 全 BC 保持 |
| D2 | Connection.window: Window (Option 不要) | ✓ direct | S1 always-1-window、Option overkill |
| D3 | ファイル配置: connection.rs split | ✓ split | 500 行 guideline + cohesion |
| D4 | scale_manager → Window (A 案) | ✓ Window | RFC §0.2-a + codex F2 重視、S2 で再 migrate 不要 |
| D5 | key_fn / event_fn / event_fn_mut → Window (A1.5 B 案) | ✓ Window | S2 per-window 化整合 |
| D6 | popup_phase_apply: Connection 受 (Pattern 4 push-back) | ✓ Connection | wm_base/qh_cached/seat 要、Window 受不可 |
| D7 | start_drag: Connection 受 (Pattern 4 push-back) | ✓ Connection | clipboard 要、Window 受不可 |
| D8 | reset_keyboard_focus_if_stale: Window 受 | ✓ Window | 純 per-window、dispatch 仕様通り |
| D9 | WaylandWindow::run trampoline 保持 | ✓ 採用 | examples 10+ BC |

★ boss1 review で D1-D9 全件確定後、Phase B 着手。

---

## A11. Pattern 4 押し戻し (revision 履歴)

### v0.1 (本 doc)
- 全 89 field 分類 (A1)
- Connection / Window draft (A2-A3)
- delegation pattern (A4)
- App::run plan (A5)
- scope-out rebind ★Pattern 4 push-back 2 件 (popup_phase_apply / start_drag → Connection 受、dispatch text の Window 受 spec を訂正提案)
- trampoline plan (A7)
- inline test migration (A8)
- Phase B step plan (A9)

### 後続 (boss1 review 後)
- v0.2: boss1 review finding 反映
- v0.3 以降: Phase B 各 step 完遂時の incremental note
