# Windows 10 (Fluent) — 実物調査 + GUI_kit 差分 + 改訂案

担当: worker1 / Phase 3b 第1波（調査のみ・実装なし・cargo なし）/ 2026-05-20

> **制約遵守**: 記憶ベース実装禁止。本 doc は (a) Microsoft 公式 (WindowColor unattend doc / Fluent 2 Design / Buttons doc)、(b) Windows 8/10 実機 system color 一覧 gist、(c) Fluent Design palette gist の一次資料に基づく。視覚最終判定は user（AI/PRESIDENT は GUI 不可視）。

---

## 0. 出典 URL（一次資料）

| 種別 | 出典 | URL |
|------|------|-----|
| 公式 accent | Microsoft Learn: WindowColor (unattend) — 既定 accent | https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-themes-windowcolor |
| 公式 design | Fluent 2 Design System: Color | https://fluent2.microsoft.design/color |
| 公式 control | Microsoft Learn: Buttons (Windows apps) | https://learn.microsoft.com/en-us/windows/apps/design/controls/buttons |
| 実機 system color | Windows System Colours (by OS) gist | https://gist.github.com/zaxbux/64b5a88e2e390fb8f8d24eb1736f71e0 |
| Fluent palette | Fluent Design Colors gist (BowenYin) | https://gist.github.com/BowenYin/a9ed31198489319800d56f309f6046e2 |
| 既定 face 確認 | tenforums: Change Button Face Color in Win10 (#F0F0F0) | https://www.tenforums.com/tutorials/133928-change-button-face-color-windows-10-a.html |

注: Win10 は「フラット + accent」設計で OS スキンというより design system。タイトルバーは DWM が既定で**白**を描画し、レガシー system color ActiveCaption (#99B4D1) は無視される（accent-on-titlebar ON 時のみ accent 色）。native push button（dialog/Explorer）の色は UxTheme 由来の確立値。

---

## 1. 実物の色実値（hex 一覧）

### 1a. 実機 system color（Win8/10 classic palette、gist 由来）

| 役割 | system color 名 | hex | RGB |
|------|----------------|-----|-----|
| surface / 3D face | Control (ButtonFace) | **#F0F0F0** | 240,240,240 |
| button highlight | ButtonHighlight | **#FFFFFF** | 255,255,255 |
| button shadow | ButtonShadow (ControlDark) | **#A0A0A0** | 160,160,160 |
| window（本体面） | Window | **#FFFFFF** | 255,255,255 |
| window text | WindowText | **#000000** | 0,0,0 |
| gray text（disabled） | GrayText | **#6D6D6D** | 109,109,109 |
| selection（classic） | Highlight | **#3399FF** | 51,153,255 |
| selection text | HighlightText | **#FFFFFF** | 255,255,255 |
| hot track（link） | HotTrack | **#0066CC** | 0,102,204 |
| title bar active（legacy値・DWMは白上書き） | ActiveCaption | #99B4D1 | 153,180,209 |

### 1b. accent / Fluent

| 役割 | 値 | 出典 |
|------|-----|------|
| **既定 accent（OS）** | **#0078D7**（0,120,215） | Microsoft WindowColor doc「The default color is a shade of blue (0xff0078d7)」 |
| Fluent design accent base | **#0078D4**（0,120,212） | Fluent 2 Design / Fluent palette gist |
| close button red（caption） | **#E81123**（232,17,35） | Win10 caption close hover の確立値 |

→ #0078D7（OS既定）と #0078D4（Fluent）の差は青 3（215 vs 212）で**視覚上ほぼ同一**。GUI_kit は #0078D4 採用＝許容。

### 1c. native push button（UxTheme 確立値 / GUI_kit と一致）

| state | background | border |
|-------|-----------|--------|
| rest | **#E1E1E1**（native dialog）/ 一部 UWP は白 | **#ADADAD** |
| hover (hot) | **#E5F1FB** | **#0078D4** |
| pressed | **#CCE4F7** | **#005499** |
| disabled | **#CCCCCC** | **#BFBFBF** / text #A0A0A0 |

→ hover #E5F1FB / pressed #CCE4F7 / border #0078D4 は GUI_kit が既に採用済（native 値と一致）。

---

## 2. font（名称・サイズ・太さ）

| 用途 | 実機 Win10 | 備考 |
|------|-----------|------|
| UI 全般 | **Segoe UI 9pt（≈12px）regular** | Win10 標準 UI フォント |
| タイトルバー caption | **Segoe UI 9pt regular（bold でない）** | Win95/XP と違い caption も非太字・左寄せ |
| 本文/dialog | Segoe UI 9pt（12px） | — |

- GUI_kit には Segoe UI asset 無し、現状 `LEGACY_JP_16_PROP` 流用（XP/Win95 と共通課題）。font asset 要否は別判断。
- 数値整合: GUI_kit title_size=12 / title_bold=false は **正しい**（Win10 caption は非太字）。本文は Segoe 9pt=12px のため font_size_md を 12〜13 で許容。

---

## 3. 角丸 radius / border / bevel 構成

Win10 は **bevel（3D 立体縁）を廃し「フラット + 1px solid border + accent」** が原則。Win95/XP のような raised/sunken 多層 bevel は無い。

### 3a. ボタン（native push button）
- border: **1px solid #ADADAD**（rest）→ hover で **#0078D4**、pressed で **#005499**
- **border-radius: 2px**（ほぼ直角、わずかな角丸）
- bevel なし（フラット）。rest bg は native dialog で **#E1E1E1**（淡灰）、hover **#E5F1FB**、pressed **#CCE4F7**

### 3b. 入力欄（text box）
- border: **1px solid #ABABAB（≒#A0A0A0）**、focus で accent **#0078D7**（2px 相当の濃い縁）
- border-radius: 2px、フラット白地、selection は accent 半透明 or classic #3399FF

### 3c. ウィンドウ枠 / タイトルバー
- **window border: 1px**。active = **accent 色**（#0078D7、accent-on-borders 時）/ 既定灰 #AAAAAA 系、inactive = 灰
- **title bar: 既定で白 #FFFFFF**（DWM 描画）、文字黒 active / 灰 inactive、**非太字・左寄せ**、高さ ~30px
- caption button: **46px 幅 × ~30px 高**、フラット square、hover で薄灰オーバーレイ、**close hover = 赤 #E81123 + 白 ×**
- min/max symbol: 細線（─ / □）、close: ×

---

## 4. 現 GUI_kit 定義との差分一覧

### 4a. palette（`theme.rs` WIN10_THEME）

| field | 現 GUI_kit | 実物正準 | 判定 |
|-------|-----------|---------|------|
| bg_primary | #F3F3F3 | Control #F0F0F0 | ⚠ 微差。#F0F0F0 が canonical（#F3F3F3 は Win11 Mica寄り） |
| bg_surface | #FFFFFF | Window #FFFFFF | ✅ 一致 |
| accent | #0078D4 | OS既定 #0078D7 / Fluent #0078D4 | ✅ 許容（差は青3、視覚同一） |
| accent_hover | #1094EA | accent lighten | △ 妥当（lighter） |
| accent_pressed | #0060A8 | accent darken（≈Dark1） | △ 妥当（darker） |
| fg_primary | #000000 | WindowText #000000 | ✅ |
| fg_secondary | #282828 | — | ◯ |
| fg_muted | #767676 | GrayText #6D6D6D | △ 近い。#6D6D6D へ寄せ可 |
| border | #ADADAD | button border #ADADAD | ✅ 一致 |
| separator | #E1E1E1 | — | ◯ |
| selection_overlay | rgba(#0078D4,80) | classic Highlight #3399FF / accent系 | △ Fluent は accent 半透明で妥当。classic #3399FF 選択肢あり |
| error | #E81123 | close red #E81123 | ✅ 一致 |
| border_radius | 2.0 | button/input 2px | ✅ 一致 |
| border_radius_sm/lg | 0.0 / 4.0 | フラット基調 | ◯ |

### 4b. button（`button.rs` button_theme_win10）

| 項目 | 現 GUI_kit | 実物正準 | 判定 |
|------|-----------|---------|------|
| bg (rest) | **#FFFFFF（白）** | native dialog **#E1E1E1（淡灰）** | ⚠ 白は UWP寄り。native Win10 dialog ボタンは淡灰。fidelity 重視なら #E1E1E1 |
| bg_hover | #E5F1FB | #E5F1FB | ✅ 一致 |
| bg_pressed | #CCE4F7 | #CCE4F7 | ✅ 一致 |
| border | 1px #ADADAD | #ADADAD | ✅ 一致 |
| border_hover | #0078D4 | #0078D4 | ✅ 一致 |
| (pressed border) | 未設定 | #005499 | ⚠ pressed 時 border #005499 が欲しい（framework が pressed border を持てば） |
| radius | 2.0 | 2px | ✅ 一致 |
| fg | #000000 | #000000 | ✅ |

button は **hover/pressed/border が native と一致＝高忠実**。残差は rest bg（白 vs 淡灰）と pressed border のみ。

### 4c. input（`input.rs` input_theme_win10）

| 項目 | 現 GUI_kit | 実物正準 | 判定 |
|------|-----------|---------|------|
| bg | #FFFFFF | #FFFFFF | ✅ |
| border_color | #767676（118） | native ~#ABABAB/#A0A0A0 | △ Win10 textbox border は灰。#767676 はやや濃いが許容（focus 強調用）|
| border_focused | #0078D4 | accent #0078D7 | ✅ 許容 |
| selection_color | rgba(#0078D4,80) | classic #3399FF / accent | △ 妥当 |
| cursor_color | #0078D4 | accent | ◯（黒も可、native は黒caret） |
| radius | 2.0 | 2px | ✅ 一致 |

### 4d. titlebar（`titlebar.rs` titlebar_theme_win10）

| 項目 | 現 GUI_kit | 実物正準 | 判定 |
|------|-----------|---------|------|
| bg | #FFFFFF | 既定 白 #FFFFFF（DWM） | ✅ 一致 |
| title_color | #000000 | active 黒 | ✅ |
| title_bold | false | 非太字 | ✅ 一致（正しい） |
| title_centered | false | 左寄せ | ✅ 一致 |
| height | 30.0 | ~30px | ✅ 一致 |
| border_color | #E1E1E1 | active=accent / 既定灰 | △ active 時 accent 縁の選択肢（accent-on-borders 再現）|
| button_width/height | 46 / 30 | 46×30 | ✅ 一致 |
| close_hover_bg | #E81123 | #E81123 | ✅ 一致 |
| max/min hover | #E5E5E5 | 薄灰オーバーレイ | ✅ 妥当 |
| symbols | × □ ─ | × □ ─ | ✅ 一致 |

→ **Win10 titlebar は既にほぼ完璧**。

---

## 5. 改訂案

### 5a. palette `WIN10_THEME`（theme.rs）改訂値

```rust
bg_primary: Color::rgb(0xF0, 0xF0, 0xF0),  // Control 正準（現 #F3F3F3、Win11寄りを是正）
fg_muted:   Color::rgb(0x6D, 0x6D, 0x6D),  // GrayText 正準（現 #767676）
// accent #0078D4 据え置き（#0078D7 との差は視覚同一、許容）
// bg_surface #FFFFFF / border #ADADAD / error #E81123 / radius 2.0 据え置き ✅
// selection: Fluent 現状(accent半透明)維持 or classic #3399FF 採用は user 視覚判定で
```

### 5b. button `button_theme_win10` 改訂（fidelity 重視）

```rust
.bg(Color::rgb(0xE1, 0xE1, 0xE1))   // native dialog 淡灰（現 白）※フラットUWP路線なら白維持も可
.bg_hover(Color::rgb(229,241,251))   // #E5F1FB 据え置き ✅
.bg_pressed(Color::rgb(204,228,247)) // #CCE4F7 据え置き ✅
.border(1.0, Color::rgb(173,173,173))// #ADADAD 据え置き ✅
.border_hover(Color::rgb(0,120,212)) // #0078D4 据え置き ✅
// 追加希望: pressed 時 border #005499（framework が pressed border を持てば）
.radius(2.0)                          // 据え置き ✅
```
> **論点（user 判定）**: rest bg を「#E1E1E1 淡灰（native dialog 忠実）」にするか「白（modern UWP）」維持か。実物っぽさ＝淡灰、モダン感＝白。

### 5c. input `input_theme_win10` 改訂

```rust
// 概ね正準。border をやや淡く native 寄せする選択肢:
.border_color(Color::rgb(0xAB, 0xAB, 0xAB))  // native textbox 灰（現 #767676、好みで）
// bg #FFFFFF / border_focused #0078D4 / radius 2.0 据え置き ✅
```

### 5d. titlebar `titlebar_theme_win10` 改訂（**最小**）

```rust
// 既にほぼ完璧。唯一の任意改善:
// active 時に accent 縁を出すなら border_color を accent に（accent-on-borders 再現）。
// 既定 Win10 は白バー＋細灰縁なので現状維持でも十分忠実。
// → 据え置き推奨。
```

---

## 6. 改訂の優先度（user 視覚確認向け）

1. **button rest bg の方針決定**（§5b）— 白 vs 淡灰 #E1E1E1。Win10 らしさの分岐点。user 判定必須。
2. **bg_primary #F0F0F0 へ是正**（§5a）— Win11 寄りの #F3F3F3 を Win10 canonical に。
3. pressed border #005499 追加（§5b）— framework 対応可なら。
4. fg_muted #6D6D6D / selection classic #3399FF（§5a）— 実機正準寄せ、余力で。
5. font（Segoe UI asset）— 別判断（XP/Win95 と統合）。

> **総評**: Win10 は GUI_kit が**既に高忠実**（titlebar ほぼ完璧、button の hover/pressed/border は native 一致）。XP のような大きなギャップは無く、調整は微差中心。数値は research 根拠、最終「実物っぽい」判定は user 実機確認 → 反復（第2波）。
