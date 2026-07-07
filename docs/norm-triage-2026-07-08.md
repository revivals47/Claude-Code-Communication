# 規範棚卸し 2026-07-08

目的: 4ヶ月分の規範(memory 164件 + instructions/)を「まだ生きたトリガーがあるか」で格付けし、
Opus 移行後の規範密度を最適化する。**削除はしない — archive 移動 + index 剪定のみ**(来歴保全)。

格付け分類:
- **1=恒久原則** — 姿勢レベル、陳腐化しない → keep
- **2=現役の具体規範/知見** — 参照先が実在 → keep
- **3=superseded/完了残骸** — 状態記録として役目終了 → `memory/archive/` へ移動 + index から除去
- **4=一過性・環境依存** — 当時のバグ/バージョン固有 → 要再検証、検証後に 2 or 3 へ

---

## A. index 整合性(検証済・機械突合)

- index に載って実体無し: **0件**(dangling なし、健全)
- 実体あるが index 不在の孤児: **14件**
  - feedback_no_publish_without_dogfood.md
  - project_guikit_phase_p_meta.md / project_hayate_ime_issue.md / project_hayate_naming_unify.md / project_hayate_txt1_bc.md
  - project_phase3b_resume_2026_05_21.md / project_phase_9_formal_exit_pending.md / project_testruct.md
  - project_track_b_complete.md / project_track_p3_status.md / project_win95_branch_merge.md / project_window_decoration_phase1_complete.md
  - reference_remaining_tasks.md / user_mac_developer.md
  - → 孤児は「毎セッション読まれていない」= 既に実質 archive 状態。格付けの上で正式に archive or index 復帰

## B. instructions/ 監査(Fable 本体による精読)

### president.md — 大幅剪定候補
- 大半が上流デモリポジトリ由来のテンプレ(ECサイト検索/経費精算の例、2024年日付、実在しない check-progress.sh cron)
- ユーザー固有の規範はほぼ含まれていない
- **推奨**: 役割定義 + クイック分析(5W) + boss1 指示テンプレ骨子のみ残し、実例2件と
  トラブルシューティング定型文は削除 or docs/ へ退避。体感 1/4 の分量になる

### boss.md — 生きた規範とテンプレ残骸が混在
**生きている(keep、いずれも実incident由来)**:
- worktree 隔離プロトコル(2026-04-28 事故由来、リカバリ手順込み)
- PRESIDENT への中間 ack 必須規範(2026-05-13 stall 由来)
- dispatch design patterns 5件(2026-05-08、Stage4/Phase1 実証)
- 継続的タスク管理・ゼロ待機時間の原則(思想部分)

**テンプレ残骸(剪定候補)**:
- `/workspace/[プロジェクト名]` 絶対パス群 — **実在しない**(検証済)。実運用は repo 相対 `workspace/` や `~/Documents/[project]`。誤誘導リスクあり、実態に合わせて書き換え or 削除
- タスクキュー管理表の例、KPI セクション、日次スタンドアップ、while ループ疑似コード
- worker*_done.txt メカニクス — tmp/ には ack_*.txt しか無く、done.txt 方式が現役か要確認

### worker.md — 中程度剪定候補
- スキルマトリクス yaml(フロントエンド/バックエンド/DevOps)はデモ内容
- 生きているのは: 実行フロー、進捗/ブロッカー/完了報告フォーマット
- `/workspace` 参照は boss.md と同様に stale

### CLAUDE.md — 健全
- 簡潔。行動姿勢7箇条追加済(0f0fcc5)

## B-2. skills 監査(追補) — 対応済

- skills は `~/.claude/skills/codex` の1件のみ(project 側 skills/commands なし)
- 旧内容は「Claude 自己レビューのプロンプトテンプレ」(3月22日作成)で、運用上の「codex=外部 CLI 査読」と同名別物に乖離していた
- **2026-07-08 user 判定=実運用に合わせて書き換え済**: codex exec 起動規範(`</dev/null` 必須 / pipe truncation 禁止 / 1500字・1案件1exec / leaf 側 cwd / stall 判定15分)+ verdict 直読・裏取り後 relay の規範を反映

## C. memory 格付け(fork agent 5体による全件精読)

