# Phase 3b 第1波 調査: macOS Big Sur (rebuild)

worker2 / 2026-05-20。**実装はまだ行わない**。本 doc は実物 web 調査 + 現 GUI_kit 定義との差分 + 改訂案。
視覚最終判定は user（worker/PRESIDENT は GUI 不可）。各値の出典は末尾に明記。

---

## 0. 重要な前置き（信頼度の区分）

調査の結果、**現 GUI_kit の Big Sur パレットは既にかなり忠実**で、Win95 以外「ゴミ」評価の主因は
パレット hex ではなく **(a) 質感の欠落（半透明 vibrancy / soft shadow / 信号機ボタンの縁取り・hover記号）と
(b) 角丸・サイズの細部** にあると判断する。下記は hex の微修正 + 質感ギャップの明文化が中心。

信頼度マーク: ◎=Apple公式/AppKit定数で確証 / ○=広く再現される定番値 / △=Apple非公開、コミュニティ計測・要user視覚確認

---

## 1. 実物の色実値（hex 一覧）

### 1-1. システムカラー（Apple AppKit / HIG、light mode）
| 用途 | hex | RGB | 信頼度 | 備考 |
|------|-----|-----|--------|------|
| accent / systemBlue | `#007AFF` | 0,122,255 | ◎ | macOS NSColor.systemBlue = 0,122,255。iOS は #0A84FF と別物 |
| systemGreen (macOS) | `#28CD41` | 40,205,65 | ◎ | **macOS の NSColor.systemGreen は #28CD41**。iOS systemGreen #34C759 (52,199,89) とは別 |
| systemGreen (iOS, トグル見た目) | `#34C759` | 52,199,89 | ○ | Big Sur の switch は iOS 風の見た目なので現行 #34C759 でも可（後述で論点化） |
| systemRed | `#FF3B30` | 255,59,48 | ◎ | error |
| systemOrange | `#FF9500` | 255,149,0 | ◎ | macOS systemOrange。warning。iOS dark の #FF9F0A とは別 |
| systemYellow | `#FFCC00` | 255,204,0 | ◎ | |
| systemGray | `#8E8E93` | 142,142,147 | ◎ | fg_muted / secondary 系の基準 |

### 1-2. ウィンドウ／サーフェス（Big Sur light, vibrancy 近似）
| 用途 | hex | 信頼度 | 備考 |
|------|-----|--------|------|
| window content bg | `#ECECEC`〜`#EAEAEA` | △ | Big Sur light の標準 window 背景グレー。現行 #ECECEC で妥当 |
| grouped/sidebar off-white | `#F5F5F7` | ○ | Apple 定番オフホワイト（apple.com / グループ背景）。現行 bg_secondary 一致 |
| card / surface | `#FFFFFF` | ◎ | |
| separator | `#D2D2D7`系 | ○ | hairline。Apple separatorColor 近似 |
| label (primary text) | `#1D1D1F`〜`#000000` | ○ | Apple のテキストはほぼ黒。apple.com 本文は #1D1D1F |
| secondaryLabel | base `#3C3C43` @60% | ◎ | Apple secondaryLabel = #3C3C43 を 60% alpha で重ねる動的色 |

### 1-3. 信号機ボタン（traffic lights）— **2系統あり、要注意**
| 状態 | close(赤) | min(黄) | zoom(緑) | 信頼度 |
|------|-----------|---------|----------|--------|
| **A: 鮮やか系**（現GUI_kit採用） | `#FF5F57` | `#FEBC2E` | `#28C840` | ○ 定番値（多数サイトで close #FF5F56/57, min #FFBD2E, max #27C93F の系統） |
| **B: 実描画近似**（縁取り付きSVG） fill | `#ED6A5F` | `#F6BE50` | `#61C555` | ○ lwouis SVG（実機は AA+透明で僅かに沈む） |
| B: 縁(border) | `#E24B41` | `#E1A73E` | `#2DAC2F` | ○ 各円の1px濃いめリング |
| B: hover時の記号色 | `#460804` | `#90591D` | `#2A6218` | ○ ×/−/+ は hover時のみ濃色で出る |
| inactive（非アクティブ窓） | fill `#DDDDDD` / border `#D1D0D2` | ○ | 全ボタン同一グレーになる |

