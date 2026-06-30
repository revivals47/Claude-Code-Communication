# Handoff 2026-06-30 (work-PC) — testruct ライト design-system イニシアチブ P1-P4 完遂 + closeout

## 概要
testruct (hayate-kit-testruct) を dogfood に、GUI_kit の cool-light house design system + hayate-kit ビジュアル identity を作り込むイニシアチブ。UX 最優先 (Mac 模倣でなくレイアウト/配置/導線)。PRESIDENT→boss1 dispatch、worker1-3 並走 (worktree 隔離 + cargo serialize)。

## 着地 sha
- **GUI_kit main = `97467a5`** (PR #308 cool theme / #309 SplitView divider SSOT / #310 固定幅API / #311 SurfaceTheme re-export+wash / #312 surface primitive 3種)
- **testruct main = `cd2673b`** (PR #69 theme注入 / #70 canvas accent / #71 panel token / #72 Mac UX レイアウト)

## ★home-PC 再開手順 (この handoff を受けて)
1. **repo 同期 (revivals47 から pull)**:
   - `~/Documents/GUI_kit` → `git pull` → main `97467a5` を確認。
   - `~/Documents/hayate-kit-testruct` → `git pull` → main `cd2673b` を確認。
   - `~/Documents/Claude-Code-Communication` (本 handoff) → ★**revivals47 fork から pull** (`git@github.com:revivals47/Claude-Code-Communication.git`、home-PC では origin かもしれない)、HEAD `9fd4146`。**Akira-Papa の上流 (HTTPS) からではない** (push-remote 注意は下記 memory mirror #3 参照)。
2. **memory mirror**: 下記 memory mirror 節の 3 ファイル分を home-PC の `~/.claude/projects/-home-tlcr-Documents-Claude-Code-Communication/memory/` へ反映 + MEMORY.md 索引行を追加 (memory は local-only、git 外、本 doc が唯一の channel)。
3. **env-drift baseline 再確認**: home-PC は別 fontconfig (RTX4070)。golden は work-PC canonical ゆえ home-PC で font drift fail が出ても regression でなく env-drift ([[feedback_golden_env_drift]])。**home-PC で golden を盲目 bless しない**。cargo test の非 golden fail のみ regression signal。
4. **状態**: イニシアチブは完全クローズ・全 merge 済・全 idle。続行するなら backlog (a)-(d) (下記) が着手可。home-PC は PRESIDENT/boss1/worker を fresh spawn (work-PC の tmux session は別、context は本 doc + memory で引継ぎ)。
5. **設計レビュー画像** (`~/Documents/testruct-design-review/`) は work-PC ローカル・git 外。home-PC で要れば `HAYATE_SCREENSHOT=... cargo run -p testruct-ui -- --answer-sheet fukuoka` で再生成可。

## 段別サマリ
- **P1** ✅ cool light theme 確立: GUI_kit に `app_theme_hayate_light` + `titlebar_theme_hayate_light` + `auto_app_theme_for(&HAYATE_LIGHT)→Some` (PR#308)、testruct へ dual-channel 注入 (`with_app_theme` + `with_theme(&HAYATE_LIGHT)`、両方必須) + light titlebar (PR#69)。実アプリで chrome dark→cool white 転換、8 割効果実証。house accent **#1482DC**。
- **P2** ✅ 脱ハードコード + 単一 source 収束: SplitView divider の framework SSOT fix (PR#309、live-verify finding) + canvas/overlay/math の accent 収束 (PR#70) + パネル 6+RulerCorner の surface token 化 (PR#71)。2 種 blue → surface.accent 単一化。page 白維持。画素整合不変。idiom = `surface: SurfaceTheme` 直接 cache。
- **P3** ✅ Mac UX レイアウト: SplitView 固定幅 API `with_first_fixed`/`with_second_fixed` (PR#310、root-cause、ratio path byte-exact) + testruct Inspector 幅 **260** + Mac spacing (section 12pt / padding 8pt、15 const 中央集約) + Toolbar 論理再編 `history|tools|clipboard|arrange|align|view` (PR#72)。幅・toolbar grouping は user 視覚確認で確定。
- **P4-1** ✅ foundation: SurfaceTheme 短 path re-export (`hayate_kit::SurfaceTheme`) + `selection_wash`/`hover_wash` を SurfaceTheme method 化 (PR#311)。(c) control/disabled token は migrate-not-receptacle で DEFER。
- **P4-2** ✅ surface primitives: DividerWidget/SectionWidget/PanelWidget additive 新設 (PR#312、codex 設計レビュー健全判定、6 ガードレール test)。★boss1 検証ゲートが merge 前に forward-gap (flatten children が VStack の bounds-aware drag hook を bypass) を捕捉 → 3 drag hook 明示 forward + bounds-aware test で根治。
- **P4-3** ⏸ backlog (toolbar separator styling、polish 寄り)。
- **P4-4** ⏸ **DEFER 確定** (migration、pixel-parity 維持不能)。

## ★最重要: goal reframe (user 明示) + dogfood の成果
- **goal reframe**: 「手描き撲滅は過剰。手描きはオプションとして残すべき」。P4-2 primitive は『新規/将来 panel が選べる additive オプション』であって既存手描き panel の強制移行 mandate ではない。手描きと primitive は共存、どちらも valid。
- **dogfood 最大の成果 (closeout doc に明記すべき)**: primitive の適用境界を実証で確定 = **新規 GUI_kit-native panel に good / 既存 monolithic 手描き panel の retrofit には不向き**。決定的理由 2 つ: (1) testruct パネルは monolithic immediate-mode painter で hit-rect を paint() が生成 (paint↔event 同一経路) → primitive (widget tree 合成前提) 採用は full 再 architecture。(2) SectionWidget/ButtonWidget が `FontFamily::Monospace` ハードコード、testruct は全 SansSerif、override 無し → header/label の maxdelta=0 不能。
- = honest DEFER は正しい判断。撲滅という goal 設定自体が過剰だった。中核 mission (P1-P3 cool-light + Mac UX) は完遂済。

## backlog (silent drop 禁止、『必要になったら』着手・投機しない)
- (a) SectionWidget/ButtonWidget font-family override (Monospace ロック解消、SansSerif app で primitive 使う時必須、新世代 app 全般有益、単独では testruct migration 解禁せず)。
- (b) P4-3 toolbar separator per-instance styling + group-spacing (toolbar.rs:15-16 + paint :480-501)。
- (c) (c)-DEFER 4 control の theme 非追従 latent bug (page_nav◀▶ / inspector トグル / pages add-btn / layers eye-lock、dark/theme-swap で顕在、実 widget 化で根治)。
- (d) forward-gap 新サブケース = memory promote 候補 (PRESIDENT 後日判断)。

## 学び (forward-gap 新サブケース、promote 候補)
container の children() を flatten 公開すると、その container の bounds-aware event override (VStack drag hook = child_rects hit-test) が bypass され子へ trait-default forward で誤 dispatch。検知 = composite_widget!(body: single) で単一子 forward すれば container override 保持 / flatten 時は bounds-aware hook を self.body へ明示 forward。予防 = reachability test では未検出ゆえ bounds-aware dispatch 専用 test が要る。[[feedback_widget_trait_forward_gap_pattern]] sub-case 候補。

---

## memory mirror (home-PC 向け verbatim、本 session の更新 3 件)

canonical 整理メモ: boss1 が closeout 時に重複作成した `project_testruct_light_design_system.md` は no-duplicate 規範で削除済 (固有の forward-gap 学びは下記 canonical へ統合済)。home-PC は下記更新を mirror すれば最新。更新 = (1) 新規 `feedback_primitives_additive_option_not_mandate.md` (2) `project_testruct_design_system_initiative.md` 最新化 (3) ★`reference_dual_pc_setup.md` への追補 (push-remote、下記 #3)。

### ★3. reference_dual_pc_setup.md への追補 (push 後に PRESIDENT 追加、handoff/comms repo の push 先)
既存 `reference_dual_pc_setup.md` の sync channel section に下記 1 文を追補済 (home-PC も同一文を local memory に反映):
```
- **★handoff/comms repo の push 先注意 (2026-06-30 実証)**: `Claude-Code-Communication` (handoff doc + agent-comms repo) は `origin` = `https://github.com/Akira-Papa/Claude-Code-Communication.git` (テンプレ上流・HTTPS・push 不可 read-only)、別に `userfork` = `git@github.com:revivals47/Claude-Code-Communication.git` (SSH 認証済) が dual-PC sync remote。handoff push は `git push userfork main` が正 (origin は read-only 上流)。boss1 が `git push origin main` を試行し `could not read Username for https://github.com` で失敗したのが今回の真因 = remote 取違え。home-PC も userfork から fetch。GUI_kit / 新世代 app repos は origin=revivals47 直ゆえこの注意は不要 (comms repo 固有)。dual-PC 枝分かれ時は別 handoff doc = 別ファイルゆえ conflict なし rebase → userfork ff push。
```

### MEMORY.md 索引 2 行 (既存、確認用)
```
- [framework primitive は additive オプション、強制 migration mandate にしない](feedback_primitives_additive_option_not_mandate.md) — 2026-06-30 user 明示「手描き撲滅は過剰、手描きはオプションで残す」。新 primitive 追加≠既存動作コードの全強制移行。purity/撲滅を絶対 goal にしない、bespoke/手描きは valid 共存。retrofit migration は parity 確実+benefit>risk 時のみ
- [testruct デザインシステム/UX イニシアチブ](project_testruct_design_system_initiative.md) — **2026-06-30 起案+boss1 dispatch**: 「testruct ダサい」→私+codex 診断収束=デザインシステム不在(テーマ未統合/手描き色/余白0/1px硬境界、GUI_kitデフォルトは健全)。方針=**Mac見た目模倣でなく使いやすさ(レイアウト/配置/導線)を詰める+testruct dogfoodで GUI_kit 良質ライト・デフォルトデザインシステム作り込み**。4段=P1テーマ統一(実証済8割)/P2脱ハードコード/P3余白配置/P4 Panel/Sectionプリミティブ。前提=ToolbarWidgetテーマ追従バグ根治 PR#307(0d9552f)。default dark→light反転は将来②保留
```

### 1. feedback_primitives_additive_option_not_mandate.md (★新規、full body verbatim)
```markdown
---
name: feedback_primitives_additive_option_not_mandate
description: framework primitive/抽象は additive オプション、動く既存コードの強制 migration mandate にしない。手描き/bespoke は valid として残す
metadata:
  type: feedback
---

2026-06-30 work-PC、testruct design-system イニシアチブ P4 で user 明示: 「手描きを撲滅は過剰です。手描きのオプションは残しておくべきです」。

PRESIDENT が P4 の goal を「手描き撲滅 (eliminate hand-painting)」と設定 → boss1 honest grounding が「既存 monolithic 手描き panel の primitive 移行は pixel-parity 非両立 (paint↔hit-rect 同一経路の全書換 + Monospace ロック)」と実証 → DEFER 推奨。user が goal 設定自体を過剰と訂正。

**Why**: framework に良い primitive を追加することと、動いている既存コードを全部それへ強制移行することは別。「純化/撲滅 (purity/elimination)」を絶対 goal にすると、parity 回帰 risk や大規模 rewrite コストを払ってまで動くコードを壊しかねない。root-cause 理念 ([[feedback_root_cause_over_quick_fix]]) は「band-aid を避け根治する」であって「全てを単一 idiom に揃える」ではない。primitive と手描き/bespoke は共存して valid。

**How to apply**: 新 primitive/抽象を framework に足す時は「新規/将来コードが選べる additive オプション」と framing する。既存の動くコードへの retrofit migration は (a) parity 維持が確実 (b) benefit が rewrite risk を上回る 時のみ。"eliminate X entirely / 撲滅 / 全 migration" を goal に掲げそうになったら過剰を疑い、「option として提供 + 既存は据置」を一次案にする。dogfood で primitive の適用境界 (新規 good / retrofit 不向き) を見極めるのは健全な成果。bespoke (ruler/canvas 等の数学的描画) は永続的に custom 維持が正。[[feedback_no_op_migration_eval_closure_pattern]] の goal-setting 版。
```

### 2. project_testruct_design_system_initiative.md (P4 closeout + goal reframe + forward-gap 学び で最新、full body verbatim)
```markdown
---
name: project_testruct_design_system_initiative
description: testruct を dogfood に GUI_kit の良質ライト・デフォルトデザインシステム + UX を作り込むイニシアチブ (2026-06-30 起案、boss1 dispatch)
metadata:
  type: project
---

**2026-06-30 work-PC 起案 + boss1 dispatch**: user が testruct の見た目を「ダサい (2000年代Linux風)」と問題提起 → 私 + codex で独立診断、両者収束。真因 = **デザインシステム不在** (テーマ未統合 / 各パネルが手描きハードコード色 / 余白ゼロ Stack::new(0.0) / 1px 硬境界)。GUI_kit デフォルト自体は健全 (widget_showcase で実証、清潔なダーク)。

**user の方針 (再フレーム重要)**: Mac の**見た目模倣ではない**。Mac が優れているのは**レイアウト・ボタン配置・操作導線 (=使いやすさ)**。testruct は hayate-kit 初アプリなので、これを **dogfood に GUI_kit の良質なライト・デフォルトデザインシステムを作り込む**。基本ライト、UX 最優先、hayate-kit 自身の identity 確立。Mac 版 (testruct-v3、AppKit ネイティブ、NSColor システム色) は使い勝手の**参考**。

**4 段スコープ (各段 別 PR + 視覚確認)**: P1 テーマ統一 (testruct を with_app_theme でライト house style に。実機実証済 = 8割効果) → P2 パネル脱ハードコード (inspector/layers/pages_panel/ruler/canvas_overlay の手描き色を注入テーマ token へ、各パネルに inject_theme、硬1px境界→淡 separator) → P3 余白/配置の UX 詰め (Mac InspectorView = section 12pt/padding 8pt/淡Divider/幅240、Toolbar = file/tools/align/modes グループ化、ただし ruler-canvas 画素整合は不変) → P4 framework 還元 (GUI_kit に PanelWidget/SectionWidget 等テーマ駆動 surface プリミティブ、手描き撲滅・再発防止)。

**前提となった修正**: GUI_kit PR #307 merge 済 (main 0d9552f)。ToolbarWidget が `let t = &HAYATE_DARK` ハードコードで注入テーマ無視のバグ → inject_theme override + surface/button token 由来 ToolbarPalette で根治。これで toolbar もテーマ追従可能 (P1 の前提)。[[feedback_root_cause_over_quick_fix]] 遵守。

**house identity = cool 確定 (2026-06-30 user 判断ロック)**: hayate-kit ライト house theme は cool (blue accent)。P1a で **app_theme_hayate_light を新 mint** (flat HAYATE_LIGHT と対、auto_app_theme_for を Some 返すよう配線) = warm の app_theme_hayate_original 流用は却下。理由=既存パネルが cool light + 現 dark default も cool(青/シアン)で identity 連続、additive で golden 無影響。boss1 premise 訂正 2件: (1) testruct パネルは既に cool light、現状画像の dark は chrome のみ framework dark 継承 = P1 本質は chrome light 化で整合 (2) with_app_theme は AppTheme 集約必須、flat HAYATE_LIGHT 単体は注入不可。

**P1 構成**: P1a GUI_kit(track-light-theme) app_theme_hayate_light mint + light titlebar → P1b testruct main.rs:298 App::new に with_app_theme + build_systemlike 第4引数を light titlebar に差替(現:359-365)。worker1 担当、P1b は P1a 着地後。P2 で blue 2種(64,132,214 / 37,99,235)を新 cool accent 単一 source へ統一。P3 Inspector 固定幅 Mac実測260pt第一候補(240と視覚比較可)。

**進捗 (2026-06-30 session、boss1 dispatch 実行中)**: P1-P3 完遂、P4 着手 GO 済。
- 前提 fix: ToolbarWidget テーマ追従 PR#307 (GUI_kit 0d9552f)。
- P1 (テーマ統一) ✅: P1a app_theme_hayate_light mint PR#308 (GUI_kit dc26c50) + P1b testruct 注入 dual-channel (with_app_theme + with_theme HAYATE_LIGHT) + light titlebar PR#69 (testruct 7e0ce67)。
- P2 (脱ハードコード) ✅: P2a SplitViewWidget divider SSOT fix PR#309 (GUI_kit 860557d) + P2c canvas/overlay/math accent 収束 PR#70 + P2b パネル6種 inject_theme/surface token PR#71 (testruct 80c81dc)。全要素 surface トークン/accent #1482DC 単一 source 収束、page 白維持、画素整合不変。
- P3 (UX レイアウト) ✅: P3a SplitView 固定幅 API (with_first_fixed/with_second_fixed) PR#310 (GUI_kit 8f657dc) + P3b testruct Inspector 幅260(user選択)+Mac実測 spacing(section12pt/padding8pt)+Toolbar 論理再編(history|tools|clipboard|arrange|align|view、user が clipboard 独立群=区切り復活を選択) PR#72 (testruct cd2673b)。
- framework 副次バグ 3件根治 (Toolbar#307/SplitView#309) + 固定幅 primitive#310、全て testruct dogfood が炙り出し GUI_kit 還元。全段 golden bit-exact + 視覚確認ゲート。
- P4 (framework primitive) = P4-1 SurfaceTheme crate-root re-export + selection_wash(16%)/hover_wash(6%) method PR#311 (GUI_kit 55317d6) + P4-2 DividerWidget/SectionWidget/PanelWidget greenfield PR#312 (GUI_kit 97467a5、codex 全4観点支持、dirty契約統一+forward-gap 修正)。**P4-4 migration = ★DEFER 確定 + goal reframe (2026-06-30 user 明示)**: 「手描き撲滅は過剰、手描きはオプションとして残すべき」。boss1 honest grounding が 2 決定的 finding を実証 = (1) testruct パネルは monolithic immediate-mode painter (paint↔hit-rect 同一経路、tree 分解+interaction 全書換が必要) (2) SectionWidget/ButtonWidget が FontFamily::Monospace ハードコード vs testruct 全 SansSerif → header maxdelta=0 構造的に不能。**= P4-2 primitive の適用境界を dogfood が確定: 新規 GUI_kit-native panel には good、既存 monolithic 手描き panel の retrofit には不向き**。手描きと primitive は共存・どちらも valid (撲滅という goal 設定自体が過剰だった)。P4 closeout、既存 testruct panel は手描き維持 (回帰なし)。backlog (投機せず必要時着手): (a) SectionWidget/ButtonWidget font-family override (dogfood surface の実 gap、SansSerif app で primitive 使う時必要) (b) P4-3 toolbar separator styling/group-spacing primitive (toolbar.rs:15-16/:480-501) (c) (c)-DEFER 4 control (page_nav/inspector トグル/pages add-btn/layers eye-lock) theme 非追従 latent bug。設計レビュー画像 = ~/Documents/testruct-design-review/ (testruct_現状→P3完了_最終)。

**学び候補 (forward-gap 新サブケース、P4-2 PR#312 で boss1 検証ゲートが merge 前捕捉、promote 判断 PRESIDENT 後日)**: container の children() を **flatten 公開** (内側 VStack の rows を直接返す) と、その container の **bounds-aware event override** (VStack の on_drag_event/on_drag_start/on_in_process_drag_start = child_rects hit-test) が **bypass** され、子へ trait-default forward で誤 dispatch (press 点直下でなく first-Some の子)。さらに trait-default の on_drag_start/on_in_process は None 返却で子へ forward すらしない (core.rs:615/642) → 無 override だと panel 内 draggable は完全 reach 不能。検知 = `composite_widget!(body: single)` で単一子 forward なら container override 保持 / flatten 時は bounds-aware hook を self.body へ明示 forward。予防 = `collect_focusable_ids` 系 reachability test では未検出ゆえ **bounds-aware dispatch 専用 test** が要る。[[feedback_widget_trait_forward_gap_pattern]] の sub-case 候補。

**決定保留 (将来の ② PRESIDENT 判断)**: GUI_kit global default を dark→light 反転するかは今回スコープ外。今回は testruct を良質ライト + 共有 cool ライト house theme 作り込みまで。反転は showcase/goldens/他app 影響大ゆえ別判断。

**実行体制**: boss1 dispatch (user 選択)。P1 即着手可、並行で P2-P4 タスク分解 + worktree 計画を PRESIDENT に ack 要求。設計レビュー画像 = ~/Documents/testruct-design-review/ (現状/ライト統一/ツールバー修正後/macOS試作)。関連 [[project_dtp_app_roadmap]] [[feedback_new_apps_depend_on_gui_kit_only]] [[project_kit_only_verification_loop]]。
```
