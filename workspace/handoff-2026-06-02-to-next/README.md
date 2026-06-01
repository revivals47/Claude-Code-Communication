# Handoff 2026-06-02 — multi-window L1 S5b 再開用 snapshot

次 session（別 PC 可）の Claude (PRESIDENT) は新規 session 開始時に本 README + `memory-snapshot/` を Read して context 復元。

## 本セッション（2026-06-02）サマリ

GUI_kit (Hayate UI) の **multi-window L1 initiative** を大きく前進。前半に repo hygiene、後半に S4 + S5a を land。

### 1. repo hygiene（full 整理）
- PR #193（multi-window L1 RFC v0.5）main merge → RFC が source-of-truth として main 着地（`docs/rfc-multi-window-l1.md`）
- merged 済 worktree 8 件削除 + merged local branch 27 本 prune（48→21）。未追跡 design 提案 18 doc を main に保全 commit。

### 2. multi-window L1 S4 ✅ MERGED（PR #219 → main 14f2b62）
- **API surface + lifetime plumbing**: `open_window`/`close_window` + run wrapper（build_window DRY factor）+ has_open_windows loop + SIGINT teardown + hayate-kit re-export + WindowConfig surface 拡張。
- 実窓は HashMap 1 entry 維持、**single-window bit-exact（AC6）**。
- D1 errata（decorations enum 格上げ構造不可）+ OQ1=a lock-in（WindowManager dead stub 削除）。

### 3. multi-window L1 S5 sub-phasing LOCK-IN + S5a ✅ MERGED（PR #220 → main d50bbba）
- **S5 sub-phasing（PRESIDENT lock-in、SD 同格）**: `S5a → S5b → {S5c, S5d}`、**plumbing-first 哲学**（bit-exact refactor 先行、機能 flip=2窓目 open を S5b に集中、AI-verifiable headless 最大化、user-live を S5b+ に寄せる）。
- **S5a = per-window render plumbing**（全 1-entry bit-exact、headless 完結）: draw_all_windows / frame-callback per-window routing（4th draw site）/ create_window_surface full per-window / Window.id invariant / force_device_lost fault-injection（AC4）/ per-window scale unit（AC10）。
- codex design-gate 3-round + impl-review（REVISE/高1→再 LGTM/0）= 計 5 round。dual seam-proof（S4 commit9 cure）。

## 現在の HEAD（全 push 済）
- **GUI_kit main = `ce24d39`**（S5a merge d50bbba + S5b survey docs commit）。origin 同期、worktree clean。
- 残 worktree = main + UNMERGED 7（track-r2-2/r2-4, track-r4-audit, track-w3-spin-followup, w2-chrome, w2-icons, worker2-iar）= S5 と無関係の別 WIP、保持。

## ★次タスク = S5b（S5 の本丸、初の user-live verify）★

S5b = **runtime で 2 窓目を実際に live connection 上に open** する段。S5a で render plumbing は全 path per-window 化済ゆえ、S5b は「実際に 2 個目を生やす」に集中可。

### S5b 起点 doc（GUI_kit main にコミット済、必読）
1. `workspace/worker1-notes/s5b_prep_survey.md` — worker1 survey（S1-S8 手順、runtime 2窓目 open gap）
2. `workspace/boss1-notes/s5b_presurvey_buildwindow_boundary.md` — boss1 境界分析

### S5b 核心（pre-survey で判明）
- **最大 gap**: `build_window`（app.rs:1810-2658、~848 行）は App 依存（~14 Rc channel clone + config/a11y/theme 読取）。**App は run trampoline で move 消費** → runtime（Connection event loop = `&mut UiState`）から build_window 到達不能。
- **boss1 lean（素地、未 lock-in）= option (b)**: factory-closure を run 前に Connection へ register（App 生存中に Rc capture → runtime invoke）。option(a) 全切出し=scope 肥大 / (c) caller pre-build=非現実的。
- **★真の中核設計 = per-window vs shared channel split★**（option 選定より深い論点）: clipboard/cursor/dnd = process-global 共有が正 / window_action/ime_cursor/title/size/quit = per-window 要検討。
- S1（id allocator: Connection counter or next_window_id 移管）は従属。
- design 時 further sub-split 検討可（runtime open wiring / WindowState lifecycle 再導入 / routing e2e）。

### S5b の AC（AI-verify / user-live 分類）
- **[user-live 必須]** AC1（2窓同時可視）= WAYLAND_DEBUG + 目視、**AI 不可ゆえ user が実機起動して確認**。
- [AI-verify + user-live] AC3（routing 誤配送ゼロ）。
- WindowState lifecycle（Window.lifecycle 再導入、4状態/7assertion、S4 §S5 carry + s4 design draft §3.2）。
- AC10 scale routing（S5a で defer 分）。

## S5c / S5d（S5b 後）
- S5c = per-window popup（R6/AC7、OQ2 PopupId→WindowId）
- S5d = per-window a11y（R7/AC11 focus+bounds）+ per-window title 消費（AC2、S5a で WindowConfig.title carry 済未消費、hardcode 廃止）

## 再開手順
```bash
cd ~/Documents/GUI_kit
git fetch origin && git pull --ff-only origin main   # → ce24d39
# 必読: docs/rfc-multi-window-l1.md (R1/R2/R4/R6/R7) + workspace/{worker1,boss1}-notes/s5b_*.md
cd ~/Documents/Claude-Code-Communication
git fetch origin && git pull --ff-only origin main
# memory: project-multiwindow-l1 (S0-S5a 履歴 + S5b scope)
```

## 確立した運用規範（本 session 実証、S5b でも踏襲）
- **plumbing-first sub-phasing**: bit-exact refactor 先行 → 機能 flip を後段集中。AI capability boundary（live visual は AI 不可）と整合。
- **PRESIDENT 独立 verify**: relay 鵜呑み禁止、finding/claim を自分で grep/cargo 裏取り（本 session で D1 errata / 4th draw site / Window.id hardcode / merge-gate 全て自走）。
- **codex 多層 gate**: design-gate（複数 round）+ impl-review（複数 round、adversarial 指示）+ codex 自発 verify。
- **scope 完成 vs 拡張の判別**: 既 intent（引数で id を受ける等）に内包される未完成は「scope 完成」として取込（leaky plumbing 防止）。F2 / R2-F1 / create_window_surface body で適用。
- **seam-proof 必須**: test が production の実 loop/helper を同一 consume + neuter で実 FAIL 実証（false-confidence test 排除、S4 commit9 起源）。
- **merge-gate（PRESIDENT 自走）**: chain clean / full cargo(-j1) / golden env-drift bit-exact / **非 test build warning-clean** / seam-proof / description fidelity / codex trail → 全クリアで同 turn squash merge。
- **branch 削除は end-state verify**: gh `--delete-branch` は worktree 占有で local 削除 fail → remote も不発。`git push origin --delete` 明示 + gh API で確認（ls-remote は propagation lag あり）。
- **crash recovery**: boss1 が落ちても disk（worktree/draft/codex 出力）は無傷、PRESIDENT context + memory で復元可。本 session で 2 回 recovery、code 喪失ゼロ。
  - ⚠️ 本 session で boss1 が 2 回 crash。頻発するなら multiagent tmux 環境/メモリ要因の調査余地。

## memory snapshot
本 session の核 memory を `memory-snapshot/` にコピー（次 PC の Claude memory に delta が無い場合の保険）:
- `project_multiwindow_l1.md` — S0-S5a 全履歴 + S5b scope + 確立規範（★S5b 再開の一次資料★）
