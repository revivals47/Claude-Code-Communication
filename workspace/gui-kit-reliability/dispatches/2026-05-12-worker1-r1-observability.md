# worker1 dispatch — R1 silent failure log + observability 強化

**発令**: 2026-05-12 / PRESIDENT pane 直接 dispatch (緊急時許容、boss1 unblock 不能のため revivals47 PRESIDENT 直々承認の例外措置)
**担当**: worker1
**scope**: implementation (R1 + observability eprintln 追加、minimal patch)

## 前提

worker1 round 1 investigation 成果は同 worktree `workspace/worker1-notes/popup-framework-presentation-investigation.md` で land 済 (8m 32s で 5 仮説検証 + R1-R5 RFC + L1-L3 新発見)。

R5 (実機 WAYLAND_DEBUG trace) を PRESIDENT pane 代行で採取、**新発見** が trace summary に記録済:
- `~/Documents/GUI_kit-track-popup-framework/workspace/worker1-notes/wayland-debug-trace-2026-05-12.log` (1582 行 protocol trace)
- `~/Documents/GUI_kit-track-popup-framework/workspace/worker1-notes/r5-trace-summary-2026-05-12.md` (解析 + 仮説 revision)

**核心 finding**: trace 内に `xdg_popup` mention zero = popup 作成 wayland call が一切発火していない。L3 仮説 (popup Configure → draw_frame kick 不在) の前提崩壊、より上流の問題。**新上流仮説 G/H/I**:
- **G** (最濃厚): `popup_request` が None 返却 (DropdownWidget の `self.open=false` or `last_rect.width<=0` gate)
- **H**: `create_popup` 早期 Err で skip (仮説 F の wayland call 前段)
- **I**: `tick_popup_phase` 自体が未発火 (`popup_phase_fn` unset)

## 作業 worktree

- **path**: `~/Documents/GUI_kit-track-popup-framework` (round 1 と同じ、investigation branch 継続)
- **branch**: `track-popup/framework-presentation-investigation`
- **既存 deliverable は workspace/worker1-notes/ に保存済**

worktree 隔離プロトコル: worker3 `~/Documents/GUI_kit-track-r2-2` とは別 dir / 別 branch、競合なし。

## scope: minimal observability eprintln 追加 (R1 + G/H/I 切り分け統合)

実装は **3-5 line eprintln 追加のみ**、機能変更なし。debug build で行動 trace を可視化、release build では `#[cfg(debug_assertions)]` で gate するか runtime env var で gate (どちらでも boss1 codex review 前提)。

### 必須 eprintln (5 箇所、最小)

1. **`src/app.rs` L1982 `create_popup` Err 経路** (= R1 本体、worker1 round 1 §7.R1):
   ```rust
   match window.create_popup(req.config) {
       Ok(popup) => active_popups.push(ActivePopup { ... }),
       Err(e) => eprintln!("[popup] create_popup failed silently: {e}"),
   }
   ```
   仮説 F + H 観測。

2. **`src/app.rs` L1262 周辺 `popup_request` 取得直後** (仮説 G/I 観測):
   ```rust
   let request = app.root.popup_request();
   #[cfg(debug_assertions)]
   eprintln!("[popup] popup_request result: {}", if request.is_some() { "Some(req)" } else { "None" });
   ```

3. **`src/platform/wayland.rs` `tick_popup_phase` 入口** (仮説 I 観測):
   ```rust
   fn tick_popup_phase(&mut self) {
       #[cfg(debug_assertions)]
       eprintln!("[popup] tick_popup_phase fired, popup_phase_fn={}", self.popup_phase_fn.is_some());
       if self.popup_phase_fn.is_some() { ... }
   }
   ```

4. **`src/widget/dropdown.rs` `popup_request` 入口** (仮説 G 確証):
   ```rust
   fn popup_request(&mut self) -> Option<PopupRequest> {
       #[cfg(debug_assertions)]
       eprintln!("[popup] DropdownWidget::popup_request: open={}, last_rect.width={}", self.open, self.last_rect.width);
       if !self.open || self.last_rect.width <= 0.0 { return None; }
       ...
   }
   ```

5. **`src/widget/menu_bar.rs` `popup_request` 入口** (同 G 確証、ただし R2-2 patch 未適用 worktree のため popup_request 自体が無い可能性、確認のうえ skip 可):
   - origin/main 74b3406 では menu_bar に popup_request 不在、skip

### 受け入れ条件

- `cargo build -j1` 緑
- `cargo test --all-targets --no-fail-fast -j1` 緑 (test 追加なし、既存壊さない確認)
- `cargo run --example dropdown_demo` 起動 → PRESIDENT pane 代行で WAYLAND_DEBUG round 2 trace 採取依頼準備
- diff は ~10-20 行、scope creep 厳禁
- band-aid フレーミング明示 (root cause fix は R2、本 task は observability 強化のみ)

## 完了後

成果物:
- 上記 5 箇所 eprintln 追加の commit (branch 内、別 PR 候補ではない、investigation 内 work)
- 完了報告: `~/Documents/GUI_kit-track-popup-framework/workspace/worker1-notes/r1-observability-impl-2026-05-12.md` に impl summary + 次の dispatch (PRESIDENT pane に round 2 WAYLAND_DEBUG trace 採取 request) を書く
- PRESIDENT pane (この conversation) に worker1 直接報告 (boss1 経由不要、緊急時承認済): `./agent-send.sh president "あなたは PRESIDENT 補佐 pane の Claude Code です。worker1 R1+observability 完了報告。詳細: [path]"` の format で送信

## OOM 回避

- 単一 eprintln 追加のみ、cargo build -j1 (16GB OOM 配慮)
- cargo test 必要なら別途、`--all-targets` 1 回のみ

## 規範遵守

- **root cause over quick fix**: 本 task は observability 強化 (band-aid + 確証作り)、明示。R2 root cause fix は別 dispatch
- **agent-send.sh は要点 + path のみ**: 完了報告も path 参照中心
- **codex second opinion**: 不要 (10-20 行の eprintln 追加、micro-patch)
- **PRESIDENT 即決承認**: 本 dispatch 自体が緊急時許容で boss1 bypass、scope は事前承認済 round 1 RFC の R1 + observability subset

## next dispatch

worker1 完了報告着信 → PRESIDENT pane が round 2 WAYLAND_DEBUG trace 採取代行 → trace summary 解析で仮説 G/H/I 確定 → root cause 確定後 R2 implementation dispatch (worker3 R2-2 implementation phase 経験者 or worker1 継続) を判断
