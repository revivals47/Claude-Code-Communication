# Task A Phase 3 option α — indep prep (structural)

**status**: draft v0.1, indep prep during dispatch wait (boss1 18:28 hint、PRESIDENT 上申中)
**author**: worker3 (Task D + send_bar triage 完遂後 idle、2026-05-31)
**purpose**: option α (eprintln 埋込) GO 受領時の即着手化準備

**scope honesty**: 本 prep は **structural** (3 site の役割 + revert 容易性) のみ。具体的 eprintln message text + diagnostic intent は Task A failure spec 未着信ゆえ speculative 排除、GO 時の boss1 / worker2 提示文に従う。

## 1. 3 site 概要 (worker2 提示)

3 site は GUI_kit chrome action pipeline の **set → poll → dispatch** chain:

```
[USER click]
   ↓
 title_bar.rs:885  (action.set(WindowAction::X))      ← site 1: SETTER
   ↓
 app.rs:770        (event_with_csd: forward to chrome) ← site 2: ROUTER
   ↓
 connection.rs:658 (wa.get() + dispatch match)         ← site 3: DISPATCHER
   ↓
[xdg_toplevel.close/maximize/set_minimized/_move/...]
```

## 2. site 1: title_bar.rs:885 — action setter

**file**: `crates/hayate-kit/src/widget/title_bar.rs:885`
**fn**: `<TitleBarWidget as Widget>::event`
**現状** (抜粋):
```rust
fn event(&mut self, event: &WidgetEvent) -> EventResponse {
    match event {
        WidgetEvent::PointerPress { x, y, button: 0x110, .. } => {
            if let Some(action) = self.hit_test_button(*x, *y) {
                self.action.set(action);          // ← eprintln 候補 A
                return EventResponse::Handled;
            }
            if self.is_in_bar_non_button(*x, *y) {
                self.action.set(WindowAction::DragMove);  // ← eprintln 候補 B
                return EventResponse::Handled;
            }
            EventResponse::Ignored
        }
        ...
    }
}
```

**diagnostic 機会**: hit_test_button が Some を返したか + どの action か + bar drag に落ちたか。

**eprintln 入れる時の規範**:
- prefix `[chrome]` で他 log と区別容易
- file:line hint (`title_bar.rs:setter`) で trail 識別
- action 値そのまま format (Debug impl で済む)

## 3. site 2: app.rs:770 — event router

**file**: `crates/hayate-platform/src/app.rs:770`
**fn**: `<AppState as Widget>::event_with_csd` (chrome forward path)
**現状** (抜粋):
```rust
fn event_with_csd(&mut self, event: &WidgetEvent) -> EventResponse {
    if let Some(ref mut slot) = self.chrome {
        let resp = slot.event(event);             // ← chrome consumes here
        if resp != EventResponse::Ignored {
            return resp;                          // ← eprintln 候補 C: chrome 経由 short-circuit
        }
    }
    // Offset pointer events into the client coordinate system: the chrome
    // height on y, plus the outer window-frame border on both axes.
    let csd_h = self.csd_height();
    let b = self.frame_border();
    let top = b + csd_h;
    ...
}
```

**diagnostic 機会**: chrome に到達した event 種別 + chrome response (Handled/FocusMe/Ignored) + client へ pass-through するか。

**注意**: PointerPress 以外も流れる (Key / PointerMove / etc)、eprintln は PointerPress 限定 filter 推奨 (log flood 回避)。

## 4. site 3: connection.rs:658-703 — action dispatcher

**file**: `crates/hayate-platform/src/platform/connection.rs:658-703`
**fn**: `Connection::run` 内 main loop の WindowAction poll
**現状** (抜粋):
```rust
if let Some(ref wa) = window!(self).window_action {
    use crate::window_action::WindowAction;
    let action = wa.get();
    if action != WindowAction::None {
        wa.set(WindowAction::None);               // ← eprintln 候補 D: dispatcher 入口
        match action {
            WindowAction::Close => { ... }        // ← eprintln 候補 E: 各 arm 個別 (optional)
            WindowAction::Maximize => { ... }
            WindowAction::Minimize => { ... }
            WindowAction::DragMove => { ... }
            WindowAction::ShowWindowMenu { x, y } => { ... }
            WindowAction::None => {}
        }
    }
}
```

**diagnostic 機会**: setter から dispatcher に action が到達したか + どの arm で消費されたか + xdg_toplevel call が成功 path に乗ったか。

**注意**: poll は frame ごと実行 (高頻度)、`if action != WindowAction::None` 内側 eprintln にして None 時は出力ゼロにすること。

## 5. ~15 行 budget 内訳 (worker2 提示数値)

site 1 (setter): ~3-5 行 (hit_test_button arm + drag arm + miss case)
site 2 (router): ~3-4 行 (chrome consume / pass-through)
site 3 (dispatcher): ~5-7 行 (entry + arm 個別 or 集約)
**計** ~11-16 行 (worker2 ~15 行 推定と整合)