<!-- fork 結果をここに反映 -->

### C-1. feedback 前半(32件) — 完了

| file | 分類 | action | 理由 |
|---|---|---|---|
| feedback_500_line_guideline | 1 | merge→code_principles | 500行原則の運用注釈、原則本体と一体化 |
| feedback_accuracy_priority | 2 | keep | sound-core休眠中だがrepo実在、再開時の前提 |
| feedback_agent_send_backtick | 2 | keep | agent-send.sh現役、観察5件蓄積中 |
| feedback_ai_worker_capability_boundary | 2 | keep(圧縮余地大) | AI worker GUI verify不可は恒常制約 |
| feedback_api_gate_verify_against_consumer_loop | 2 | keep | dirty-STALL class 3例、GUI_kit現役 |
| feedback_apps_on_l2 | 1 | keep | L2アーキ原則 |
| feedback_boss1_input_confirm_delay | 4 | keep-verify | モデル切替で挙動前提が変わりうる。file自身にdeprecation条項あり |
| feedback_cargo_filesystem_discovery | 2 | keep | cargo一般fact |
| feedback_cargo_j1_rule | 2 | keep(圧縮余地) | home-PC環境制約現役 |
| feedback_cargo_lock_capture | 2 | keep | WIP capture運用、普遍 |
| feedback_cargo_reads_worktree_wip | 2 | keep | 共有worktree検証の恒常制約 |
| feedback_cargo_test_full_workspace_gui_hang | 2 | keep | GUI_kit現役 |
| feedback_cargo_verify_crate_kind_preflight | 2 | keep | dispatch設計規範、普遍 |
| feedback_code_principles | 1 | keep(merge先) | 最古参の恒久原則 |
| feedback_codex_batch_stall | 4 | keep-verify | 2026-05-12当時のcodex挙動、現行版で再現するか要再検証 |
| feedback_commit_preserve_vs_push | 1 | keep | push承認統治、2026-07-07まで最新 |
| feedback_consult_codex_when_uncertain | 1 | keep | user明示規範+track record 7件 |
| feedback_coord_authority_measure_running_path | 1 | keep | 原則はdegimon remakeに継承、普遍 |
| feedback_coord_invariant_at_platform_layer | 2 | keep | GUI_kit popup coordアーキ判断、現役 |
| feedback_cumulative_by_stage_pattern | 2 | keep | phased migration一般に再利用可 |
| feedback_delegate_to_boss1 | 1 | keep | user明示の役割分担 |
| feedback_derisk_against_real_artifact_not_stub | 1 | keep | 3日前、degimon現役 |
| feedback_design_maturity | 3 | archive(merge→hayate_vs_gtk_live_compare) | 100日前の評価、user「GTKと遜色なし」判定でsuperseded |
| feedback_dispatch_premise_stale_after_bulk_merge | 1 | keep | dispatch前提検証の恒久規範 |
| feedback_dispatch_send_evidence | 2 | keep | boss1 dispatch protocol現役 |
| feedback_forward_infra_needs_real_caller | 2 | keep | caller grep audit、普遍 |
| feedback_golden_doa | 2 | keep | golden framework現役 |
| feedback_golden_env_drift | 2 | keep-verify | 12 fail inventoryはmain revision依存、次のre-blessで要更新 |
| feedback_hayate_design_identity | 1 | keep | 美学の北極星 |
| feedback_hayate_vs_gtk_live_compare | 2 | keep(merge先) | 4日前、残課題現役 |
| feedback_headphone | 2 | merge→accuracy_priority | sound-core前提2件→1file |
| feedback_helper_extract_partial_move | 2 | keep | Rust一般テクニック |

**担当forkの所見**: 真のarchive候補は design_maturity 1件のみ — feedback系は生存率が高い。ただし長大file(4-11KB)が4件あり「規範部を先頭3-5行に凝縮、事例はappendix化」の体裁統一が有効。boss1_input_confirm_delay はOpus切替後の再観察対象。参照先実在確認済(pane-watchdog.sh/sound-core/GUI_kit/codex 全て実在)。

### C-2. feedback 後半(32件) — 完了

