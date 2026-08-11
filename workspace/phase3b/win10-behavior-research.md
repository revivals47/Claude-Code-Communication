# Phase 3b 第3波 調査 — Windows 10 widget state 挙動の仕様 + GUI_kit 差分 (worker3)

作成: 2026-05-20 / 担当: worker3 / 状態: 研究のみ（実装なし・cargo 未起動）
関連: 第3波ミッション (workspace/phase3b-mission.md L112-)、視覚最終判定は user (gallery)

## 0. 結論サマリ

Win10 button の **rest/hover/press の塗り色は GUI_kit で既に正しい**（bg白 / hover #E5F1FB / press #CCE4F7 / border #ADADAD / hover border #0078D4 = button_theme_win10 と一致）。**真のギャップは挙動 state の 2 点:**

1. **【最大】disabled に視覚がない**（modern テーマ）。`ButtonTheme` に disabled 用フィールドが無く、paint の disabled 分岐は Win95 etched 専用。Win10 の disabled（bg #CCCCCC + text #A0A0A0）は**表現不能**で、無効ボタンが通常と同じ見た目になる。
2. **focus ring の色が `HAYATE_DARK.accent`（cyan #55CCFF）ハードコード**で、Win10 の accent #0078D4 にならない。`ButtonTheme` に focus 色フィールドが無い。

副次: pressed 時に border が暗化しない（#0078D4 のまま）。rest 背景が白(UWP) か淡灰(#E1E1E1, classic dialog) かは user 判断保留事項（ミッション既出）。

実装は user の gallery 評価後。本 doc は仕様 + 差分 + 改訂提案のみ。

---

## 1. Windows 10 button state 仕様（出典付き）

Win10 の button は WinUI/Fluent で **4 state**（Normal / PointerOver / Pressed / Disabled）+ keyboard focus 視覚を持つ（出典 §5-①②）。state ごとのテーマリソース（`ButtonBackgroundPointerOver` / `ButtonBackgroundPressed` / `ButtonForegroundDisabled` / `ButtonBorderBrushDisabled` 等）で色が定義される（出典 §5-③）。

実 OS の common-control / system button（Win10 標準ダイアログボタン）の state 別実値:

| state | background | border | text | 備考 |
|---|---|---|---|---|
| rest (Normal) | #FFFFFF（UWP）/ 淡灰 #E1E1E1（classic dialog） | #ADADAD (173,173,173) 1px | #000000 | rest 背景は UWP白/classic淡灰の二系統（user 判断事項） |
| hover (PointerOver) | **#E5F1FB** (229,241,251) | **#0078D4** (0,120,212) accent | #000000 | hover で accent border + 淡青塗り |
| pressed | **#CCE4F7** (204,228,247) | #005499〜#0078D4（暗め accent） | #000000 | press でさらに濃い青塗り |
| disabled | **#CCCCCC** (204,204,204) | #BFBFBF 系 | **#A0A0A0** (160,160,160) | 塗り・文字とも灰、操作不可 |
| focus (keyboard) | (state 色は維持) | + **accent 2px** focus 矩形/枠 | — | Tab focus 時に accent #0078D4 の 2px インジケータ |

挙動 (出典 §5-①):
- click は既定で **Release 時**発火（ClickMode=Release）。keyboard は Enter / Space で発火。
- press 中は pressed 塗り、pointer が出ると hover 解除。
- hover/press の色遷移は subtle（短い fade）、Win95 のようなベベル反転は無い（flat + 1px border + accent）。

注: 正確な hex（#E5F1FB / #CCE4F7 / #ADADAD / #0078D4 / disabled #CCCCCC・#A0A0A0）は Microsoft の単一 doc ページに表形式では載らないが、Win10 common-control system button の周知値であり、**GUI_kit の現 button_theme_win10 が既にこの値を採用している**（§2、内部 cross-check）。WinUI の state リソース構造とアクセント focus は §5 出典で裏取り。

---

## 2. 現 GUI_kit の state 実装（button.rs + button_theme_win10）

