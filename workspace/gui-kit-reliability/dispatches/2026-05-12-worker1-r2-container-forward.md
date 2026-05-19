# worker1 dispatch — R2 container popup callback forward 実装

**発令**: 2026-05-12 / PRESIDENT 即決 (boss1 経由、user 上申 → user 承認 → codex 査読反映済)
**担当**: worker1
**scope**: implementation (architectural fix、popup framework critical gap root cause 修復)
**worktree**: `~/Documents/GUI_kit-track-popup-r1` (branch=`track-popup/r1-silent-failure-log` @ 02b7e93 継続)
**branch 戦略**: R1c branch (`track-popup/r1-silent-failure-log`) 上に R2 commits を積む。R1 observability + R2 forward を統合 PR `track-popup/r1+r2-framework-fix` として最終 raise (boss1 と確認後)

## 前提 / 背景

worker1 round 1-3 (R1+R1b+R1c eprintln land 状態) + R5 round 2 WAYLAND_DEBUG trace 採取で **ROOT CAUSE 確定**: container widget (`VStack`/`HStack`/`Padding`) が `popup_request`/`on_popup_dismissed`/`paint_popup` を override せず Widget trait default `None`/no-op で **child へ forward しない**。pp1a→pp1b 移行時の設計事故。

詳細解析 + RFC R2: `~/Documents/GUI_kit-track-popup-r1/workspace/worker1-notes/r5-round2-summary-2026-05-12.md` (codex 査読 2026-05-12 反映済)

## 作業 scope (R2-A 〜 R2-H、codex 査読反映済)

### R2-A: container `popup_request` first-Some forward

- 対象: `VStack`, `HStack`, `Padding` を minimum
- **pre-step**: `impl Widget for ...` を全 grep + `children_mut()` を override している container を全列挙 (R2-D で sweep)
- 実装: `children_mut().iter_mut().find_map(|c| c.popup_request())`
- pp1a single-popup 制約維持、後続 child は frame 単位で skip
- comment で「first-Some is pp1a-constrained; multi-popup phase で revisit」明記

### R2-B: container `on_popup_dismissed` token-dispatch forward

- 全 child forward (`for c in children_mut() { c.on_popup_dismissed(token); }`)
- child 側で token 一致 gate (default impl no-op、popup 持つ widget は token 比較で state clear)
- **pre-step**: DropdownWidget / TooltipWidget / ContextMenu の on_popup_dismissed override 実在を grep で sweep、欠落あれば本 R2 内で追加

### R2-C: container `paint_popup` 同様 forward

- 全 child forward、popup_id / popup_token gate
- token 一致 child のみが描画、他は no-op

### R2-D: 他 container widget の grep + 横展開 (pre-step 必須)

- `impl Widget for` 全 grep
- `children_mut()` override widget 全列挙
- forward 実装漏れがないか sweep
- dynamic widget (children runtime 可変) も対象

### R2-E: tests 追加 (regression 防止)

必須 test ケース:
1. **multi-level nest**: `VStack(Padding(VStack(Dropdown)))` で popup_request が Some
2. **single-popup pp1a constraint**: `VStack(Text, Dropdown(open=true), Tooltip(visible=true))` で先頭のみ Some、Tooltip suppressed
3. on_popup_dismissed 後、再 popup_request が Some (state machine)
4. **既存 test sweep**: container popup_request → None 期待の test を grep + 修正

### R2-F: dogfood 8 件 cargo check sweep

- 全 8 件 (notepad/freecell/solitaire/pinball/linux-gallery/agents-linux/agents-linux-v2/gpu-furnace)
- container forward は binary 互換、cargo check 緑であるべき
- 失敗あれば原因解析 + 報告

### R2-G: 実機 verify (revivals47 操作必須)

- dropdown_demo + popup_anchor_matrix で WAYLAND_DEBUG trace 採取
- `xdg_popup` mention 出現確認 (round 1/2 zero → R2 後 non-zero 確認)
- hayate-notepad + dogfood 8 件のうち 2-3 件 sample で実機 popup visible 確認
- ※ revivals47 (user) の click 操作必須、PRESIDENT pane 経由で依頼

### R2-H: R2-2 (MenuBar) 統合判断

- **推奨 Option B (分離)**: 本 R2 を独立 land → R2-2 を rebase + retest → 別 PR で land
- boss1 と確認、R2-2 worker3 (track-r2/r2-2-menubar-flex @ d692b01) は本 R2 land 後に rebase verify

## 完了条件

- container forward 実装 commit (R2-A/B/C/D)
- test 追加 + 全 test 緑 (R2-E、`cargo test --all-targets --no-fail-fast -j1` で 1702+α passed 維持)
- dogfood 8 件 cargo check 緑 (R2-F)
- 実機 verify (R2-G) — WAYLAND_DEBUG trace で `xdg_popup` 出現確認は user 操作待ちで marker 化、PRESIDENT pane 経由で依頼
- R2-2 統合判断書 (R2-H) — boss1 確認後 confirm
- 完了報告 file: `~/Documents/GUI_kit-track-popup-r1/workspace/worker1-notes/r2-container-forward-impl-2026-05-12.md`

## OOM 回避

- `cargo build --example dropdown_demo -j1`
- `cargo test --all-targets --no-fail-fast -j1`
- 16GB 環境配慮、parallel rustc 禁止

## 規範遵守

- **root cause over quick fix**: 本 R2 は architectural fix、band-aid 厳禁
- **verify before recommending**: 各 R2-A/B/C 実装は実装後 cargo test + dogfood cargo check で確証
- **codex second opinion**: 本 dispatch は既に codex 査読反映済、PR 段階で再査読推奨
- **agent-send.sh messages must not contain bash-interpretable code snippets**: 完了報告は要点 + path 中心、code snippet は file path 参照
- **worktree 隔離**: worker3 R2-2 worktree (~/Documents/GUI_kit-track-r2-2) と別 dir、本 dispatch は R1c branch 継続で隔離 ◯

## next dispatch

worker1 完了報告 → boss1 確認 → PR raise (track-popup/r1+r2-framework-fix → main) → codex 査読 → merge → R2-2 unblock 判断