**結論**: 現行の鮮やか系 hex は妥当（変える必要は薄い）。**不足は (i) 各円の1px濃い縁取り、(ii) hover時のみ×/−/+記号を出す、(iii) 非アクティブ窓で全部グレー化**。

---

## 2. font（名称・サイズ・太さ）

| 用途 | 実物 | 信頼度 |
|------|------|--------|
| システムフォント | **SF Pro**（San Francisco）。<20pt は SF Pro Text、≥20pt は SF Pro Display 自動切替 | ◎ |
| 標準コントロール / 本文 | **13pt**（NSFont.systemFontSize = 13） | ◎ |
| small system | 11pt | ◎ |
| label / mini | 10pt / 9pt | ○ |
| ウィンドウタイトル（Big Sur） | 13pt、**Big Sur で太く（semibold相当）+中央寄せ** | ○（pxlnv「bigger, bolder titles」） |
| 見出し large | 17〜22pt | ○ |

GUI_kit には SF Pro 実体は無く、現状 `LEGACY_JP_16_PROP` 共用。**SF 風アセットは別判断（重い）**。本波では font サイズ階調（13/11/17/22）の一致のみ提案。

---

## 3. 角丸 radius / border / bevel 構成

Big Sur は **3D bevel を使わない**（フラット + soft drop shadow + 半透明）。「層の色とオフセット」より **角丸と影が主**。

| 要素 | 実物 | 信頼度 | 現GUI_kit |
|------|------|--------|-----------|
| ウィンドウ角丸 | ≈ **10px**（Big Sur で大型化。Apple非公開、コミュニティ計測） | △ | border_radius_lg 10.0（妥当） |
| 標準 push button 角丸 | ≈ **5〜6px**（中サイズの角丸矩形。Apple非公開） | △ | button radius **8.0（やや丸すぎ→6推奨）** |
| popover / sheet 角丸 | ≈ 10〜12px | △ | — |
| text field 角丸 | ≈ 6px | ○ | input radius 6.0（妥当） |
| border | hairline 1px `#D2D2D7`、focus は accent 2px ring | ○ | 一致 |
| 影 | soft drop shadow（黒 ~8〜30% alpha、ぼかし大）。bevel無し | ○ | button shadow 1px alpha30（弱め） |
| 質感 | **vibrancy / 半透明ブラー**（sidebar・menu・titlebar） | ◎ | **未対応（最大の質感ギャップ）** |

---

## 4. title bar の見た目

- 高さ: 純タイトルバー ≈ 28px、ツールバー統合時はもっと高い（~52px）。中央寄せ・太字タイトル。
- 信号機ボタン: **左端**、横並び、直径 ≈ 12px（現行14は許容範囲）。close=赤/min=黄/zoom=緑。
- 背景: Big Sur light で `#ECECEC` 前後、**実物は下地が半透明 vibrancy**。グラデは基本なし（フラット）。
- hover で各ボタンに ×/−/+ 記号が出る。非アクティブ窓では信号機が全グレー。

現 `titlebar_theme_macos_big_sur`: bg #ECECEC / 中央寄せ・太字 ✓ / 左 ✓ / 信号機色 ✓ / 高さ28 ✓。
**不足**: ボタン円の縁取りなし・hover記号なし・非アクティブ未対応・vibrancy未対応。

---

## 5. 既存実装の出典 URL

- Apple HIG Color: https://developer.apple.com/design/human-interface-guidelines/color
- Apple Standard colors (AppKit/UIKit): https://developer.apple.com/documentation/uikit/standard-colors
- iOS/macOS dynamic colors（systemGreen の macOS=28CD41 / iOS=34C759 差を含む）: https://blog.verslu.is/xamarin/ios-macos-dark-mode-dynamic-colors-overview/
- Apple system colors 一覧: https://colorsift.com/reference/apple-system-colors / https://mar.codes/apple-colors
- 信号機ボタン hex（縁取り・hover記号・押下・inactive 付き SVG）: https://github.com/lwouis/macos-traffic-light-buttons-as-SVG
- 信号機 配色（鮮やか系）: https://www.schemecolor.com/close-minimise-and-maximise-buttons-in-mac.php
- Big Sur デザイン観察（角丸大型化・太いタイトル・padding 増・vibrancy）: https://pxlnv.com/blog/big-sur-design-observations/
- SF Pro 仕様（Text/Display 切替）: https://developer.apple.com/fonts/ / https://en.wikipedia.org/wiki/San_Francisco_(sans-serif_typeface)