| file | 分類 | action | 理由 |
|---|---|---|---|
| feedback_hypothesis_space_openness | 1 | keep | H4原則、2026-07-07更新の最新鋭 |
| feedback_impl_review_trace_all_paths | 1 | keep | review恒久原則 |
| feedback_inhouse_implementation_default | 2 | keep | codex=review本分は現役運用 |
| feedback_instrument_runtime_when_fixes_miss | 1 | keep | 「2回外したら計測」恒久原則 |
| feedback_iterative_refinement_pattern | 3 | merge→pre_move_grep_audit | 本質重複、8割が完了済Phase trail |
| feedback_lgtm_merge_gap_pattern | 2 | keep | future-tense禁止、弱いモデルほど再発しやすい類型 |
| feedback_live_re_atrest_not_mid_transition | 2 | keep | degimon live-RE進行中 |
| feedback_live_visual_verify_before_completion | 1 | keep | 完成凍結原則、最重要級 |
| feedback_memory_index_staleness | 2 | keep | memory運用のメタ規範 |
| feedback_merge_gate_build_examples | 2 | keep | GUI_kit merge運用現役 |
| feedback_no_publish_without_dogfood | 2 | keep(index復帰) | crates.io公開は将来事項、651B |
| feedback_no_relay_expected_as_observed | 1 | keep | 捏造2件教訓の中核、7箇条#1の詳細版 |
| feedback_no_sunk_cost_rebuild_ok | 2 | keep | degimon現役。platform_principleと弱い重複 |
| feedback_overlay_child_lifecycle_forward | 2 | keep | GUI_kit silent bug class |
| feedback_per_window_routing_tracking_vs_delivery | 2 | merge→routing_refactor_enumerate_emission_arms | tracking≠delivery同一教訓2file |
| feedback_period_theme_accuracy | 2 | merge→research_before_replicate | clone-fidelity 3部作の一 |
| feedback_platform_principle | 1 | keep(condense推奨) | 最上位4制約。5回の追記で肥大 |
| feedback_pre_move_grep_audit | 2 | keep(merge先) | file move前grep audit汎用 |
| feedback_rebaseline_derived_docs_vs_code | 1 | keep | derived doc re-baseline恒久 |
| feedback_research_before_replicate | 2 | keep(merge先) | clone案件先行調査必須、3部作の親 |
| feedback_routing_refactor_enumerate_emission_arms | 2 | keep(merge先) | grep-variation completeness含む上位互換 |
| feedback_shared_to_perinstance_handle_audit | 2 | keep | GUI_kit現役 |
| feedback_shared_wt_commit_hygiene | 3 | archive | 結論がCLAUDE.md worktree隔離プロトコルに昇格済=supersede |
| feedback_trait_api_branch_scope | 2 | keep | dogfood 18 repo運用で現役 |
| feedback_verify_before_recommending | 1 | keep(condense推奨) | 原則恒久だがchronicleが本体の7割 |
| feedback_verify_fn_scope_by_lexical_range | 2 | keep | verify家族の独立facet |
| feedback_verify_reused_mechanism_behavior | 2 | keep | 4 incident裏付き現役 |
| feedback_visual_validation_gap_pattern | 2 | keep | GUI_kit現役 |
| feedback_widget_trait_forward_gap_pattern | 2 | keep | 7 case invariantで現役 |
| feedback_win95_solitaire_fidelity | 3 | merge→research_before_replicate | 同根失敗の具体例、1行で吸収可 |
| feedback_worker_swap_protocol | 2 | keep | multiagent運用現役 |
| feedback_fable_to_opus_posture | 1 | keep(確定) | 受け皿として機能済 |

**担当forkの所見**: 統合候補=①clone-fidelity 3部作(research_before_replicate親)②tracking≠delivery 2件③iterative_refinement→pre_move_grep_audit。platform_principle と verify_before_recommending は「本体condense+詳細をarchive行き」が有効。frontmatter `name:` slug が不統一([[link]]解決の観点で正規化価値あり)。shared_wt_commit_hygiene の archive 時は CLAUDE.md 昇格済の旨を明記。

### C-3. project 前半(35件) — 完了

