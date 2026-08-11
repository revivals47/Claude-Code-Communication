# Phase 3b 第3波 完了サマリ（boss1 synthesis — PRESIDENT/codex 査読向け）

作成: 2026-05-20 / boss1。第3波 = behavioral state 研究 + golden 検証設計（worker cargo-free、研究/設計のみ）完了。
実装は user の gallery 評価後に優先度付けして dispatch（本 doc は実装候補の整理）。

## 0. 6 doc 完了 + boss1 検証（全て実コード/出典照合済、捏造ゼロ）

| doc | worker | boss1 検証要点 |
|-----|--------|----------------|
| win95-behavior-research.md | worker1 | 98.css 状態規則 + code 照合。Win95 主要 state は既実装と確認 |
| winxp-behavior-research.md | worker1 | xp.css 状態規則 + code。focus hardcode 横断バグ精密診断 |
| macos9-behavior-research.md | worker2 | Inside Macintosh + Aqua。脈動=Aqua 後継機能の研究訂正 |
| macos-bigsur-behavior-research.md | worker2 | Apple HIG + mackuba。no_hover 非忠実 + 脈動訂正 |
| win10-behavior-research.md | worker3 | MS/WinUI + code。横断2バグの最優先指摘 + framework 改訂提案 |
| golden-state-design.md | worker3 | 実 golden framework 全照合。空ラベル決定論化 + 層C→B 橋渡し |

---

## 1. 横断 framework state バグ 2 件（3 worker 独立確認、最高レバレッジ = 1 修正で 3-4 テーマ救済）

### Gap A: focus ring の色が cyan hardcode
- `button.rs:531` 非bevel focus ring が `HAYATE_DARK.accent`（= #55CCFF cyan、theme.rs:178 で boss1 grep 確認）を固定。XP/Win10/Big Sur が自テーマ accent でなく cyan focus になる。
- さらに step6 inner ring（L531）と末尾 `draw_focus_ring`（L618、active_theme 使用）の **二重描画**疑い。
- **修正案（worker3/worker1）**: ButtonTheme に `focus_color: Option<Color>` 追加（None なら active_theme().accent）+ 二重描画一本化。platform 側（consumer 不可）。

### Gap B: disabled 視覚が非bevel 経路で皆無
- `button.rs:578` の disabled etched は `bevel_outer_light.is_some()`（Win95/MacOS9 bevel テーマ）限定。modern/cosmic-text 経路（XP/Win10/Big Sur）は disabled でも full color 描画 = 無効ボタンが通常と同一見た目（click は無視されるが視覚的に区別不能 = UX 欠陥）。
- **修正案（worker3）**: ButtonTheme に `disabled_bg/disabled_fg/disabled_border: Option<Color>` 追加 + paint に bevel 非依存の disabled 分岐。各テーマ値（Win10 #CCCCCC/#A0A0A0、XP/BigSur 灰）を設定。platform 側。

→ **Gap A + B は ButtonTheme へのフィールド追加 2 種で XP/Win10/Big Sur(+MacOS9 disabled) の state 忠実度が一気に上がる**。enum 改修（Disabled/Focused 追加）は影響大のためフィールド追加（局所）を推奨（worker3 §4-C）。

---

## 2. mission への研究訂正（記憶ベース実装の罠を回避）

- **「脈動 (pulsing) default button」は Platinum にも Big Sur にも無い**。脈動は Aqua（OS X 10.0 導入 / Yosemite 2014 廃止）固有。Mac OS 9 default = 静的太黒枠リング、Big Sur default = 静的 accent 塗り。**脈動を足すと忠実度が下がる**（worker2 が macos9/bigsur 両 doc で指摘、出典 Aqua Wikipedia）。
- **classic Mac OS / macOS push button は hover で変化しない**。GUI_kit `button_theme_macos_big_sur` は no_hover 未設定で hover 明化（#1487FF）= 非忠実 → **no_hover 付与**が忠実（低リスク、テーマ値のみ）。

---

## 3. テーマ別 state ギャップ（framework gap 修正後 / user 優先度次第）

- **Win95**: 主要 state（bevel 反転 / text 沈み / hover無 / dotted focus / engrave disabled）は既実装。残: G1 default 外周黒枠（未実装、Mac OS 9 ring と共通 framework 基盤）、G2 engrave 向き（右下 vs 現 -1,-1）、G3 外BR #000→#0a0a0a。timing: press 即時 vs 現 0.08s（user 確認）。
- **XP Luna**: G1 hover が全面 amber tint vs 仕様=縁 inset glow、G2 press が scale縮小 vs 仕様=グラデ反転（press_scale 0.98 は XP 非実機）、focus 内側 blue glow。inset glow primitive 要（framework backlog）。
- **Big Sur**: no_hover 付与（§2）、非default(白) variant 不在（全 accent 塗り）、disabled dim（Gap B）。accent の user 設定追従は将来 theme framework。
- **Mac OS 9**: default 静的黒リング（§4-C framework）、focus は Platinum 実線 vs 現 bevel 一律 dotted（skin-split 要）。脈動追加禁止。

---

## 4. golden 検証設計（層B = AI GUI 不可視の決定論解消）

worker3 設計が実 framework（GoldenSnapshot/WidgetTestHarness/golden_widgets.rs、exact-match BGRA、GOLDEN_BLESS）に完全準拠。要点:
- **空ラベル widget で state golden を描画** → glyph 非描画 → cosmic-text 不踏 → 全テーマ exact（win10 含む）。**[[feedback_golden_env_drift]] を構造回避**（state 判別 px は bg/border/bevel/focus で glyph 非依存）。
- アニメ決定論化: state を event 駆動 → `update(LARGE_DT)` で tween settle → paint。
- **golden = user 承認済み見た目の回帰 lock**（実物 OS 自動 fidelity 判定ではない）。bless は user gallery 承認後（層C→B）。実物スクショ直 diff は AA/DPI で破綻するため非採用。
- 既存 golden_widgets.rs（rest 専用）非破壊、新 golden_widget_states.rs に widget×state×theme matrix。cosmic テキスト golden は env-gate 別 target（Tier D2）に隔離。
- **重要規律**: win10 disabled/focus は Gap A/B 修正実装後に bless（現状の欠陥を凍結しない）。

---

## 5. 実装優先度 recommendation（user gallery 評価後に確定）

3 層モデル状況: (A) 挙動仕様 = 研究完了 / (B) golden 検証 = 設計完了 / (C) 空気感 = user gallery 待ち。

推奨着手順（user が gallery で「どの state 挙動が最も気になるか」を示した後に最終確定）:
1. **Gap A + Gap B（framework ButtonTheme フィールド追加）** = 最高レバレッジ。XP/Win10/Big Sur の focus 色 + disabled 視覚を一括是正。platform 側、PRESIDENT or 専任 worker。
2. **テーマ別 state 値投入**（Big Sur no_hover、Win10 disabled #CCCCCC/#A0A0A0、各 focus 色）= Gap A/B のフィールドが入った後、低リスク。
3. **golden state suite**（worker3 設計）= 上記実装 + user 承認後に bless（順序厳守）。
4. **高コスト framework**（inset glow=XP hover/focus、default-ring=Win95/MacOS9、Big Sur 非default variant、多stopグラデ）= WAVE2-SYNTHESIS backlog と統合、user 優先度で順次。

cargo は引き続き -j1 直列、実装解禁は user 評価後に boss1 が 1 人ずつ。記憶ベース禁止・出典必須・視覚判定 user のみ を継続。
