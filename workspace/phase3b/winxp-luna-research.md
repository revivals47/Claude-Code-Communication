# Windows XP Luna (Blue) — 実物調査 + GUI_kit 差分 + 改訂案

担当: worker1 / Phase 3b 第1波（調査のみ・実装なし・cargo なし）/ 2026-05-20

> **制約遵守**: 記憶ベース実装禁止。本 doc は (a) xp.css ソース原文（botoxparty/XP.css、main branch）と (b) Windows XP 実機 system color 値（system colour 一覧 gist）の2系統一次資料に基づく。視覚最終判定は user（AI/PRESIDENT は GUI 不可視）。

---

## 0. 出典 URL（一次資料）

| 種別 | 出典 | URL |
|------|------|-----|
| 実装 (CSS) | botoxparty XP.css `themes/XP/_variables.scss` | https://github.com/botoxparty/XP.css/blob/main/themes/XP/_variables.scss |
| 実装 (CSS) | XP.css `themes/XP/_window.scss`（タイトルバー/枠） | https://github.com/botoxparty/XP.css/blob/main/themes/XP/_window.scss |
| 実装 (CSS) | XP.css `themes/XP/_buttons.scss` | https://github.com/botoxparty/XP.css/blob/main/themes/XP/_buttons.scss |
| 実装 (CSS) | XP.css `themes/XP/_forms.scss`（input/radio/check/select） | https://github.com/botoxparty/XP.css/blob/main/themes/XP/_forms.scss |
| 実機 system color | Windows System Colours (by OS) gist | https://gist.github.com/zaxbux/64b5a88e2e390fb8f8d24eb1736f71e0 |
| 実機 visual style | Windows XP visual styles (Wikipedia) | https://en.wikipedia.org/wiki/Windows_XP_visual_styles |
| font 仕様 | XP Visual Guidelines: Fonts (retrospace mirror) | https://www.retrospace.net/download/WebApplications/WindowsXPDesignGuidelines/fonts.htm |

注: xp.css は CSS 再現実装、system color gist は実機レジストリ由来の正準値。**両者で値が食い違う箇所は本 doc で明示し、実機正準値を優先採用候補とする**（xp.css は WEB 制約で一部簡略化しているため）。

---

## 1. 実物の色実値（hex 一覧）

### 1a. 実機 system color（正準・Luna Blue）

| 役割 | system color 名 | hex | RGB |
|------|----------------|-----|-----|
| surface / 3D face | Control (ButtonFace) | **#ECE9D8** | 236,233,216 |
| button highlight（明） | ButtonHighlight | **#FFFFFF** | 255,255,255 |
| button shadow（暗） | ButtonShadow (ControlDark) | **#ACA899** | 172,168,153 |
| window（入力面） | Window | **#FFFFFF** | 255,255,255 |
| window text | WindowText | **#000000** | 0,0,0 |
| title bar active 基色 | ActiveCaption | **#0054E3** | 0,84,227 |
| title bar active 明端 | GradientActiveCaption | **#3D95FF** | 61,149,255 |
| title bar inactive | InactiveCaption | **#7A96DF** | 122,150,223 |
| selection（強調） | Highlight | **#316AC5** | 49,106,197 |
| selection text | HighlightText | **#FFFFFF** | 255,255,255 |
| menu highlight | MenuHighlight | **#316AC5** | 49,106,197 |
| button text | ButtonText | **#000000** | 0,0,0 |

### 1b. xp.css 実装値（CSS 再現、視覚調整済）

```
--surface:           #ece9d8   （実機 Control と一致）
--button-highlight:  #ffffff
--button-face:       #dfdfdf   （実機 #ECE9D8 と差。CSS は 3D 押下面を白寄せ）
--button-shadow:     #808080   （実機 #ACA899 と差。CSS は中間グレー流用）
--window-frame:      #0a0a0a
--dialog-blue:       #2267cb   （= selection。実機 Highlight #316AC5 と差）
--input-border:      #789dbc   （= 7f9db9 が select 用、789dbc が input 用）
```

**食い違い所見**: xp.css は button-shadow と selection を簡略値にしている。**実機正準（ButtonShadow #ACA899 / Highlight #316AC5）を採用推奨**。surface #ECE9D8 と active caption #0054E3 は両者一致。

---

## 2. font（名称・サイズ・太さ）

| 用途 | 実機 XP | xp.css | 備考 |
|------|---------|--------|------|
| UI 全般（ボタン/メニュー/本文） | **Tahoma 8pt（≈11px）regular** | `"Pixelated MS Sans Serif", Arial` 11px | XP は MS Sans Serif → Tahoma へ移行 |
| タイトルバー caption | **Trebuchet MS Bold 10pt（≈13px）** | `"Trebuchet MS"` bold 13px | XP の象徴的変更点。caption だけ Trebuchet MS |
| input/textarea selection | Tahoma 8pt | var(--sans-serif) | — |