### 2-A. state モデル
- `ButtonState` enum (button.rs:17) = **Normal / Hovered / Pressed の 3 値のみ**。Disabled / Focused は enum でなく**別 bool フィールド**（`disabled` button.rs:69、`focused` :66）。
- アニメ: `bg_value` (0.0=normal / 1.0=hover / 2.0=pressed) を `bg_tween` で補間。`update(dt)` (button.rs:651) で tick。event で `animate_to()` を呼ぶ（hover→1.0、press→2.0、hover_duration ベース）。
- disabled は `disabled()` builder / `set_enabled()` で設定。event 時 `handle_button_event` は disabled なら即 `Ignored`（state 変化なし）。

### 2-B. button_theme_win10（widget_theme_presets/button.rs:151）実値
| field | 値 | spec 一致 |
|---|---|---|
| bg | #FFFFFF | rest 白（UWP系）✓ |
| bg_hover | #E5F1FB (229,241,251) | ✓ |
| bg_pressed | #CCE4F7 (204,228,247) | ✓ |
| fg / fg_hover / fg_pressed | #000000 | ✓ |
| border_width / border_color | 1.0 / #ADADAD (173,173,173) | ✓ |
| border_hover_color | #0078D4 (0,120,212) | ✓ hover accent border |
| border_radius | 2.0 | WinUI は 4、classic は 0、中間 2（許容） |
| hover_duration | 0.08 | subtle fade ✓ |
| bevel_* | None | flat（Win95 でない）✓ |
| **disabled 用フィールド** | **無し** | ✗（§3-1） |
| **focus 色フィールド** | **無し** | ✗（§3-2） |

`ButtonTheme` struct (widget_themes/button.rs) の全フィールドを確認: bg/bg_hover/bg_pressed, fg/fg_hover/fg_pressed, border_*, radius, shadow, glow, gradient, shine, pill, press_depth/scale, hover_duration, bevel_*, press_text_offset, no_hover, padding, font_size, bitmap_text。**disabled_bg / disabled_fg / disabled_border / focus_color に相当するフィールドは存在しない。**

### 2-C. paint の state 別挙動（button.rs:290-622）
- **bg**: `v<=1` で `bg.lerp(bg_hover, v)`、`v>1` で `bg_hover.lerp(bg_pressed, v-1)`。→ hover/press 塗りは spec どおり補間。✓
- **border**: `border_color.lerp(border_hover_color, v.min(1))`。focus 時 `border_width+1` + alpha boost。→ hover で #ADADAD→#0078D4 補間 ✓。**press では v.min(1)=1 のため border は #0078D4 のまま（暗化しない）**。
- **focus ring** (button.rs:519-546): bevel なし(modern) 分岐は **`HAYATE_DARK.accent`（cyan #55CCFF）ハードコード**の 2px outer ring（offset −2、radius+2）を描画。さらに末尾 (button.rs:618-620) で `draw_focus_ring(active_theme)` も描画（2 重）。
- **disabled** (button.rs:578): `if self.disabled && th.bevel_outer_light.is_some()` ＝ **Win95(bevel あり) のみ** etched 描画。**modern(bevel None=Win10) は disabled でも fg/bg を一切変えない** → 無効ボタンが通常表示。

---

## 3. ギャップ一覧（spec vs 現実装）

