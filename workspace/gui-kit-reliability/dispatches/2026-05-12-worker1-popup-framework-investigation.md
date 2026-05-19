# worker1 dispatch — Phase 12 popup framework critical gap investigation

**発令**: 2026-05-12 / boss1 経由 PRESIDENT 即決
**担当**: worker1
**scope**: investigation only (実装着手は別 dispatch)

## 背景

2026-05-12 D smoke (PRESIDENT pane 代行) で hayate-notepad + GUI_kit examples/dropdown_demo の isolated 検証により Phase 12 popup framework 全体の wayland surface presentation gap が確定。R2-2 とは independent な pre-existing critical gap、dogfood 8 件 popup-emitting widget 全部に発現の可能性大。

詳細 memory: `project_phase_12_popup_framework_critical_gap.md` (boss1 本 turn で land 済)。

## 作業 worktree (新規作成、worker3 と隔離)

- **path**: `~/Documents/GUI_kit-track-popup-framework`
- **branch**: `track-popup/framework-presentation-investigation`

worktree 作成手順:

```bash
cd ~/Documents/GUI_kit
git fetch origin
git worktree add ../GUI_kit-track-popup-framework -b track-popup/framework-presentation-investigation origin/main
```

※ worker3 (`~/Documents/GUI_kit-track-r2-2`, branch `track-r2/r2-2-menubar-flex`) と完全隔離。worktree 隔離プロトコル遵守。

## scope = investigation phase のみ

- grep + 仕様考察、実装着手しない
- root cause 特定 + 修復 RFC draft
- 実装は別 dispatch (本 task 完了後 boss1 が判断、worker3 担当想定)

## 候補 root cause 仮説 (PRESIDENT 補佐 pane 提示、F が最濃厚)

- **F**: app.rs L1983 silent failure (`window.create_popup()` Err case が無 log)
- **A**: Wayland xdg_popup `wl_surface` attach/commit silent path 抜け
- **B**: popup buffer SHM pool 設定問題 (buffer 描画されない)
- **D**: xdg_surface `ack_configure` popup で missing → compositor が popup を ready と見なさない
- **E**: 環境問題 (特定 GNOME mutter / Wayland session で xdg_popup silent fail)

## 確認すべき code path

- `src/app.rs` L1865-2030 `popup_phase_apply` (silent failure 経路)
- `src/platform/wayland.rs` `create_popup` / `popup_phase_fn` 周辺
- `src/platform/popup.rs` `PopupWindow` 実装 (`render_frame_cpu` + buffer pool)
- Phase 12 commit history: `git log src/platform/popup.rs src/app.rs` で recent fix bisect

## 検証手段

- `examples/dropdown_demo` / `popup_anchor_matrix` / `popup_constraint_matrix` / `popup_dropdown_demo` の trace 出力
- 実機実行は PRESIDENT pane (work-PC president pane Claude Code) に request 投げて代行可
- log instrumentation 追加 (silent failure 経路の visibility 化) も検討、ただし実装着手は別 dispatch、本 task 内では追加しない

## 完了条件

- 仮説 F/A/B/D/E のうち最も濃厚なものを root cause として絞り込む
- 3-5 段の grep trace + `popup_phase_apply` → `window.create_popup` → `popup_phase_fn` → xdg_popup attach/commit chain 精査
- 修復 RFC draft (実装方針 + 影響範囲 + cross-cutting decision)

## 成果物

`~/Documents/GUI_kit-track-popup-framework/workspace/worker1-notes/popup-framework-presentation-investigation.md`

含むべき内容:
- 仮説 F/A/B/D/E の grep evidence + 絞り込み根拠
- 修復 RFC draft (実装は別 dispatch、scope と影響範囲を明記)
- next dispatch 候補 (worker3 R2-2 worktree readability の利点活用 vs worker1 継続)

## OOM 回避

grep 主体、`cargo check` / `cargo run` は最小限 (`-j1` + 単 example のみ)、実機 verify は PRESIDENT pane 代行優先。

## 規範遵守

- worktree 隔離 (worker3 と別 dir、別 branch、別 worker pane)
- **verify before recommending** (memory 規範): 仮説は src grep evidence で確定、推測のみ提示しない
- **root cause over quick fix** (memory 規範): silent failure 周辺の band-aid (log 追加のみ) ではなく root cause 修復 RFC を draft
- **agent-send.sh messages must not contain bash-interpretable code snippets** (memory 規範): 報告は要点 + path のみ

## 完了後

boss1 へ報告。修復 RFC draft 内容に応じて implementation phase の dispatch 担当 (worker1 継続 / worker3 / 並走) を boss1 が決定。