| file | 分類 | action | 理由 |
|---|---|---|---|
| project_button_design_language | 1 | keep | user美的判断待ちhold中の現役task |
| project_chrome_controls_visibility | 1 | keep | PR #285 open+re-bless gate残 |
| project_chrome_sibling_layout | 2 | keep(reference型へ変更候補) | 実装アーキ事実、陳腐化しにくい |
| project_chrome_window_controls_redesign | 3 | merge→chrome_controls_visibility | 同一taskの旧版、新版がsuperset |
| project_degimon_care_two_tier | 2 | keep | care機構のRE正典+honest gap 4件 |
| project_degimon_care_verify | 2 | keep | 検証手法handbook、再利用価値高 |
| project_degimon_menu_status_ui | 1 | keep | follow-up現役、RE事実6点は再発見コスト高 |
| project_degimon_resume_2026_07_04 | 3 | merge→degimon_world_remake | snapshot役目終了。private remote+push規範のみ移送 |
| project_degimon_scenario_progression | 1 | keep(圧縮余地大) | 最活性、次回冒頭checklist筆頭 |
| project_degimon_world_remake | 1 | keep(圧縮候補筆頭) | 現役initiative親。52k tokens超、Phase1経緯が大半 |
| project_digimon_remake_gamma | 4 | merge→degimon_scenario_progression | γ-1bはP3-B実装済の公算、要1点確認 |
| project_dnd_phase_b_status | 2 | keep | 知見部(wrapper forward必須)現役 |
| project_dogfood_homepc_inventory | 3 | archive | 65日前snapshot、all-green達成済 |
| project_dtp_app_roadmap | 2 | keep | north star、優先順位判断の現役根拠 |
| project_gpu_integration | 3 | archive | 100日前、後続で完全supersede |
| project_guikit_multiworker | 3 | archive | CLAUDE.md worktree隔離+他memoryで既カバー |
| project_guikit_phase_p_meta | 3 | archive | 孤児。Phase P close済、教訓は他が既カバー |
| project_guikit_track1_branches_landed | 4 | keep-verify | 生残branch 3件の掃除完了後にarchive |
| project_hayate_amp_slider_fix | 2 | keep | supersede警告に固有価値(再着手防止) |
| project_hayate_apps | 3 | archive | 101日前計画、実態乖離。要件は各app memoryに既存 |
| project_hayate_default_design_unset | 2 | keep | 未決の美学決定、現役 |
| project_hayate_font_philosophy | 2 | keep | 恒久哲学、軽量pointer |
| project_hayate_gpu_furnace | 2 | keep | bench harness、perf判断の現役ground |
| project_hayate_ime_issue | 3 | archive | 孤児。resolved+closed。debt 4件のみ拾い出し |
| project_hayate_kit_agents_v3 | 1 | keep(大幅圧縮候補) | parked、詳細はrepo handoff docにあり |
| project_hayate_kit_notepad | 2 | keep | M3 DTP布石の受け皿 |
| project_hayate_mac_layout | 3 | archive | 参照目的はagents_v3 #3 landで達成済 |
| project_hayate_modern_ui | 2 | keep | vision memory、恒久根拠 |
| project_hayate_motivation | 2 | keep | プロジェクトのwhy、恒久 |
| project_hayate_naming_unify | 2 | **keep+index復帰** | 孤児だが未決residualが生きている |
| project_hayate_roadmap | 3 | archive | 2026-04-05策定、supersede済 |
| project_hayate_theme_extensibility | 2 | keep | 未着手architectural debt |
| project_hayate_txt1_bc | 3 | archive | 孤児。凍結済+対象はlegacy系統 |
| project_hayate_ui_vulkan_crash | 4 | keep-verify | 未再現watch中。#186 fallback landで「解消扱いarchive」も検討可 |
| project_hayate_video_playback | 2 | keep | 残=Phase2 backlog。**index行がstale**(本体はuser live PASS済)、index更新要 |

**担当forkの所見**: 孤児4件中 naming_unify のみ index 復帰、他3件は archive。大型ファイル群(world_remake 52k tokens等)は完了済み中間経緯が大半 — 「現状+hard-won factsのみ」への圧縮が context 削減の最大レバー。degimon/digimon slug 表記揺れあり。video_playback の index 行乖離は index staleness の実例。

### C-4. project 後半(35件) — 完了