| # | gap | 重大度 | 詳細 |
|---|---|---|---|
| 1 | **disabled 視覚なし(modern)** | 高 | `ButtonTheme` に disabled 色フィールド無 + paint disabled 分岐が Win95 etched 専用。Win10 disabled(bg #CCCCCC + text #A0A0A0) 表現不能。無効ボタンが通常と同一見た目 + click は無視（挙動だけ無効、見た目は有効のまま）= UX 上明確な欠陥。 |
| 2 | **focus ring 色が cyan ハードコード** | 中-高 | modern focus ring が `HAYATE_DARK.accent`(#55CCFF cyan)。Win10 は #0078D4。テーマ accent を無視。`ButtonTheme` に focus 色フィールド無し。加えて focus 描画が 2 経路(inner ring + draw_focus_ring)で二重。 |
| 3 | state モデルが 3 値 + bool 散在 | 低-中 | `ButtonState` に Disabled/Focused が無く bool 併用。per-state 色は bg/fg/border の hover/pressed 3 つ組のみで、disabled/focus 用の色を表現する場所が構造的に無い(=#1/#2 の根因)。 |
| 4 | pressed border 暗化なし | 低 | press 時 border が #0078D4 のまま。spec は press で僅かに暗い accent。視覚差小。 |
| 5 | rest 背景 白 vs 淡灰 | 保留 | UWP=白、classic dialog=#E1E1E1。どちらを「Win10 らしい」とするかは user 判断(ミッション既出)。現状は白。 |

---

## 4. 改訂提案（実装は user 評価後。提案のみ）

### 4-A. disabled 表現（gap #1、最優先）
- `ButtonTheme` に `disabled_bg` / `disabled_fg` / `disabled_border`（Option、None=現状維持）を追加。
- paint で `self.disabled` 時、bevel 有無に依らず disabled 色を適用する分岐を追加（現 Win95 etched 分岐はそのまま、modern は disabled_bg/disabled_fg で塗る）。
- button_theme_win10 に disabled_bg #CCCCCC / disabled_fg #A0A0A0 / disabled_border #BFBFBF を設定。
- 他テーマ(win95 は etched 既存、xp/macos は別 worker 調査値)も同枠組みで設定可能に。

### 4-B. focus 色のテーマ化（gap #2）
- `ButtonTheme` に `focus_color`（Option、None なら従来の active_theme.accent / フォールバック）を追加、または modern focus ring を `HAYATE_DARK.accent` 固定でなく注入テーマ accent（active_theme().accent）から取る。
- button_theme_win10 は focus #0078D4。focus 描画の二重(inner + draw_focus_ring)は整理（どちらか一本化）を検討。

### 4-C. state モデル（gap #3、任意）
- 上記 4-A/4-B のフィールド追加で実用上は足りる。enum に Disabled/Focused を足す抜本案は影響範囲大のため、フィールド追加(局所)を優先推奨。

### 注意（プラットフォーム原則整合）
- disabled/focus 色は GUI_kit(platform) 側の `ButtonTheme` に持たせ、consumer 側で個別実装しない（feedback_platform_principle）。
- 全ての見た目最終判定は user の gallery 確認（focus 色/disabled 濃度/press 暗化の要否）。本 doc は research 根拠の提案に留める。

---

## 5. 出典 URL
- ① Microsoft Learn — Buttons (Windows apps / WinUI): https://learn.microsoft.com/en-us/windows/apps/design/controls/buttons （state、ClickMode=Release 既定、Enter/Space 発火、4 specialized button）
- ② WinUI button states (Normal/PointerOver/Pressed/Disabled) + theme dictionaries: https://learn.microsoft.com/en-us/windows/apps/develop/ui/theming
- ③ XAML styles / theme resources (ButtonBackgroundPointerOver / ButtonForegroundDisabled / ButtonBorderBrushDisabled): https://learn.microsoft.com/en-us/windows/apps/develop/platform/xaml/xaml-styles
- ④ Fluent 2 Design System — interaction states (rest→hover→pressed の段階): https://fluent2.microsoft.design/components/web/react/core/button/usage
- 内部 cross-check: 現 button_theme_win10 (GUI_kit crates/hayate-kit/src/style/widget_theme_presets/button.rs:151) が #E5F1FB / #CCE4F7 / #ADADAD / #0078D4 を既採用。

## 6. 制約遵守メモ
- cargo 未起動（grep + web のみ）。記憶ベースなし、数値は出典 + 実コード grep。
- 視覚最終判定は user(gallery)。本 doc は仕様 + 差分 + 提案のみ、実装せず。
- golden での state 検証設計は別 doc workspace/phase3b/golden-state-design.md（disabled/focus を含む state を決定論的に locking する層）。
