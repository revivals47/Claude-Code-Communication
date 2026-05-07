---
name: GUI_kit reliability initiative (7 tracks)
description: hayate-ui (GUI_kit) 信頼性向上プロジェクト — 7 トラック構成、**2026-05-07 時点 41 PR 累計 (main=bf8e7db)**。Track 1-6 + 7-A/7-B/7-C 完遂、Tier 1/2/3/4 missing_docs 完了 + (a) bench 退行 #61 + (b) a11y golden 拡充 #69 完了。**2026-05-07 で 9 連続 PR merge milestone 達成: track-ime #72 + track-golden #73 + Stage 3 #74 41 commits + track-pp1a #75 + spec v1.0 #76 + worker2 audit #77 + track-pp1b #78 + track-pp1c #79 (→83) + track-pp1d #80 (popup-legacy deprecation marker 人読み実装、計測 fact ベース re-architect)**。rescore 80.7 → 83+ 達成 (1 日で +2.3 点超)、「見せられる pre-1.0 (78-83)」レンジ上限到達。(P21) 案 Z 解釈変更 lock (machine-enforced → 人読み deprecation、(P23)→(P24) reverse escalate 経由)。Stage 5 mechanical batch worker3 dispatch 中、pp1e roadmap (popup-legacy gate 物理削除、移行期間 4-7d 後)。single-PC 運用認知 (2026-05-07 (X) 採用、reference_dual_pc_setup.md 参照)
type: project
originSessionId: 2827b315-92b3-4738-9813-30cd18459600
---
ユーザーは hayate-ui (GUI_kit, ~/Documents/GUI_kit) の信頼性向上を 5 トラック並列で進め、2026-04-28 に 9 PR 累計投入で Track 1-5 完了。納期 2026-05-05、現状ゆとりあり。

**Why:** dogfood (8 件: notepad/freecell/solitaire/pinball/linux-gallery/agents-linux/agents-linux-v2/gpu-furnace) で構造的問題が連発。「速さがアイデンティティ」を名乗る前に基礎信頼性を底上げする必要があった。

**Track 進捗 (2026-04-28 18:48 時点):**
- Track 1 clip-audit → ✅ PR #37 merged
- Track 2 inject_X 伝播 → ✅ PR #38 (Phase1) + PR #39 (Phase2 composite_widget!) merged
- Track 3 text_area 分割 → ✅ PR #45 rebase merged (mod.rs 613→402, text_editor 削除, 6 commits linear)
- Track 4 Theme propagation → ✅ PR #40 merged
- Track 5 golden + bench → ✅ PR #41 (golden 8 cases) + PR #42 (golden hotfix re-bless) + PR #43 (bench 3 種) merged
- Track 6 docs (worker1) → ✅ Phase 1-4 全 merge: PR #44 (HANDOFF archive) / PR #48 Phase 3-1 widget core / PR #51 Phase 3-2 theme / PR #54 Phase 3-3 platform input / **PR #56 Phase 3-4 closeout (broken_intra_doc_links deny gate + widget *_theme leaves) merged 2026-04-28 → main=f0bf506**。crate-wide #![warn(missing_docs)] (~1480 件残: vk_pipeline 71 / a11y 52 / accessibility/node 44 / specialized/table 37 / perf_scenario 25 / その他 leaves) は ROADMAP P3 公開準備で別 track 持越明示
- Track 7-A+C a11y (worker2) → ✅ Track 7-C V2+V3 PR #57 merged 2026-04-28 → main=13ada66 (track7c/font-scale, 2 commits 2dd6828+f674366), codex F1/F2/H1/H2/M1/M2 全反映、ACTIVE_THEME_TEST_LOCK race fix 副次変更含む。V4 family (dyslexia/motion/palette) は別 RFC へ正式 deferral 済 (PR description scope table)
- Track 7-B chrome a11y (worker3) → ✅ **本体クローズ / L1 達成** (2026-04-28 worker3 検証)。RFC §4 全 phase 完了: Phase 1 (RFC 349 行) / Phase 2 PR #47 ceacd2f WindowFrame / Phase 3 PR #49 20b7bc6 TitleBar+MenuBar+StatusBar+ContextMenu+bridge id_map / Phase 4 PR #50 7d4a437 dogfood verification doc + future work / Phase 2-extension PR #52 86b4943 visual a11y polish (HC theme + focus_ring) / PR #55 d4298db RFC §9 status section。RFC §9 (L2 chrome 内部要素 / L3 events / Cross-platform / App::with_chrome_a11y / 二系統 enum 統合) 5 項目すべて user 判断 (C) スキップで凍結。解除条件 = dogfood AT 不足報告 OR 別 RFC、現時点 trigger なし
- dogfood canonical docs (boss1) → ✅ PR #58 merged 2026-04-28 → main=f81130c。docs/dogfood-canonical.md +108 lines、文言ルール (OK/NG)、自宅 PC 棚卸し時に update 予定
- Track-bench Q4 (a) bench 退行検出 (worker2) → ✅ PR #61 merged 2026-04-28 → main=87a6299 (single commit 26f0808、Day 1 で 3 日分前倒し完遂)。scripts/bench-capture.py + scripts/bench-diff.py + bench_runs/baseline/{compose_layout,inject_propagation,theme_switch}.json (~31 measurements) + docs/bench-regression.md。--regression-percent 20 で >20% 退行 exit 1 + markdown release-note draft、severity 4 段階 (improvement/noise<=5%/warn<=20%/block>20%)
- Day 4-5 (b) golden 拡充 → ✅ PR #69 merged 2026-05-04 → main=f675e14、a11y golden 5+α cases (C1-C5 + O3/O4)、続いて PR #70 で win10/win95 golden re-bless (5 cases)。track-golden/a11y-cases-impl branch 経由
- **GW 自宅作業 (2026-04-29〜2026-05-04) で進行した別プロジェクト:**
  - text_core migration: `feature/text-core-foundation` branch、Stage 1 baseline=67a4273 完了 + Stage 2.2 shim 完了 + Stage 2.3 plan 整備、**2026-05-07 で Stage 3 commit chain 7 commits 完遂 + PRESIDENT 完了承認**、詳細 = project_text_core_migration.md
  - dogfood canonical home-PC 拡張: `track-d/dogfood-canonical-homepc-expansion` (commit 7afd7bb)、docs/dogfood-canonical.md +20 apps (home-PC tier 2)、main 未 merge