| file | 分類 | action | 理由 |
|---|---|---|---|
| project_hayate_vulkan_dmabuf | 3 | archive | ブロッカー解決済+後続で前提進展 |
| project_hayate_xp_fidelity_limits | 3 | archive | 5プリミティブ中4件がPR#181で実装済=superseded |
| project_imageview_l2_rebuild | 3 | archive | MERGED #187、教訓はfeedback群へ抽出済 |
| project_language_profile | 2 | keep | 進行非依存の設計方針、小さく腐らない |
| project_layer_separation_initiative | 3 | archive | L1完遂+L0 spec正本はrepo docs/ |
| project_multiwindow_l1 | 3 | archive(残1行保持) | 全MERGED、残=AC11 AT-SPIのみslim noteに |
| project_multiwindow_popup_open | 3 | archive | 解消済。per-instance FontSystem罠はreference化salvage |
| project_notepad_l2_phase2_resume | 3 | merge→notepad統合1本 | LAND COMPLETE、rebuild側と大幅重複 |
| project_notepad_l2_rebuild | 3 | merge(同上) | 残follow-upだけのslim記録に |
| project_pdfview_l2 | 1 | keep(要圧縮) | Phase4②③④未着手=現役roadmap。session journal化+index hook stale |
| project_pdfview_tools_roadmap | 1 | keep | 次=Merge、roadmap現役 |
| project_phase3b_resume_2026_05_21 | 3 | archive | 孤児。resume point消化済 |
| project_phase3b_theme_fidelity | 2 | keep(merge先) | theme再開時の正本 |
| project_phase3b_xp_bigsur_fidelity | 3 | merge→theme_fidelity | 参照サイト一覧+gotchaのみ移植 |
| project_phase_12_popup_status | 3 | archive | 後続が上書き済 |
| project_phase_9_formal_exit_pending | 3 | archive | 孤児。本文でABANDONED宣言済 |
| project_picker_browser | 3 | archive+**index訂正** | MERGED #187済なのにindex「user判断待ち」=stale |
| project_prosody_analysis | 4 | keep-verify | **index「実装済」vs本体「構想」が矛盾**、真偽確認要 |
| project_r2_4_modal_focus_trap | 1 | keep | bug1(~70 LOC)が生き残課題 |
| project_sound_core | 2 | keep | 休眠projectの再開基盤 |
| project_testruct | 3 | archive | 孤児。核心はgoal/public_releaseに継承済 |
| project_testruct_fidelity_sweep | 3 | archive | 全項目MERGED |
| project_testruct_goal | 3 | merge→testruct_public_release | 動機+repo pointerを吸収 |
| project_testruct_mac_convergence | 1 | keep | 現役、残タスク明確 |
| project_testruct_public_release | 1 | keep | 現役最重要initiative |
| project_text_area_select_paste_crash | 3 | archive | 解消済+回帰ガードgreen |
| project_text_area_vector_wrap_perf | 1 | keep | 残follow-up現役 |
| project_text_core_migration | 4 | keep-verify(要圧縮) | Stage5/6の生死未確認(work-PC依存) |
| project_track_b_complete | 3 | archive | 孤児。本文自ら closeout宣言 |
| project_track_p3_status | 3 | archive | 孤児。以後の変遷でstale |
| project_vertical_dtp_roadmap | 3 | archive | 全land+#283 merged、継続はdtp_app_roadmapが担う |
| project_vise_canonical_transform | 3 | archive | superseded明示済 |
| project_vulkan_cpu_fallback_design | 3 | archive | #186完成merged |
| project_win95_branch_merge | 3 | archive | 孤児。historical record |
| project_window_decoration_phase1_complete | 3 | archive | 正本はreference_decorations_default_borderless |

**担当forkの所見**: index不在の孤児は全てarchive判定 — 「indexから落ちた時点で実質死んでいる」= 孤児検出は棚卸しの良いシグナル。index hook の stale/矛盾を2件発見(picker_browser、prosody_analysis)。「session journal化した巨大memory」は現状+残タスクのみへ圧縮が有効(trailはrepo側handoff/PRに残存)。

---

## 総括(Fable 統合)