- 実機 XP の UI 基準フォントは **Tahoma 8pt**。タイトルバーのみ **Trebuchet MS Bold**（XP で初採用、視覚的特徴）。
- GUI_kit には Tahoma も Trebuchet MS も bitmap asset が無く、現状 `LEGACY_JP_16_PROP`（16px 日本語）流用。**font asset 要否は別判断**（重いアセット導入は worker3 の Win95 MS Sans Serif 論点と統合して PRESIDENT 判断）。本 doc は色/形状の改訂を主とし、font は title_size=13 / ui_size=11 の数値整合のみ提案。

---

## 3. 角丸 radius / border / bevel 構成

### 3a. ボタン（xp.css `_buttons.scss` 原文）

- `border: 1px solid #003c74`（濃紺アウトライン。XP ボタンの最外周）
- `border-radius: 3px`
- 通常背景 = 縦グラデ（180deg）:
  - 0%: **#ffffff**（rgba 255,255,255）
  - 86%: **#ecebe5**（rgba 236,235,229）
  - 100%: **#d8d0c4**（rgba 216,208,196）
- 押下（active）= 縦グラデ（180deg）:
  - 0%: **#cdcac3** / 8%: **#e3e3db** / 94%: **#e5e5de** / 100%: **#f2f2f1**
- hover = 外周 amber グロー（inset box-shadow 4層）:
  - inset -1px 1px **#fff0cf**, inset 1px 2px **#fdd889**, inset -2px 2px **#fbc761**, inset 2px -2px **#e5a01a**
- focus = 外周 blue グロー（inset box-shadow 5層）:
  - inset -1px 1px **#cee7ff**, inset 1px 2px **#98b8ea**, inset -2px 2px **#bcd4f6**, inset 1px -1px **#89ade4**, inset 2px -2px **#89ade4**

XP ボタンは Win95 のような硬い 4 層 bevel ではなく、**1px 濃紺 border + 縦グラデ + hover/focus で内側ソフトグロー** が本質。

### 3b. 入力欄（xp.css `_forms.scss`）

- input border: `1px solid #7f9db9`（select）/ `#789dbc`（input var）。sunken bevel ではなく **1px ソリッド soft-blue border**。
- selection: 背景 `--dialog-blue`（実機 Highlight #316AC5）, 文字 white。
- radio/checkbox: border `1px solid #1d5281`、bg グラデ `#dcdcd7→#fff`(135deg)、hover amber inset。

### 3c. ウィンドウ枠（xp.css `_window.scss` — XP の最重要視覚要素）