---

## 6. 現 GUI_kit 定義との差分一覧

定義場所: `crates/hayate-kit/src/style/theme.rs` の `MACOS_BIG_SUR_THEME`、
`widget_theme_presets/{button,input,switch,titlebar,scroll_bar}.rs` の `*_macos_big_sur`。

| 項目 | 現 GUI_kit | 実物/推奨 | 差分判定 |
|------|-----------|-----------|----------|
| accent | #007AFF | #007AFF | ✓ 一致 |
| error | #FF3B30 | #FF3B30 | ✓ |
| success | #34C759 (iOS緑) | macOS は #28CD41 | △ 論点（switch見た目はiOS緑寄り） |
| warning | #FF9F0A | macOS systemOrange #FF9500 | △ 微修正候補 |
| bg_primary | #ECECEC | #ECECEC前後 | ✓ |
| bg_secondary | #F5F5F7 | #F5F5F7 | ✓ |
| border/separator | #D2D2D7 | #D2D2D7系 | ✓ |
| fg_primary | #1E1E20 | ほぼ黒(#1D1D1F〜#000) | ✓ 妥当 |
| button radius | **8.0** | 5〜6px | △ やや丸すぎ→6推奨 |
| button shadow | 1px alpha30 | soft大ぼかし | △ 弱い（質感） |
| 信号機色 | #FF5F57/#FEBC2E/#28C840 | 同(鮮やか系) | ✓ ただし縁取り・hover記号なし |
| switch track_on | #34C759 | systemGreen | △（#28CD41 か #34C759 か要確定） |
| vibrancy/半透明 | 無 | sidebar/menu/titlebar で必須 | ✗ **最大ギャップ** |
| 信号機 inactive | 無 | 非アクティブ窓で全グレー | ✗ |

---

## 7. 改訂案

### 7-1. palette 定数（`MACOS_BIG_SUR_THEME`）
- 基本は維持（既に高忠実）。微修正候補のみ:
  - `warning`: #FF9F0A → **#FF9500**（macOS systemOrange に統一）◎
  - `success`: 現状 #34C759 維持 or **#28CD41**（macOS systemGreen）— user 視覚確認で確定（△）
  - `font_size_md`: 13.0 維持 ✓ / `font_size_sm`: 11.0 維持 ✓（SF 階調と一致）

### 7-2. 主要 sub-theme
- `button_theme_macos_big_sur`: `.radius(8.0)` → **`.radius(6.0)`**（Big Sur 標準 push button へ）。
  影は soft 化（ぼかし大）が理想だが ButtonTheme の表現力に依存（要確認）。bg/hover/pressed の #007AFF 系は維持。
- `input_theme_macos_big_sur`: radius 6.0 / border #D2D2D7 / focus #007AFF 維持 ✓（変更不要）。
- `switch_theme_macos_big_sur`: pill・31px高・track_on 緑 維持。緑値は palette success と揃える。

### 7-3. titlebar（`titlebar_theme_macos_big_sur`）
- 色・配置・中央太字 は維持 ✓。
- **要 framework 拡張（PRESIDENT 横断課題側）**: (i) 信号機円に1px濃い縁取り、(ii) hover時 ×/−/+ 記号、
  (iii) 非アクティブ窓で全グレー化、(iv) vibrancy/半透明下地。TitleBarTheme に表現手段が無ければ別途設計が必要。

### 7-4. 質感ギャップ（本波の最重要 finding）
Big Sur の「実物っぽさ」は hex でなく **半透明 vibrancy + soft shadow + 信号機の縁取り/hover記号** に宿る。
パレット改訂だけでは user 評価は上がりにくい。**framework 側の半透明・soft shadow 対応可否を PRESIDENT 判断事項として上申**する。