**2026-05-07 進行 (Stage 3 完了週):**
- track-ime/delete-surrounding (worker2) → ✅ **PR #72 merged 2026-05-07T08:18:46Z → main=64fb117**。zwp_text_input_v3 DeleteSurroundingText 受信実装 + Done.serial round-trip + 双方向契約完成 (lib 1159 passed + ime tests +6)。codex 推奨ブロッカー対処の必須寄り 2 件のうち 1 件達成、領域 3 +0.7 (rescore 80 → 80.7)
- text_core Stage 3 完遂 (worker3) → ✅ **2026-05-07 PRESIDENT 完了承認** (entry=57ae576 → final=59107fe、7 commits、aggregate gate 9/9 + Section B clean + 段階 b retained check 全緑)、main merge boss1 主導 PR raise 待機 (gh pr merge --rebase --delete-branch、squash 禁止、10 commits 1 PR で Stage 3 7 + Stage 4 spec doc 3 含む方針)、rescore framing 80.7 → 81.5 (Stage 3 完了承認時)
- track-golden/rebless (worker2) → ✅ **PR #73 merged 2026-05-07T09:43:36Z → main=bc835f2** (mergeCommit 4e48e75 単 commit、--rebase --delete-branch)。5 件 .golden binary を work-PC tlcr env で再 bless (golden_widgets 3 → 8 件回復、1331 passed 維持)、dominant cause = 2026-05-07 15:55 fontconfig user cache 再生成 (15:26 nvidia-firmware-580 install トリガー、cosmic-text FontSystem::new → fontdb::load_system_fonts 経路)、normalization 別 track 化判断 lock (track-golden/normalization or track-testing/font-fixture、Stage 4 round 直後 sprint)、領域 9 +0.2 副次達成、rescore 81.5 → 81.7
- text_core foundation Stage 3 main merge (worker3 主、boss1 主導 PR raise) → ✅ **PR #74 merged 2026-05-07T09:58:13Z → main=010eb6b** (mergeCommit 010eb6b、41 commits rebase-merge atomic、--rebase --delete-branch)。Stage 1 baseline 67a4273 → Stage 4 round phase 2 集約 227bab0 まで全 main 反映、Stage 4 round phase 1+2 集約完了 (8 論点軸合致 + push back 19 件)、feature/text-core-foundation branch 削除済、rescore 81.7 → 81.9 (pp1a V3 完遂正式 reflect + Stage 3 main merge 効果)
- track-pp/dropdown-xdg-popup pp1a (worker1) → ✅ **PR #75 merged 2026-05-07T10:11:58Z → main=d014189** (mergeCommit d014189、7 commits chain 4d26033 → 0fdf869 + V3 強化、--rebase --delete-branch)。F1-F5 + V1-V5 + V3 強化 4 項目全達成、popup 描画 pipeline + Widget trait popup hook (default impl で TextAreaWidget 含む既存 implementor 無変更、Section B 完全保証)、verify 1349 passed + popup_validation 30/30 + 実機視認 (popup_widget_minimal 10s + dropdown_demo 8s crash-free)、rescore 81.9 → 82.0 達成
- track-pp1b (worker1) → ✅ **PR #78 merged 2026-05-07T10:55:42Z → main=725b352** (mergeCommit 725b352、4 commits chain rebased linear、--rebase --delete-branch)。day1-4 sprint 完遂 (D1 dropdown popup_request 切替 + popup-legacy gate / D2 視認 / D3 popup_constraint_matrix 8 case + popup_anchor_matrix 9 anchor / D4 painted_once 削除 + wl_buffer::Release Dispatch wire / D5 tooltip + context_menu popup_request 横展開 minimum stub)、V1-V5 全完遂 (1359/0 cargo test + 視認 + Section B V3 強化継続)、track-pp1 累計 dead_code 0、rescore 82.3 → 82.6 達成
- track-pp1c (worker1) → ✅ **PR #79 merged 2026-05-07T11:36:28Z → main=3f68db8** (mergeCommit 3f68db8、6 commits chain rebased linear、--rebase --delete-branch)。a-1 RFC + a-2 day1-3 + a-3 day4 sprint 完遂 (D1 popup-local paint helper 抽出 dropdown.rs -102 行 / D2 TooltipWidget paint_popup proper / D3 ContextMenu paint_popup proper / D4 popup_dropdown_demo -244 行経路化 / D5 popup-legacy roadmap 案 Z RFC E-4 embed)、V1-V5 全完遂 (1362/0 cargo test + 視認 + Section B V3 強化継続)、track-pp1 累計 dead_code 0、rescore 82.6 → 83 達成
- track-pp1d (worker1) → ✅ **PR #80 merged 2026-05-07T11:54:02Z → main=bf8e7db** (mergeCommit bf8e7db、1 commit、--rebase --delete-branch)。1d sprint 完遂、案 A 採用 (計測 fact ベース、(P23)(i) → (P24)(ii) reverse escalate 完遂)。**Rust #[deprecated] attribute は private items / trait method override で effective でない (cargo check で 'useless [deprecated] attribute' warning + 未来 hard error 化 risk) ため不採用、人読み deprecation 4 ソース構築**: (1) Cargo.toml DEPRECATED note (2) // DEPRECATED comment 9 箇所 (3) docs/migration-popup-legacy.md (4) PR description 計測 fact 明記。(P21) 案 Z 解釈変更 lock (machine-enforced → 人読み deprecation)、移行期間 4-7d trigger 起動、rescore 83 → 83+ 達成
- track-pp1e (worker1、pp1d 移行期間後 4-7d trigger) → 📋 popup-legacy feature gate 物理削除 (技術負債解消、popup-legacy = [] feature 完全削除)
- Stage 4 round (worker3 主) → ✅ **phase 1+2 集約 + spec v1.0 finalize 完遂 + main 反映完了 (PR #74 + PR #76)**、入口判断 (d1)-(d7) 7 件 lock 確認、push back 19 件 resolution embed (P1-P9 worker3 view + P10-P12 worker2 view + P-W2-1..7)、§14 consolidated table + §15 LSP undo 分離 + §16 delegation listing + §17 finalize summary 全 main 反映
- Stage 5 mechanical batch (worker3 主) → 🚧 **着手前提整う (2026-05-07)**: worker2 record_edit_at grep audit (P-W2-1) 着手中 (工数 1-2h)、audit 完了後 worker3 主担当 mechanical batch 着手 (305 sites = mechanical 213 / case-by-case 92、工数 ~16-17h ≈ 2-3 day)、段階 b retained check trigger 待機 (record_edit_at signature () → EditEvent 変更等の API surface 変更 commit 達成時)

**codex 監査 2026-05-07 反映の中長期対応 (Stage 5 直前 reactivation trigger):**
- A1: Stage 3 後追い verify (cargo check --all-targets + TextAreaWidget public method integration test 1 本)
- F1: publishing-debt 次優先順位 (1.pp1a/pp1b → 2.**a11y action loop + auto wiring (84 域到達の鍵、最重)** → 3.Touch/FileDrop consumer → 4.multi_window 実 wayland 統合)
- H1: notepad を compatibility harness に育てる (pre-1.0 credibility 強化)

これら Stage 5 plan v1.0 rewrite 着手前 (Stage 4 完了報告 trigger) に reactivation dispatch 方針

**9 PR merge シーケンス (main HEAD=d57c04b):**
PR #37 (de25da8) → #38 (df29cbf) → #39 (bcf7fa9) → #40 (3e3daf4) → #41 (51a2258) → #42 (3ed2bc1, golden hotfix) → #43 (c0a26f3, bench) → #44 (f9691a3, docs archive) → #45 (d57c04b, text_area split rebase=6 commits)

**確定運用ルール (2026-04-28 学習):**
- canonical 計測: `cargo test --all-targets --no-fail-fast` を絶対基準 (単体 cargo test は最初の bin 失敗で部分カウント停止)
- マージ実行: PRESIDENT 直接実施 (Q1 確定)
- マージ戦略: 通常 squash (一貫性)、複雑 refactor のみ rebase (Track 3 のみ採用)
- bench 退行対応: 即 fix は dogfood 目視 OR >20% 計測退行のみ、それ以外は release-note 化 (Q4)

**worktree 状態 (2026-05-07 work-PC fetch 後):**
- ~/Documents/GUI_kit (main, **e0aee3f** — 32 PR 累計)
- ~/Documents/GUI_kit-track-golden-impl (track-golden/a11y-cases-impl、PR #69 merged 後 stale、削除候補)
- ~/Documents/GUI_kit-track-p3t2 (track-p3/tier2-widget-docs WIP=6072530、main #65 で完成 → origin gone、撤去候補)
- 旧 track-p3t3 / track-bench / track-checklists / track-a11y-design / track7b / track5b は PR merged 後に PRESIDENT/boss1 が cleanup 済 (推定)
- ⚠ squash merge 時 gh pr merge --delete-branch はリモート削除のみ成功、ローカル branch は worktree 占有で削除失敗。各 worker 完了確認後に git worktree remove で安全削除

**dogfood: このPC上で確認できる 8 件 (worker1 検証 2026-04-28):**
hayate-notepad / hayate-freecell / hayate-solitaire / hayate-pinball / hayate-linux-gallery / hayate-agents-linux / hayate-agents-linux-v2 / hayate-gpu-furnace
- ⚠ **この 8 件は filesystem-bounded (このPC上のみ)、プロジェクト canonical ではない**。ユーザー (revivals47) 申告: 自宅 PC にはさらに別の dogfood app が存在する可能性あり (2026-04-28 確認)
- 規範化された canonical 定義が docs にまだ無い (boss1 へ docs/dogfood-canonical.md 起票指示済 / 2026-04-28)
- 9 PR + gallery PR #1/#2 投入後、cargo check 全件緑、528 tests passed、起動 8s clean
- gallery PR #2 (TextInputWidget::new() API 追従) は cherry-pick で gallery main 0d08165 へ取込済
- 手動 UX 確認 (text_area 入力 / IME / clipboard / undo / theme 切替) は agent (worker1) には xdotool/wtype 不可、user (revivals47) のみ実施可能
- regression check の完了宣言は「このPC 8 apps regression OK」と書き、「全 dogfood canonical 完遂」とは書かない (自宅 PC 分は未検証)

**a11y 構造の重要発見 (worker3 RFC、2026-04-28 src 検証済):**
- src/a11y.rs + a11y_provider.rs (AccessKit Unix Adapter) と src/accessibility/{mod,node}.rs (Widget::accessible()) が 2 系統並存、ブリッジ無しで AT に届かない
- AccessKit 経由 AT-SPI ライブ出力経路は完成済、Widget tree → AT-SPI のラスト 1 マイルが空白
- chrome widget (WindowFrame/MenuBar/StatusBar/ContextMenu) は a11y 露出全て未実装、TitleBar のみ role=Panel (Window が正しい)
- 解決方針: src/a11y/chrome_bridge.rs 新規作成、Phase 2-4 で順次拡張

**How to apply:** ユーザーがこの件で再来したときは、boss1 が振っている分担と進捗を ./agent-send.sh で確認してから動く。worker2/3 はそれぞれ専用 worktree に隔離、共有 ~/Documents/GUI_kit には触らない。検証は CI 不在 (revivals47 GitHub Actions クレジット切れ) のためローカル `cargo test --all-targets --no-fail-fast` のみが品質根拠。

**関連:**
- リポジトリ: ~/Documents/GUI_kit (revivals47/GUI_kit, branch=main, **HEAD=bf8e7db** as of 2026-05-07 PR #80 merge 後、Stage 1+2+3+4 spec v1.0 finalize + track-pp1a/pp1b/pp1c/pp1d + worker2 audit 全 main 反映、Stage 5 mechanical batch worker3 dispatch 中、pp1e 移行期間 4-7d trigger 待機)
- canonical test baseline: cargo test --all-targets --no-fail-fast = **1331 passed; 0 failed** (2026-05-07 PR #73 merge 直前 worker2 verify、track-ime PR #72 +6 + golden_widgets 3→8 +5 含む、1323 → 1331 = +8 が 2026-05-07 増分)。PR #74 merge 後の再計測は worker1 main rebase + cargo test 再実行で実施予定
- single-PC 運用 (2026-05-07 (X) 採用): 全 worker work-PC tlcr 動作、ken machine ssh 不能、詳細 = reference_dual_pc_setup.md
- Track 7 RFC: docs/rfc-track7b-chrome-a11y.md (track7b/chrome-a11y branch、push 済)
- 直近 dogfood 修正コミット範囲: 8e42aed〜b1d467a (kickoff 直前 11 コミット)