XP ウィンドウは **3px の青枠 + 上端 8px 角丸**。box-shadow 6 層 inset で立体青枠を再現:
```
inset  1px  1px #0831d9   (TL 1層)
inset -1px -1px #00138c   (BR 1層)
inset  2px  2px #166aee   (TL 2層)
inset -2px -2px #001ea0   (BR 2層)
inset  3px  3px #0855dd   (TL 3層)
inset -3px -3px #003bda   (BR 3層)
border-top-left-radius: 8px; border-top-right-radius: 8px;
```
→ 外側ほど明るい青(#166aee/#0855dd)、内側ほど濃紺(#00138c/#001ea0)の **多層青ベベル**。これが「XP らしさ」の核。

### 3d. タイトルバー（xp.css `_window.scss`）

- height: **28px**, font Trebuchet MS bold 13px, text-shadow `1px 1px #0f1089`(濃紺影)
- 背景 = 縦グラデ（180deg、グロッシー多段）:
  - 0%: **#0997ff**（上端ハイライト）
  - 8%: **#0053ee**
  - 40%: **#0050ee**
  - 88%: **#0066ff**
  - 93%: **#0066ff**
  - 95%: **#005bff**
  - 96%: **#003dd7**
  - 100%: **#003dd7**（下端の濃い帯）
- border: top/left `1px #0831d9`, right `1px #001ea0`、上角丸 8px/7px
- ボタン: min 21x21px, base bg **#0050ee**（XP は SVG アイコン使用、bevel なし）。close は赤系グロッシー square + white X。

---

## 4. 現 GUI_kit 定義との差分一覧

### 4a. palette（`theme.rs` XP_LUNA_THEME）

| field | 現 GUI_kit | 実物正準 | 判定 |
|-------|-----------|---------|------|
| bg_primary | #ECE9D8 | #ECE9D8 (Control) | ✅ 一致 |
| bg_surface | #FFFFFF | #FFFFFF (Window) | ✅ 一致 |
| accent | #0054E3 | #0054E3 (ActiveCaption) | ✅ 一致（良好） |
| fg_primary | #000000 | #000000 | ✅ 一致 |
| border | #7A8CAF | input #789DBC / #7F9DB9 | ⚠ 近いが微差。入力欄正準へ寄せる余地 |
| separator | #BDB89C | ButtonShadow #ACA899 | ⚠ 実機 shadow へ寄せる |
| selection_overlay | rgba(#0054E3,90) | Highlight **#316AC5** | ⚠ 実機 selection は別色。#316AC5 採用推奨 |
| accent_hover | #2E6AE9 | GradientActiveCaption #3D95FF 系 | △ 用途別。caption明端と整合させる選択肢 |
| border_radius | 6.0 | window 上角 8px / button 3px | △ widget別。下記改訂参照 |
| border_radius_sm | 3.0 | button 3px | ✅ 一致 |

### 4b. button（`button.rs` button_theme_xp_luna）

| 項目 | 現 GUI_kit | xp.css 正準 | 判定 |
|------|-----------|-------------|------|
| gradient | #ffffff → #d8d0c4（2 stop） | #ffffff 0% → #ecebe5 86% → #d8d0c4 100%（3 stop） | ⚠ 中間 stop 欠落。86% の #ecebe5 を追加すると下部の質感が出る |
| border | 1px #003C74 | 1px #003c74 | ✅ 一致 |
| radius | 3.0 | 3px | ✅ 一致 |
| bg_pressed | #CDCAC3 | active 0% stop #cdcac3 | ✅ 一致（簡略だが代表値） |
| bg_hover | #FDEBB2 | amber inset glow（#fff0cf/#fdd889/#fbc761/#e5a01a） | △ flat 近似。border_hover #E5A01A は最下層と一致 ✅ |
| shine(180) | 有 | — | ◯ グラデ艶を shine で代替、妥当 |
| font_size | 11.0 | 11px | ✅ 一致 |

button は **既にかなり忠実**。改善は (1) グラデ3 stop 化、(2) hover を amber 多層 inset に寄せる（framework が inset glow を持つか要確認）の2点のみ。

### 4c. input（`input.rs` input_theme_xp_luna）

| 項目 | 現 GUI_kit | xp.css 正準 | 判定 |
|------|-----------|-------------|------|
| bg | #FFFFFF | #FFFFFF | ✅ |
| border_color | #7A8CAF | #789DBC（input）/ #7F9DB9（select） | ⚠ #7F9DB9 へ寄せ推奨 |
| border_focused | #0054E3 | focus blue glow 系（#98b8ea 等） | △ accent 流用、許容 |
| selection_color | rgba(#0054E3,120) | Highlight **#316AC5** | ⚠ #316AC5 へ |
| border_radius | 3.0 | XP input は実質 0〜2px（角ほぼ直角）, select 3px | △ 微差。3.0 維持可 |

### 4d. titlebar（`titlebar.rs` titlebar_theme_xp_luna）

| 項目 | 現 GUI_kit | xp.css / 実機正準 | 判定 |
|------|-----------|-------------------|------|
| bg / gradient | #0053ee → #003dd7（2 stop） | グロッシー 8 stop（上端 #0997ff ハイライト→ #003dd7 下端） | ⚠ **最大ギャップ**: 上端の明るい #0997ff ハイライト band が無く、グロッシー感が出ない |
| height | 28.0 | 28px | ✅ 一致 |
| title_size | 13.0 | 13px | ✅ 一致 |
| title_bold | true | Trebuchet MS bold | ✅ （font asset は別） |
| border_color | #0831D9 | top/left #0831d9 | ✅ 一致 |
| close_bg / hover | #BD2C2C / #E84545 | 赤グロッシー（XP は SVG, base #0050ee + 赤 close） | ◯ 近似妥当 |
| max/min bg | #0050EE / hover #347CFF | base #0050ee | ✅ 一致 |
| bevel_light | #0997FF | 上端ハイライト色と同 | ✅ 良好 |
| text_shadow | （未設定?） | 1px 1px #0f1089 濃紺影 | ⚠ caption の濃紺影が欲しい（framework が title text-shadow を持つか要確認） |

---

## 5. 改訂案

### 5a. palette `XP_LUNA_THEME`（theme.rs）改訂値

```rust
// 実機 system color 正準へ寄せる
border:            Color::rgb(0x7F, 0x9D, 0xB9),   // input/select border 正準（現 #7A8CAF）
separator:         Color::rgb(0xAC, 0xA8, 0x99),   // ButtonShadow 実機（現 #BDB89C）
selection_overlay: Color::rgba(0x31, 0x6A, 0xC5, 90), // Highlight #316AC5 実機（現 accent 流用）
accent_hover:      Color::rgb(0x3D, 0x95, 0xFF),   // GradientActiveCaption（現 #2E6AE9、caption明端と統一）
// bg_primary #ECE9D8 / bg_surface #FFFFFF / accent #0054E3 / fg #000000 は据え置き（既に正準一致）
// radii: border_radius_sm 3.0 据え置き(=button)。border_radius は 6.0→ window 上角は WindowFrame 側で 8px 別管理推奨
```

### 5b. button `button_theme_xp_luna` 改訂

```rust
// グラデを 3 stop 化（中間 #ecebe5 を追加）し下部質感を出す。
// framework の .gradient が 2 色のみなら 3 stop 対応 or shine 調整で近似。
.gradient(Color::rgb(255,255,255), Color::rgb(216,208,196))  // 端点は据え置き
// → 可能なら mid-stop #ECEBE5(86%) を framework 拡張で。不可なら現状維持で許容（差は微小）
.border(1.0, Color::rgb(0,60,116))   // #003C74 据え置き ✅
.border_hover(Color::rgb(229,160,26)) // #E5A01A 据え置き ✅
.bg_pressed(Color::rgb(205,202,195))  // #CDCAC3 据え置き ✅
.radius(3.0)                           // 据え置き ✅
// 改善余地: hover を amber 多層 inset glow に（framework が inset bevel/glow API を持つ場合のみ）
```
→ **button は最小改訂で良い**（既に高忠実）。

### 5c. input `input_theme_xp_luna` 改訂

```rust
.border_color(Color::rgb(0x7F, 0x9D, 0xB9))         // #7F9DB9 正準（現 #7A8CAF）
.selection_color(Color::rgba(0x31, 0x6A, 0xC5, 120)) // Highlight #316AC5（現 accent 流用）
// bg #FFFFFF / border_focused #0054E3 / radius 3.0 据え置き
```

### 5d. titlebar `titlebar_theme_xp_luna` 改訂（**最重点 = XP らしさの核**）

```rust
// 現状の 2 stop では XP のグロッシー感が出ない。
// (1) framework の titlebar gradient が多段対応なら 8 stop へ:
//     上端 #0997FF → #0053EE → #0050EE → #0066FF → #005BFF → #003DD7 下端
// (2) 2 stop 制約なら、上端を明るく: bg #0997FF（上端ハイライト）/ gradient_bottom #003DD7
//     現状 bg #0053EE は中間色なので「上が明るく光る」印象が出ていない疑い。
bg:                Color::rgb(0x09, 0x97, 0xFF),  // 上端ハイライト（現 #0053EE）※多段不可時の次善
bg_gradient_bottom: Some(Color::rgb(0x00, 0x3D, 0xD7)), // 据え置き ✅
height: 28.0,                                      // 据え置き ✅
title_size: 13.0, title_bold: true,                // 据え置き ✅
border_color: Color::rgb(0x08, 0x31, 0xD9),        // 据え置き ✅
bevel_light: Some(Color::rgb(0x09, 0x97, 0xFF)),   // 据え置き ✅
// 追加希望: title text-shadow 1px1px #0F1089（framework が対応する場合）
// close 赤/青ボタンは現状の近似で許容（実機は SVG アイコン）
```

### 5e. WindowFrame（PRESIDENT 横断課題側 / 参考情報）

XP の象徴 = **3px 多層青枠 + 上端 8px 角丸**（§3c）。これは titlebar theme でなく WindowFrame widget の描画。PRESIDENT の skin 連動 titlebar/framework 対応の中で、XP 選択時に「青多層枠 + 上角丸」を出せると忠実度が大きく上がる。本 doc は参考として 6 層 inset 値を §3c に記載。

---

## 6. 改訂の優先度（user 視覚確認向け）

1. **titlebar グラデ上端ハイライト**（§5d）— XP らしさ最大。最優先。
2. **WindowFrame 青多層枠 + 上角丸**（§5e）— PRESIDENT 横断課題。XP らしさ大。
3. selection を #316AC5 に（§5a/5c）— 実機正準化。
4. button グラデ 3 stop / hover amber inset（§5b）— 既に高忠実、余力で。
5. font（Tahoma/Trebuchet MS asset）— 別判断（重い、Win95 と統合）。

> 数値は research 根拠。最終「実物っぽい」判定は user 実機確認 → 反復（第2波）。
