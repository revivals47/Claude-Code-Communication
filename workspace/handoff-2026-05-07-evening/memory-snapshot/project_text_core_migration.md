---
name: text_core migration project (GUI_kit)
description: GUI_kit の TextAreaWidget engine を独立 module 化する 6 段階 migration。**Stage 3 + Stage 4 spec v1.0 全 main 反映完了 (2026-05-07、PR #74 41 commits + PR #76 spec v1.0 finalize、main HEAD 6f5b17e)**、Stage 4 round 全集約 outcome (入口判断 7 件 lock + 軸合致 8 件 + push back 19 件 resolution + §14/§15/§16/§17) 反映済、**Stage 5 mechanical batch 着手前提整い** (worker2 record_edit_at grep audit 着手、305 sites = mechanical 213 / case-by-case 92)。Stage 3 verify v1.3.1 (single-PC 運用認知、role/cadence 区別): 段階 a = 7 consumer worker3 自動 build smoke / 段階 b = notepad cargo test 厳格 (final candidate + API 変更時のみ)
type: project
originSessionId: 1035e373-fb86-4a60-805f-eb292e2c50a1
---
GUI_kit の `src/widget/text_area/engine.rs` を `src/text_core/` に独立 module 化し、最終的に CodeEditorWidget (Stage 4) を新設する 6 段階 migration project。GW 中 (2026-04-29〜2026-05-04) で Stage 1+2 完了、2026-05-07 で Stage 3 (TextAreaWidget 内部置換) commit chain 7 commits を完遂、PRESIDENT 完了承認受領、**同日 PR #74 で 41 commits atomic main merge 完了 (main HEAD 010eb6b、Stage 1 baseline → Stage 4 round phase 2 集約まで全反映)**。Stage 4 round phase 1+2 集約完了、spec v1.0 commit 着手 GO 待ち、Stage 5 mechanical batch 検討段階。

**Why:** TextAreaWidget engine が 305 caller (TextEditor 経由 160 + 直接 145) に diffuse、buffer/cursor/undo/grapheme/word logic が widget と密結合。独立 text_core で 7 consumer + work-PC notepad の API 安定性を保ったまま、CodeEditorWidget multi-tab 等の上位機能を別 widget で構築可能にする。

**Stage 状況 (2026-05-07 時点):**
- Stage 1 ✅ baseline=`67a4273` (regression_baseline 6 PASS / 1 ABSENT [hayate-notepad work-PC only] / 累計 548 tests green)、tests-first 5 axis matrix (roundtrip/multibyte-grapheme/trailing-newline/empty/undo) + regression floor 22 件
- Stage 2.1 ✅ worker1、word movement / NavDir 6→8 拡張 / shift extend land 済
- Stage 2.2 ✅ worker2、`src/specialized/text_editor_compat/` shim Day-A〜C (commit f796144 / cde54d2 / 93e0c24)
- Stage 2.3 ✅ worker3 主 + worker2 監修、editor 救出完了
- **Stage 3 ✅ 完遂** (2026-05-07 PRESIDENT 完了承認):
  - commit chain 7 commits: 57ae576 (v1.3 protocol + Stage 1 完了 marker baseline) → a5d10cd (Stage 3 entry baseline 再取得 R1 step 1+2) → fccb81e (P1 scaffolding) → d3fd3fb (P2 read paths swap) → 8604ae4 (step (4)(5) v1.3.1 docs) → 059638b (P3 dual-write pattern) → 59107fe (Stage 3 final、legacy 削除 3 files / -329 net)
  - aggregate gate 9/9 全緑 + Section B clean (両 trigger PASS) + 段階 b retained check 全緑 (notepad cargo build OK + test 0 passed/0 failed = baseline exact match + ABORT 0 + new red 0 + elapsed 0.40s + peak_rss_kb 53912)
  - TextAreaWidget が text_core::engine::Engine 単独 facade、public API signature 維持を work-PC tlcr 環境で確証
  - Stage 3 entry baseline (`tests/regression_baseline/_summary_2026-05-07b.md`): 7 PASS / 0 FAIL / 0 ABSENT、peak_rss_kb=1040044 (~1.04 GB)、elapsed=55.63s、swaps=0
  - v1.3.1 監視 threshold (Stage 3 commit chain 全長で使用): OOM alarm = peak_rss_kb >= 1352057 (x1.3)、絶対 ceiling = 12582912 (12 GB / 16 GB の 75%)、I/O 劣化 alarm = elapsed >= 111.26s (x2)
  - Section B grep (Stage 3 着手前 + 完了報告時、protocol §6 trigger 2 件): clean、6 consumer いずれも TextAreaWidget public API 未使用、notepad のみ唯一 caller (src/main.rs:26)
- Stage 4 ✅ **round 全集約 + spec v1.0 finalize 完遂 (PR #76 main 反映済、2026-05-07)**、入口判断 (d1)-(d7) 7 件 lock + 軸合致 8 論点 + push back 19 件 resolution embed:
  - (d1) multi-tab / (d2) delegation method / (d3) search 内蔵 SearchEngine 分離 / (d4) record_edit_at public + 戻り値型 `() → EditEvent` (案 Z LSP TextDocumentContentChangeEvent 互換 lean)
  - (d5) EditEvent と undo/redo boundary 対応規則 / (d6) SearchEngine sync/async + cancellation 単位 / (d7) multi-tab shared document or 完全独立 (codex 監査追加 3 点)
  - phase 1 集約: commit 28c3188 (worker1 response 反映 + push back P1-P9 worker3 view)
  - phase 2 集約: commit 010eb6b (PR #74 merge、worker2 response 反映 + P10-P12 + P-W2-1..7 + §5.4 path 訂正)
  - **spec v1.0 finalize: commit 6f5b17e (PR #76 merge、§14 push back resolution table + §15 LSP/undo 分離 + §16 delegation/lifecycle + §17 finalize summary)**
  - 軸合致 8 論点 (§3/§4/§6/Q1/Q3/(d5)/(d6)/(d7)) + push back 19 件 (P1-P9 + P10-P12 + P-W2-1..7) main 反映完了
- Stage 5 🚧 **mechanical batch 着手前提整う + 真 scope 46 sites 確定 (2026-05-07 worker2 P-W2-1 audit、PR #77)**:
  - **真 scope = 46 sites (mechanical 100%)**: production 4 + unit test 14 + integration test 28、全件 record_edit/_at 戻り値 discard pattern (let _ = ...)
  - 旧想定 305 sites (mechanical 213 / case-by-case 92 = 70:30) は Stage 6 別 scope (TextEditorCompat 削除に伴う TextEditor 全 method caller migration) と判明、Stage 5 と分離
  - 工数大幅軽量化: 16-17h ≈ 2-3 day → ~35-45 min (worker3 1 sprint 内)
  - **段階 b retained check 非該当** (worker2 audit finding): record_edit_at signature 変更は Engine method、TextAreaWidget public API 不変 + delegate 不経由
  - 段階 a 7 consumer 連続実行 verify は worker3 dispatch 時に必須 (protocol v1.3.1 §2.1)
  - 4 step batch: production → integration test → unit test → cargo test --all-targets
  - spec v1.0 patch commit (§4.6 「305 sites」訂正 + 新 §18 worker2 audit reference embed) は並行 commit 可
- Stage 6 📐 TextEditorCompat 削除 + caller migration:
  - **真 scope = 305 sites (TextEditor 全 method caller migration)**、Stage 5 完遂後に着手
  - hayate-linux-editor (work-PC 不在) は別途 audit dispatch、§5.4 言及 8+10 callers は Stage 6 着手時に整理 ((P17) (iii) 採用、2026-05-07)
- Stage 5 📐 editor migration、worker3 plan v0.1 (commit 90617cf)、Stage 4 完了後に v1.0 rewrite trigger
- Stage 6 📐 TextEditorCompat 削除、transient code 撤去

**Stage 3 verify 二段構成 v1.3.1 (2026-05-07 Resolved #3 部分撤回 + (X) single-PC 運用認知):**
- **段階 a (拡張 gate、高頻度 build smoke)**: **7 consumer** (notepad + freecell/solitaire/pinball/linux-gallery/agents-linux × 2) build + cargo test、worker3 自動 (work-PC tlcr)、`bash scripts/run_consumer_regression.sh --diff <date>`。gate = build_error=0 + ABORT=0 + new red=0 (notepad は test count exact match も含めて gate、他 6 は test count 不一致 info)
- **段階 b (retained check、低頻度厳格)**: `hayate-notepad` cargo test、worker3 (work-PC tlcr) で実施 → boss1 review → PRESIDENT 最終確認、**Stage 3 branch final candidate** または **API surface 変更 commit** のみ実行 (1-2 回見込み、毎中間 commit ではない)。**役割定義 (2026-05-07 codex 監査反映)**: (1) public API 唯一 caller (notepad) の実 consumer sentinel (2) integration smoke sentinel (build smoke を超えた動作確認) (3) Stage 4 以降の API drift 検知 (multi-environment 反証論拠は (X) 採用で失効、本 3 点で独立価値維持)
- baseline 取得: Stage 3 着手と同時固定 (Resolved #2 維持)、work-PC で baseline と current 両取り = clean diff (single-PC 運用認知)
- 中間 commit ごと gate (Resolved #4 維持)、段階 a のみ反復、段階 b は trigger 条件達成時のみ
- **Resolved #3 (notepad home-PC clone 不要) は 2026-05-07 部分撤回 + (X) 採用で再解釈**: 物理 home-PC 不要が確定 (single-PC 運用)、段階 b は廃止せず retained check として保持、role/cadence 区別で独立価値
- baseline summary の notepad 行 ABSENT → PRESENT 更新は **coverage 拡張** (仕様変更ではない) と明記、Stage 1 完了 marker は不変

**How to apply:**
- Stage 3 verify は work-PC tlcr で完結 (single-PC 運用、段階 a/b 共に同一 machine)、段階 b retained check は廃止せず final candidate / API 変更時に必ず実施
- baseline 取得は work-PC で worker3 自動 (Stage 3 着手と同時)、PRESIDENT 介入は段階 b の trigger 達成時のみ
- 段階 b trigger 条件: (i) Stage 3 commit chain の最終候補 (boss1 が「Stage 3 完了候補 commit」と宣言した時点) (ii) commit が TextAreaWidget public API surface (signature / pub fn 追加削除等) を変更した時点 — どちらか満たした時に PRESIDENT へ明示依頼
- 段階 b 結果は work-PC 上で生成、work-PC 内で commit / push (single-PC なので転送不要)、cross-machine 一致証跡は不要 (multi-env 反証論拠は (X) 採用で失効)
- ABORT/OOM 検出: 段階 a で 7 consumer 連続実行となるため、protocol に「7 consumer 連続時の ABORT/OOM 検出規範」を v1.3 で追記、I/O 劣化 / incremental cache 汚染も監視軸 (peak RSS と所要時間を初回計測で baseline 化、`peak_rss_kb` を summary に記録)
- Stage 3 着手前に Step 2.1.0 環境 spot check 必須: `mount | grep -iE "nfs|cifs|sshfs" | grep -i target` (空) + `ls -la <repo>/target | head -3` (ローカル所有)
- **Section B finding 監視**: 6 consumer のいずれかが TextAreaWidget public API を使い始めたら verify 設計前提が静かに壊れる。Stage 3 着手前 + 完了報告時に再 grep で `TextAreaWidget` caller 確認 (notepad 以外の出現があれば protocol 再設計 trigger)
- **boss1 追跡タスク (2026-05-07 v1.3 で確定)**: (1) Section B finding 再 grep を Stage 3 着手前 + 完了報告時に実施 (2) worker3 から「Stage 3 完了候補 commit です」または「API surface 変更 commit です」報告受領時、boss1 → PRESIDENT に段階 b retained check 明示依頼 (想定 1-2 回)

**重要 commit / docs:**
- baseline = `67a4273` (Stage 1 完了点)、harness = `b489f8a` (-j1 強制 + ABORT detection)、verify protocol v1.1 = `f13981c`、grep inventory = `ba7f484`
- `workspace/worker3-notes/text_core_stage3_verify_protocol.md` (二段構成 + Resolved Decisions 6 件)
- `workspace/worker3-notes/president_resolved_decisions_2026-05-03.md` (PRESIDENT 確定事項 14 件 + Stage 4 入口 4 件 + 運用ルール 5 件 + self-policing matrix 2 axis)
- `docs/text_core_test_plan.md` (5 axis matrix + Decision 1 trailing-newline)
- `scripts/run_consumer_regression.sh` + `scripts/README.md` (classify_log 4 分類 + ABORT 判定根拠)

**branch 状態:** `feature/text-core-foundation` / `stage4-round/spec-v1.0` / `track2/stage5-audit` 全て **2026-05-07 merge 後削除済**。main HEAD = `52f8037` (Stage 1 baseline → Stage 4 spec v1.0 finalize + worker2 audit doc まで全反映、+1 commit linear from PR #76 6f5b17e)。merge 戦略 = `gh pr merge --rebase --delete-branch` (track-ime PR #72 / track-golden PR #73 / Stage 3 PR #74 / track-pp1a PR #75 / spec v1.0 PR #76 / audit PR #77 全部同 strategy)、bisect 容易性のため commits chain を main 上に保持。

**Stage 5 直前 reactivation trigger (codex 監査 2026-05-07 由来、PRESIDENT 確定):**
- **A1**: Stage 3 後追い verify - cargo check --all-targets で doctest/examples/bench 含む public surface 破壊有無確認 + TextAreaWidget public method 群 (text/cursor/selection/insert/backspace/delete_forward/move_cursor/undo/redo/preedit) の最小 compile-only integration test 1 本
- **F1**: publishing-debt 次優先順位 (rescore 84 域到達のための): 1.pp1a/pp1b 完遂 → 2. **a11y action loop closes + widget→a11y 自動接続経路 (84 域到達の鍵、最重)** → 3. Touch/FileDrop consumer (half-pipeline 解消、ROI 高) → 4. multi_window 実 wayland 統合
- **H1**: notepad を compatibility harness に育てる (pre-1.0 credibility 強化、TextAreaWidget public API drift 検知の external-ish fixture consumer)

これら Stage 5 plan v1.0 rewrite 着手前 (Stage 4 完了報告で boss1 → PRESIDENT 上申後 trigger) に reactivation dispatch、Stage 4 round + Stage 5 plan rewrite 進行中の負担増回避方針。
