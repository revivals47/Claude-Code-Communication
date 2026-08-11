# Windows 95/98 — button state 挙動の仕様 + GUI_kit 現状 + ギャップ

担当: worker1 / Phase 3b 第3波（behavioral state 研究）/ 2026-05-20
**研究のみ・実装なし・cargo 起動なし**（PRESIDENT が gallery build で cargo 使用中）。視覚最終判定は user。

> 制約: 記憶ベース禁止。本 doc は 98.css (jdan/98.css) の `style.css` 原文（:root border token + button の :active/:hover/:focus/:disabled/.default 各規則）+ Win32 標準挙動を出典とする。現 GUI_kit 挙動は `button.rs` paint/event のコード読解（worker2 第2波 macos9-button-fix-draft §2 で検証済の構造制約を再利用）。

---

## 0. 出典 URL

| 種別 | 出典 | URL |
|------|------|-----|
| 実装 (CSS) | 98.css `style.css`（:root border tokens + button 状態規則） | https://github.com/jdan/98.css/blob/main/style.css |
| 実 OS 挙動 | Win32 `DrawFrameControl` / `DrawState`(DSS_DISABLED) 標準 | https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-drawstate |
| 現 GUI_kit | `crates/hayate-kit/src/widget/button.rs`（paint L290-622 / event L692-816）+ `widget/win95.rs`（bevel/focus/color） | コード読解 |
| 既存 finding | worker2 `workspace/phase3b/macos9-button-fix-draft.md` §2（renderer 構造制約） | 同 repo |

98.css 色 token（:root）: surface/btn-face `#dfdfdf`、button-highlight `#ffffff`、button-shadow `#808080`、window-frame `#0a0a0a`、text `#222`(98.css)/`#000`(実OS)。

---

## 1. state 仕様（98.css 原文 + 実 OS）

Win95 button の本質 = **2-stage 3D bevel が rest=raised / press=sunken に反転 + text 1px 沈み + hover 無し + 破線 focus + 既定ボタン外周黒枠 + disabled engrave**。

### 1a. rest（通常・raised）
- box-shadow（2 段 raised bevel、98.css `--border-raised-outer` + `--border-raised-inner`）:
  - 外 TL = `#ffffff`（button-highlight）, 外 BR = `#0a0a0a`（window-frame）
  - 内 TL = `#dfdfdf`（button-face）, 内 BR = `#808080`（button-shadow）
- 背景 surface `#c0c0c0`、radius 0、border none（bevel が枠）、min 75×23px、padding 0 12px
- font: Pixelated MS Sans Serif 11px、text は `text-shadow: 0 0 var(--text-color)` で擬似描画（黒）

### 1b. hover（**状態なし**）
- 98.css: `@media (not(hover))` の中だけ `:hover` で sunken を当てる = **hover 可能デバイスでは hover で見た目が変わらない**。
- → **Win95 button に hover state は存在しない**（マウス乗せても rest のまま）。これが Win95 の「素っ気なさ＝空気感」。

### 1c. press（:active・sunken + text 沈み）
- box-shadow を **sunken に反転**（98.css `--border-sunken-outer/inner`）:
  - 外 TL = `#0a0a0a`, 外 BR = `#ffffff`（raised の逆）
  - 内 TL = `#808080`, 内 BR = `#dfdfdf`
- **`text-shadow: 1px 1px var(--text-color)`** = ラベルが右下 1px へ沈む（押し込み感）。
- 背景・面色は不変（bevel の反転だけで「凹む」）。timing 概念 = 即時（アニメなし、押下の瞬間に切替）。

### 1d. focus（破線 rect）
- `outline: 1px dotted #000000; outline-offset: -4px` = **1px 黒の点線矩形を端から 4px 内側に**。
- press とは独立（focus 中でも raised/sunken は press 状態に従う）。

### 1e. disabled（engrave / 灰文字）
- `:disabled { color: var(--button-shadow) }` = テキスト `#808080`（灰）。
- `button:disabled { text-shadow: 1px 1px 0 var(--button-highlight) }` = 灰文字の**右下 1px に白 #ffffff の影**（彫り込み engrave、Win32 DSS_DISABLED と一致）。
- bevel は raised のまま、hover/press 反応なし。

### 1f. default button（既定ボタン・OK 等）
- 98.css `.default`: `--default-button-border-raised-outer` = **最外周 1px に near-black `#0a0a0a` の枠**（全辺 window-frame）+ bevel を 1px 内側へ。
- press 時は `--default-button-border-sunken-*` で同様に反転。
- = **既定ボタンは通常ボタンの外側に near-black の太め輪郭が 1 周**（Enter 既定の視覚強調）。

---

## 2. 現 GUI_kit の挙動（button.rs コード読解）

`ButtonState`(button.rs:17) = Normal / Hovered / Pressed の 3 値。**Disabled は enum でなく `disabled: bool`**（widget フィールド）。`bg_value` = 0=normal / 1=hover / 2=pressed（tween）。