## 6. revert 容易性

eprintln は **purely additive、source 挙動不変、commit revert 容易**:
- 既存 logic / control flow に手を加えない (eprintln は side-effect only)
- 1 commit に集約すれば `git revert <sha>` 1 発で原状復帰
- 1 file ごと commit 分けて bisect 容易性 + 個別 revert も選択肢
- AC: `cargo check -p hayate-platform` `cargo check -p hayate-kit` 緑 (eprintln 自体は型 / borrow 違反生まない)
- output は stderr ゆえ test harness の stdout assertion を壊さない

## 7. cargo verify 想定 (option α 採択時)

- `cargo check -p hayate-platform -j1` 緑
- `cargo check -p hayate-kit -j1` 緑
- `cargo build -p hayate-platform -j1` 緑 (eprintln 含む binary 動作確認)
- `cargo test -p hayate-platform --lib -j1` = 既存 baseline 維持 (eprintln test output 干渉なし confirm)
- (option) dogfood 1 app `cargo run` で eprintln 出力 sanity check

## 8. boss1 推奨 worktree (option α GO 時)

- 推奨: `~/Documents/GUI_kit-task-a-phase3` 新規切出 + branch `feat/task-a-phase3-trace` (or boss1 命名)
- worker1 S3 hold 中 + worker2 popup_validation 並走想定ゆえ worker3 用に切出
- base: GUI_kit main 69d224c (worker3 PR #208 land 後)

## 9. 注意点 (pre-flight checklist)

- [ ] **diagnostic intent 確認**: Task A の specific failure mode (= 何を観察したいか) を boss1 / worker2 提示文から拾う、本 prep は spec 不在前提
- [ ] **eprintln message text**: prefix (`[chrome]` 等) + file:line hint + 値 format は worker3 judgment、ただし boss1 review 要件あれば従う
- [ ] **PointerPress 以外 filter**: site 2 で全 event eprintln すると flood、PointerPress に絞る
- [ ] **None action filter**: site 3 で frame ごと None 出力させない
- [ ] **bit-exact 規範**: source logic 不変、test fail 0 件追加 confirm
- [ ] **PR scope**: 単発 PR (option α 専用)、Phase 3 本 fix とは別 commit/PR、merge 順序は boss1 判断

## 10. revision history

- **v0.1** (2026-05-31 18:23): 初版、structural 3-site mapping + revert 容易性 + cargo verify 想定 + worktree 推奨 + pre-flight checklist。Task A failure spec 不在ゆえ specific eprintln text は speculative 排除、GO 時の boss1 提示文に従う方針明記
- **v0.2** (2026-05-31 18:50): 採択後確定版
  - 2026-05-31 18:32 PRESIDENT option α GO 認可、boss1 worktree 切出 (~/Documents/GUI_kit-task-a-phase3、feat/task-a-phase3-eprintln-diagnostic、base 7f09739)
  - Task A failure spec: TitleBar single-click も dbl-click も完全無反応 (worker2 18:25 phase 2 + user 17:39 報告)
  - **site 1 title_bar.rs:885 (29 added / 4 modified)**: 3 click arm 全 instrument
    - L-press (button 0x110): entry eprintln (x/y/bar_rect/theme.h/hit_button result/in_bar_non_button) + action.set eprintln (per hit / DragMove / Ignored)
    - R-press (button 0x111): entry + ShowWindowMenu action.set
    - DoubleClick: entry + Maximize/Minimize per double_click_action arm
  - **site 2 app.rs:770 (20 added)**: event_with_csd 入口で click_kind filter (PointerPress L/R + DoubleClick のみ) + chrome consume 後 chrome_response 出力、chrome 不在 path も separate eprintln
  - **site 3 connection.rs:658 (5 added)**: action dispatcher 入口で action + has_xdg_toplevel 出力 (None action は既 filter で frame ごと出力ゼロ)
  - **AC verify**:
    - cargo check -p hayate-platform -j1: ✅ 緑
    - cargo check -p hayate-kit -j1: ✅ 緑
    - cargo build --examples -p hayate-kit -j1: ✅ 緑 (pre-existing 1 warning win95_memory_repro deprecated、無関連)
    - cargo test -p hayate-platform --lib -j1 --no-fail-fast: ✅ 808/0 (baseline 維持)
    - cargo test -p hayate-kit --lib -j1 --no-fail-fast: ✅ 1008/0
  - **budget over rationale**: worker2 推定 ~15 行 vs 実 51+/4-。over の理由 = Task A failure spec 「single-click も dbl-click も完全無反応」両方 instrument 要件 + 3 click arm (L/R/Double) 全 cover + action.set arm 個別出力で root cause arm 絞り込み容易化。dispatch eprintln format 仕様を 3 arm × ~6 行 で site 1 に実装、site 2/3 は仕様通り 1 行ベース
  - **revert 容易性**: 単 PR 1 commit、`git revert <sha>` 1 発で原状復帰、source logic 不変 (eprintln は side-effect only)
