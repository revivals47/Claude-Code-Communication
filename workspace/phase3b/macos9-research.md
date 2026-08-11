# Phase 3b 第1波 調査: Mac OS 9 Platinum (rebuild)

worker2 / 2026-05-20。**実装はまだ行わない**。本 doc は実物 web 調査 + 現 GUI_kit 定義との差分 + 改訂案。
視覚最終判定は user（worker/PRESIDENT は GUI 不可）。各値の出典は末尾に明記。

---

## 0. 重要な前置き（信頼度の区分 + 主因仮説）

Mac OS 8.5〜9.2.2 の標準 appearance = **Platinum**（Appearance Manager に組込み、テーマ着脱式ではない）。
特徴は **(a) グレー基調の 3D 立体ベベル（pillowy bezel）、(b) タイトルバーの横縞 racing stripes、
(c) close box 左／collapse・zoom 右 の分割配置**。

現 GUI_kit の **base palette（グレー値）は実物とほぼ一致**しているが、
**`button_theme_mac_classic` が Platinum ではなく System 7 風の「フラット黒枠＋押下で白黒反転」になっており別物**。
これが Mac OS 9 が「ゴミ品質」評価の主因と判断する。Platinum の肝 = **3D ベベル**。

信頼度: ◎=Apple公式 HIG / ○=pixel-perfect 再現実装の値 / △=要 user 視覚確認・OS 側で可変

---

## 1. 実物の色実値（hex 一覧）

出典 = mat-sz/platinum.css（"pixel perfect recreation of MacOS 9's Platinum UI"）の `src/index.scss` 実値。

### 1-1. グレーランプ（Platinum chrome の核）
| 用途 | hex | RGB | 信頼度 |
|------|-----|-----|--------|
| window body / surface | `#DEDEDE` | 222,222,222 | ○ |
| window frame / 構造グレー | `#CECECE` | 206,206,206 | ○ |
| highlight（最明・白）| `#FFFFFF` | 255,255,255 | ◎ |
| 中間シャドウ（mid grey）| `#9C9C9C` | 156,156,156 | ○ |
| ベベル外シャドウ | `#8C8C8C` | 140,140,140 | ○ |
| 構造の黒枠 | `#000000` / 濃 `#212121` | | ○ |
| タイトル縞 暗線 | `#737373` | 115,115,115 | ○ |

### 1-2. text / selection
| 用途 | hex | 信頼度 | 備考 |
|------|-----|--------|------|
| primary text | `#000000` | ◎ | Platinum テキストは黒 |
| disabled / muted | `#808080`前後 | ○ | グレーアウト |
| selection / highlight（既定 Appearance: Blue）| 既定青（OS 側で可変）| △ | **既定ハイライト色は Appearance コントロールパネルで変更可。既定=青系**。正確 hex は非公開→現行 #3366CC を暫定採用、user 視覚確認で確定 |

### 1-3. button 3D ベベル（Platinum の核 — 現行が最も外している箇所）
出典 platinum.css のボタン定義（`box-shadow` 多層 + 135° グラデ face）:
- **face**: `linear-gradient(135deg, #9C9C9C → #FFFFFF)`（左下暗→右上明のグレーグラデ）
- **border**: `#212121`（1px）
- **bevel（box-shadow 多層）**:
  - 外 TL highlight: `#8C8C8C`（-1px,-1px）
  - 外 BR: `#FFFFFF`（1px,1px）
  - 内 TL light: `#CECECE`（inset）
  - 内 BR shadow: `#8C8C8C`（inset）
- 押下時: ベベルが沈む（**白黒反転ではない**。テキストは黒のまま）

---

## 2. font（名称・サイズ・太さ）

| 用途 | 実物 | 信頼度 |
|------|------|--------|
| システムフォント | **Charcoal**（Mac OS 8/9 で Chicago を置換、メニュー・ウィンドウタイトル）| ◎ |
| small system font | **Geneva**（小ポイント用）| ◎ |
| 標準サイズ | システム 12pt 前後 / small 9〜10pt（Geneva 9 が定番）| ○ |
| タイトルバー文字 | Charcoal、太字寄り、中央配置（縞に挟まれる）。再現実装で 11.5px | ○ |