| state | 現 GUI_kit 挙動 | 該当 |
|-------|----------------|------|
| rest | bevel テーマなら 2-stage raised bevel を `fill_rect` で 4 辺描画。`button_theme_win95` = bevel(白, 黒, #dfdfdf, #808080) | paint L426-517 / preset L108-130 |
| hover | `no_hover` 時 PointerMove を Ignored = **hover 無効**（Win95 preset は `.no_hover()`） | event L709-711 |
| press | bevel を **light↔dark 自動反転**（外: L430-440 / 内: L472-477）= sunken。`press_text_offset`(=1.0) でラベル 1px シフト（L568）。release 時 bevel テーマは**即時 snap-back**（L754-758、アニメなし） | paint L427-517 / event L740-758 |
| focus | bevel テーマ → `draw_focus_dotted`（端から 4px 内側、1px 黒点線、step_by(2)） | paint L522-529 / win95.rs:388 |
| disabled | bevel テーマ → `draw_etched`（BUTTON_HIGHLIGHT 白 を下地 + BUTTON_SHADOW 灰 を上に -1,-1 シフト）= engrave。pointer event は swallow（L697-705） | paint L578-593 |

**要点: Win95 の主要 state 挙動（bevel 反転 / text 沈み / hover 無し / 点線 focus / engrave disabled）は既に実装済**。色 token も win95.rs に正準値で定義（BUTTON_HIGHLIGHT #fff / BUTTON_SHADOW #808080 / BUTTON_DARK_SHADOW #000 / BUTTON_FACE #c0c0c0）。

---

## 3. ギャップ一覧（仕様 vs 現実装）

| # | 項目 | 仕様（98.css/実OS） | 現 GUI_kit | 重大度 | メモ |
|---|------|---------------------|-----------|--------|------|
| G1 | **default button 外周黒枠** | 既定ボタンは最外周に near-black `#0a0a0a` の 1 周枠（§1f） | **未実装**。button に "default" 概念なし、focus は点線のみ | 中 | Win95 の Enter 既定強調が出ない。ButtonTheme に default フラグ or chrome 側マーキングが要る |
| G2 | engrave 影の向き | disabled = 灰文字 + 白影 **右下 +1,+1**（DSS_DISABLED） | `draw_etched` は白下地 + 灰を **-1,-1（左上）** シフト | 低〜中 | 彫り方向が逆の可能性。実OSは「白ハイライトが右下」。要 user 視覚確認 + draw_etched 向き検証 |
| G3 | 外 BR bevel 色 | `#0a0a0a`（near-black） | `Color::rgb(0,0,0)`（純黒、preset L121） | 低 | 第1波 win95-refine でも既出の微差。#0a0a0a へ寄せ可 |
| G4 | bevel と radius | Win95 は radius 0（bevel は矩形辺、radius 無視 = worker2 §2-#2） | 同（radius 0） | なし | 仕様一致。問題なし |
| G5 | focus ring 二重描画 | 点線のみ | bevel テーマは点線 + 末尾 `draw_focus_ring`(active_theme) も走る（L618-621） | 低 | 点線の上に modern ring が重なる可能性。bevel テーマで末尾 ring を抑制すべきか要確認 |

> 注（G5 関連・横断）: 非 bevel テーマの step-6 focus ring は `HAYATE_DARK.accent`（cyan）を **hardcode**（L531）。Win95 は bevel 経路なので影響薄だが、XP/Win10 では theme accent と不一致になる横断バグ（winxp-behavior-research.md §3 G-X 参照）。

---

## 4. 改訂方針メモ（実装は user gallery 評価後）

優先度順（実装判断は PRESIDENT/boss、user 視覚確認前提）:

1. **G1 default button 外周黒枠**（中）: 「OK が既定だと分かる」Win95 の象徴。案 = ButtonTheme に `default_outline: Option<Color>` 追加 → bevel の外側に near-black 1px ring を 1 周描画（worker2 §4-C の Platinum リング capability と**共通基盤**にできる）。Win95 既定値 `#0a0a0a`。
2. **G2 engrave 向き検証**（低〜中）: `draw_etched` を Win32 DSS_DISABLED 準拠（灰文字 + 白影を右下 +1,+1）に揃えるか確認。現状でも「灰で凹んで見える」効果は出ているので user が違和感を訴えた場合に対応。
3. **G3 外 BR を #0a0a0a**（低・任意）: preset の純黒 → near-black。第1波 win95-refine の bevel 微修正と同 commit にできる。
4. **G5 focus ring 重複**（低）: bevel テーマ時に末尾 `draw_focus_ring` を抑制するか調査（点線のみが正）。

**触らない方が良い（仕様一致）**: bevel 反転・press_text_offset・no_hover・dotted focus inset 4px・disabled pointer swallow は 98.css/実OS と一致。空気感（hover 無し・即時 snap-back）も正しい。

> timing 概念: Win95 は press/release が**即時**（フェードなし）。GUI_kit は press を 0.08s EaseOut でアニメ（event L741）。98.css は CSS 即時切替。**0.08s でも体感は「ほぼ即時」だが、Win95 の硬質感を厳密に出すなら bevel テーマは press アニメも 0 にする選択肢**（user 視覚確認事項）。release は既に bevel テーマで即時 snap-back 済（L754-758）。