**格付け集計(164件)**:
- keep(分類1/2): **約104件** — feedback系の生存率が突出して高い(64件中61件現役)
- archive/merge で active set から外れる: **約51件(-31%)** — うち project系が40件と大半。「規範」はほぼ全部生きていて、削れるのは「状態記録」
- keep-verify(要再検証): **9件** — boss1_input_confirm_delay(Opus切替で挙動前提変化)、codex_batch_stall、codex_exec_stdin(現行codexで再現するか)、golden_env_drift、guikit_track1、vulkan_crash、prosody_analysis(index矛盾)、text_core_migration(work-PC依存)、digimon_remake_gamma(P3-B supersede 1点確認)

**構造的発見**:
1. **feedback(規範)とproject(状態)は寿命が違う** — feedbackは95%生存、projectは45%が残骸。今後は「project系は完了時にarchiveへ」を運用に組み込むと棚卸し不要になる
2. **index孤児=死亡シグナル** — 孤児14件中11件がarchive妥当、復帰が正なのは3件のみ(user_mac_developer / naming_unify / no_publish_without_dogfood)
3. **index hook のstale 4件** — picker_browser(MERGED済なのに判断待ち表記)、video_playback、pdfview_l2、prosody_analysis(index⇔本体矛盾)。feedback_memory_index_staleness の規範が正しかった実証
4. **本文内のstale state claim 2件** — reference_guikit_sdf_large_text_blur / reference_hayate_headless_screenshot(「未merge」記述だが main 入り確認済)
5. **肥大file問題** — 規範として現役でも4-11KB(world_remakeは52k tokens)。「規範部を先頭3-5行、事例はappendix」体裁と、journal型projectの「現状+hard-won factsのみ」圧縮が context 削減の最大レバー
6. **統合候補 約10組** — clone-fidelity 3部作、notepad 2件、testruct 5→2件、phase3b 3→1件、degimon resume吸収、xpcss 2→1件など

## D. 実行結果(2026-07-08 同日実行済)

user 判定「推奨順で進めて」を受け、archive 移動・統合15組・index 修繕・instructions 剪定・圧縮上位4件を同日実行完了。

**数値**:
- active memory: 164 → **119 file**(-27%)、容量 1.3MB → **772KB**(-41%)
- archive: 51 file(退役46 + 圧縮原本4 + ARCHIVE_NOTES.md)。削除ゼロ、全て原文残存
- index: 119行 = active 119 file、dangling 0・孤児 0(機械突合 GREEN)
- 統合: 15組実施(全て要点移植後に退役、fork 3体で分担)
- 圧縮: world_remake 115KB→13.3KB(11.6%) / scenario_progression 50.6KB→19.2KB(38%) / pdfview_l2 24.4KB→5.9KB(24%) / kit_agents_v3 27.2KB→4.1KB(15%)。いずれも検証済 RE facts・残タスクは全保持、原本 archive 保全
- stale 訂正: 本文2件(SDF blur / headless screenshot、grep 実地確認つき)+ index hook 5件(video_playback / pdfview_l2 / prosody 矛盾フラグ / kit_agents handoff 後続明記 / **scenario_progression の push HELD 表記** — 圧縮 fork が本体との矛盾を摘発、track3/faithful-178 は PUSHED origin 済が正)
- instructions 剪定: commit 28afbfe(-786行/+59行)
- skills: /codex を外部 CLI 査読手順に書き換え(user 判定=Option 1)
- 衛生: repo 直下の空ファイル `section`(redirect 事故)削除、settings.local.json の死に許可2件除去

**Opus 移行後への申し送り(未実施分)**:
1. 要再検証9件(index に「要再検証/要確認」フラグ付与済): codex batch stall / codex exec stdin / boss1 input 遅延(モデル切替で挙動前提変化) / prosody index⇔本体矛盾 / text_core Stage5/6(work-PC) / golden env drift inventory / guikit_track1 生残branch / vulkan_crash 解消扱い判断 / γ-1b=P3-B supersede 確認
2. Cargo.toml(hayate-kit-testruct)に `feedback_new_apps_depend_on_gui_kit_only` という存在しない memory 名がコメント引用されている — 規範がコード側にのみ生存、memory 起こしを検討
3. frontmatter `name:` slug の命名不統一(日本語/kebab/snake 混在)— [[link]] 解決の信頼性向上のため正規化余地
4. 残り肥大 file の圧縮第2弾(care_two_tier / menu_status_ui 等、今回は上位4件のみ)
5. 「project 完了時に archive へ」を運用に組み込む(次回の棚卸しを不要にする)