GUI_kit に Charcoal/Geneva 実体は無し（現状 `LEGACY_JP_16_PROP`）。font サイズ階調（md12/sm10）は既に妥当。
ビットマップ Charcoal/Geneva アセットは重いので**別判断**（本波では論点化のみ）。

---

## 3. 角丸 radius / border / bevel 構成

| 要素 | 実物 Platinum | 信頼度 | 現 GUI_kit |
|------|---------------|--------|-----------|
| button 角丸 | 小（角丸矩形、~2〜4px）| ○ | radius 8.0（**丸すぎ→3〜4推奨**） |
| button bevel | 上記 1-3 の多層グレーベベル（**raised**）| ○ | **無（フラット黒枠+反転）→要全面差替** |
| window frame | 3D ベベル付きグレー枠（raised）| ○ | border 1px 黒（フラット）→ベベル化 |
| input | 白地・1px 黒枠・sunken 気味 | ○ | border 1px 黒 radius2（概ね可、sunken ベベルだとなお良） |
| scrollbar | 3D ベベル thumb + 端に矢印 cap、track グレー | ○ | arrow_caps✓ だが **thumb_bevel/cap_bevel None→ベベル付与** |
| 全体 | 「appearance may change, layout does not」= 立体感が identity | ◎(HIG) | — |

---

## 4. title bar の見た目

- **横縞 racing stripes**: アクティブ窓のタイトルバーは、中央のタイトル文字の左右に**横縞**（白 `#FFFFFF` と暗グレー `#737373` の交互線）。
  非アクティブ窓は縞なし・全体グレーアウト。
- **窓コントロール配置**: **close box = 左上**、**collapse(windowshade) box + zoom box = 右上**（**左右分割**）。
  ※ 現 framework の `ButtonSide` は片側のみ → **分割配置は framework 拡張が必要**（PRESIDENT 横断課題候補）。
- タイトル: 中央寄せ・Charcoal・やや太字。
- 下地: `#CECECE`〜`#DEDEDE` グレー、3D ベベル枠。

現 `titlebar_theme_mac_os9`: bg #CCCCCC / 中央寄せ✓ / stripe_color Some(#B4B4B4)（**単色・明るすぎ**）/ close等すべて Left（**右分割未対応**）/ button_bevel false。
**不足**: 縞が単色（白+#737373 の二色交互が正）・左右分割なし・アクティブ/非アクティブ区別なし・ベベルなし。

---

## 5. 既存実装の出典 URL

- mat-sz/platinum.css（pixel perfect MacOS 9 Platinum 再現、グレー値・ベベル・縞の実値）: https://github.com/mat-sz/platinum.css （raw: src/index.scss）
- Inside Macintosh "Platinum Appearance"（Apple HIG OS8、Charcoal・platinum theme 定義・layout 原則）: https://dev.os9.ca/techpubs/mac/HIGOS8Guide/thig-8.html
- Wikipedia "Platinum (theme)"（Appearance Manager 組込・Charcoal・グレー多用）: https://en.wikipedia.org/wiki/Platinum_(theme)
- retpolanne/platinum（Mac OS 8.1 UI 再現 CSS/JS）: https://github.com/retpolanne/platinum
- robbiebyrd/classicy（Mac OS 8 UI コンポーネント React 再現）: https://github.com/robbiebyrd/classicy
- JohnDDuncanIII/platinum（Mac OS 9 テーマ for OS X、ボタン各状態スクショ）: https://github.com/JohnDDuncanIII/platinum
- Appearance control panel（既定ハイライト/フォント可変）: https://apple.fandom.com/wiki/Appearance_control_panel
- Mac フォント解説（Charcoal/Geneva）: https://whitefiles.org/mac/pgs/t03.htm

---

## 6. 現 GUI_kit 定義との差分一覧

定義場所: `theme.rs` の `MACOS9_THEME`、`widget_theme_presets/{button,titlebar,scroll_bar,input,switch}.rs` の `*_mac_os9` / `*_mac_classic`。

| 項目 | 現 GUI_kit | 実物/推奨 | 判定 |
|------|-----------|-----------|------|
| bg_primary | #DDDDDD | #DEDEDE | ✓ ほぼ一致 |
| bg_tertiary | #CCCCCC | #CECECE | ✓ |
| bg_surface | #FFFFFF | #FFFFFF | ✓ |
| border | #888888 | #8C8C8C（ベベル shadow）| ✓ 近似 |
| fg_primary | #000000 | #000000 | ✓ |
| accent/selection | #3366CC | 既定青（可変）| △ 暫定可・要user確認 |
| font md/sm | 12/10 | 12 / 9-10 | ✓ |
| **button** | フラット #DDD・1.5px黒枠・押下で白黒反転 | **グレーグラデ face + 多層 3D ベベル・押下で沈む** | ✗ **最大ギャップ・全面差替** |
| button radius | 8.0 | 2〜4px | △ 丸すぎ |
| titlebar 縞 | 単色 #B4B4B4 | 白#FFF + 暗#737373 の二色交互 | ✗ |
| titlebar 配置 | 全 Left | close左 / collapse・zoom右（分割）| ✗ framework依存 |
| titlebar active/inactive | 区別なし | 縞の有無で区別 | ✗ framework依存 |
| scrollbar bevel | None | 3D ベベル thumb + cap | ✗ |
| window frame | フラット黒1px | 3D ベベルグレー枠 | △ |

---

## 7. 改訂案

### 7-1. palette 定数（`MACOS9_THEME`）
- グレー値を再現実装に厳密化（微調整）:
  - `bg_primary` #DDDDDD → **#DEDEDE** ○
  - `bg_tertiary` #CCCCCC → **#CECECE** ○
  - `border` #888888 → **#8C8C8C** ○
  - `fg_muted` #808080 維持 / `fg_primary` #000000 維持 ✓
  - `accent` #3366CC: 暫定維持（既定ハイライトは OS 可変のため）。user 視覚確認で確定（△）
  - font_size md12/sm10 維持 ✓

### 7-2. 主要 sub-theme（**ここが本命**）
- **`button_theme_mac_classic` を Platinum 3D ベベルへ全面差替**（現行の黒枠反転を廃止）。win95 の `.bevel()` 機構を流用し、Platinum グレーで:
  - face: グレーグラデ（#9C9C9C→#FFFFFF 相当。ButtonTheme の `.gradient()` で近似）
  - bevel 4層: 外TL `#FFFFFF` / 外BR `#8C8C8C` / 内TL `#CECECE` / 内BR `#9C9C9C`（raised）
  - border 1px `#212121`、radius **3.0**、押下で `.press_text_offset` 的に沈む（白黒反転しない、fg は黒維持）
  - default button: 外周に太め黒リング（現 `mac_classic_default` の 3px 枠を踏襲、ただし反転しない）
- `input_theme_mac_os9`: 現状（白地・黒1px・radius2）概ね可。可能なら sunken ベベル付与で実物に近接。
- `scroll_bar_theme_mac_os9`: `thumb_bevel` / `cap_bevel` を **Some(3D グレーベベル)** に。thumb #DDDDDD / track #CECECE。

### 7-3. titlebar（`titlebar_theme_mac_os9`）
- 縞を **二色交互（#FFFFFF + #737373）** に。下地 #CECECE。中央太字 ✓ 維持。
- **要 framework 拡張（PRESIDENT 横断課題側）**: (i) close 左 / collapse・zoom 右 の**左右分割配置**（現 ButtonSide は片側のみ）、
  (ii) **アクティブ/非アクティブで縞の有無**を切替、(iii) window frame の 3D ベベル枠。

### 7-4. 最重要 finding（本波の核）
Mac OS 9 の「実物っぽさ」は **3D ベベルの再現**に集約される。現 `button_theme_mac_classic` は Platinum と別物（System 7 風）なので、
**ベベル全面差替が第2波の最優先**。グレー値（palette）は既にほぼ正しい。
title bar の左右分割配置・active/inactive 縞は framework 機能拡張が要るため PRESIDENT 判断事項として上申する。