### C-5. reference + user(30件) — 完了

| file | 分類 | action | 理由 |
|---|---|---|---|
| reference_bitmap_font_fractional_scroll_y | 1 | keep | scroll系widget全般に再利用可の恒久gotcha |
| reference_button_widget_bare_return_no_focus_gate | 2 | keep | L2 root fix未着手、composite author規範 |
| reference_clipboard_self_paste_deadlock | 3 | merge→wayland_self_source_pipe_deadlock | fix MERGED #191+一般化版が包含済 |
| reference_codex_exec_background_stdin | 4 | keep-verify | 当時のcodexバージョン挙動依存、現行版で再検証 |
| reference_cosmic_wrap_and_bidi_gotchas | 1 | keep | cosmic-text恒久gotcha |
| reference_cpu_golden_cannot_verify_vulkan | 1 | keep | 構造的制約 |
| reference_decorations_default_borderless | 2 | keep | L2 app新規作成のたび踏む罠(実害2例) |
| reference_demucs | 2 | keep | パス実在確認済、コスト極小 |
| reference_deref_scaffolding_split_borrow | 1 | keep | Rust言語制約の恒久知見 |
| reference_duckstation_live_ram_capture | 2 | keep | degimon主力手法、2日前更新 |
| reference_font_constant_cap_centering | 1 | keep | 単行label widget全般、CJK follow-up残 |
| reference_food_item_id_vs_shop_id | 2 | keep | degimon現役 |
| reference_guikit_font_resolution | 2 | keep | 6日前更新の現役 |
| reference_guikit_gamma_pipeline | 2 | keep | follow-up残の現役 |
| reference_guikit_key_broadcast_focus_gate | 1 | keep | L1 Key配送モデルの恒久知見 |
| reference_guikit_sdf_large_text_blur | 2 | keep-verify | **本文の「残landing」記述がstale**(main入り実地確認済)、本文更新要 |
| reference_hayate_headless_screenshot | 2 | keep-verify | **「未merge」記述がstale**(screenshot.rs main実在確認済)、本文更新要 |
| reference_hayate_perf_debug_vs_loop | 1 | keep | 実測ベース恒久知見 |
| reference_hayate_ui_shim_dep_swap | 2 | keep | legacy app残る限りswap表有効 |
| reference_ovldis_xref_absolute_blindspot | 2 | keep | degimon RE現役手法 |
| reference_remaining_tasks | 3 | **archive** | 参照先ファイル消失確認済、87日古+index孤児、pointer先無しの純pointer |
| reference_textinput_no_focusme_on_click | 2 | keep | root fix(L2)未了、現役 |
| reference_unity_mcs_standalone_verify | 2 | keep | Unity path実在確認済、degimon現役 |
| reference_vulkan_cold_cache_first_open | 1 | keep | 恒久診断知見 |
| reference_vulkan_rect_sdf_flush_order | 1 | keep | Vulkan構造制約 |
| reference_wayland_self_source_pipe_deadlock | 1 | keep(merge先) | 一般化版+設計規範 |
| reference_wayland_stuck_grab_vt_switch | 2 | keep | 再発時に即価値 |
| reference_xpcss_gloss_in_svg_assets | 3 | merge→xpcss_scss_source_not_dist | 具体色値はre-discover高コスト、削除でなく統合 |
| reference_xpcss_scss_source_not_dist | 2 | keep(merge先) | 教訓+gh fetch手順が具体的 |
| user_mac_developer | 2 | **keep+index復帰** | 孤児だが内容現役(Mac=正典と直結)、index 1行追加 |

**担当forkの所見**: 孤児2件は対照的 — remaining_tasks=参照先消失でarchive、user_mac_developer=index復帰が正。「未merge/残landing」系のstale記述2件は本文更新しないと将来 state claim 鵜呑みの罠。name: slug 命名不統一(ハイフン形/日本語混在)は [[link]] 解決の信頼性に影響。

---

