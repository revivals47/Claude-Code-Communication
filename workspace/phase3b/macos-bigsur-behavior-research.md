# Phase 3b 第3波 調査: macOS Big Sur — widget state 挙動の仕様

worker2 / 2026-05-20。**研究のみ・実装なし・cargo 不使用**。視覚最終判定は user。出典は末尾。
対象 = push button の rest / hover / press / focus / disabled / default。

---

## 0. 結論サマリ + 重要な research 訂正

- **Big Sur の default button は脈動 (pulse) しない**。脈動は Aqua 専用（OS X 10.0 導入、**Yosemite 2014 で廃止**）。Big Sur (2020) は脈動廃止後なので **default = accent 塗りの静的ボタン**。
  → ミッション記載の「default ボタンの強調(accent 塗り + 脈動)」のうち **脈動は誤り**。accent 塗りのみが正。**Big Sur に脈動を足してはいけない**。
- **標準 push button は hover (rollover) で外見が変わらない**。マウス乗りでハイライトしない。press で初めて暗化。
  （sidebar / toolbar / list 行など他コントロールは hover するが、**push button は別**。）
- press = **暗化**（Big Sur までは色付き押下、Monterey で色ハイライト廃止）。
- default button = **accent 色で塗られて強調**（accent は user 設定: 既定 blue / multicolor / purple 等）。非 default = 白/淡グレー。
- focus = **accent 色の focus ring**。disabled = **淡色 (dim)**。

---

## 1. state 別 仕様（出典付き）

| state | Big Sur 仕様 | 出典 |
|-------|-------------|------|
| rest（非 default）| 白背景の丸角ボタン、薄い境界、soft shadow | mackuba NSButton styles（"white background"）/ HIG |
| rest（default）| **accent 色塗り**で強調（Return 起動を示す）。accent は blue 既定 (#007AFF) / multicolor 等 user 設定 | Apple HIG Push Buttons（"draws the default button prominently using the accent color"）/ 512px Big Sur accent |
| **hover** | **標準 push button は変化なし**（rollover ハイライトなし）| mackuba / HIG（push button の hover 記述なし）|
| press | **暗化**（Big Sur まで色付き押下、Monterey で廃止）。微かに沈む/縮む感 | mackuba（"Non-default buttons were also drawn with the same colored background in their pressed state ... changed in Monterey"）|
| **default 脈動** | **なし**（Yosemite 2014 で廃止、Big Sur は静的）| Wikipedia Aqua（脈動 = OS X 10.0 導入 / Yosemite 廃止）|
| focus | **accent 色の focus ring**（Full Keyboard Access も focus を accent で強調）| HIG / Apple Support Full Keyboard Access |
| disabled | コントロールを**淡色化 (dimmed, 約 50%)** | HIG（"disabled if not applicable"）+ 一般 AppKit 慣行 |

### accent vs highlight（Big Sur）
- **accent color** = button / control / sidebar glyph / **default button** の色（blue 既定、Multicolor 追加）。
- **highlight color** = text selection（Big Sur では accent に追従可）。
- → default push button の色は **accent 設定に追従**する。

---

## 2. 現 GUI_kit の挙動（コード読解、cargo なし）

出典: `crates/hayate-kit/src/widget/button.rs`、`widget_theme_presets/button.rs`（macos_big_sur）。

| 機構 | 実装 | 該当 |
|------|------|------|
| 状態 enum | `ButtonState { Normal, Hovered, Pressed }` + bool `focused` / `disabled` | button.rs:17-24 |
| アニメ | `bg_value` 0/1/2 を Tween (spring/ease) 補間 | :77, :118, :653 |
| hover | macos_big_sur は **no_hover を設定していない** → hover 遷移する（`bg_hover` #1487FF、`hover_duration` 0.12）| presets button.rs:166-179, button.rs:713-722 |
| press | `bg_pressed` #0064DC + `press_scale 0.97` で暗化+縮み | presets:170,178 / paint:373-377,314 |
| focus | bevel なしテーマ → **accent outer ring** | paint:530-533 |
| disabled | **modern/cosmic-text 経路は淡色化なし**（etched は bevel+bitmap 専用）→ disabled でも full color 描画 | paint:578-593 |
| default 概念 | **無し**（default/非 default の区別も、accent 追従もテーマに無い）| — |
| 脈動 | 無し | — |

現 `button_theme_macos_big_sur`: accent #007AFF 塗り / press 暗化 #0064DC + scale 0.97 / radius 6（第2波で 8→6）/ shadow 1px。

---

## 3. ギャップ一覧

| # | 項目 | 仕様 | 現 GUI_kit | 判定 |
|---|------|------|-----------|------|
| 1 | **hover** | push button は変化なし | **hover で明化する**（bg_hover #1487FF, dur 0.12）| ✗ 非忠実な hover ハイライト |
| 2 | press | 暗化 | bg_pressed 暗化 + scale 0.97 | ✓ 一致 |
| 3 | **脈動** | **なし（足さない）** | なし | ✓ 一致（追加しないこと）|
| 4 | **default vs 非 default** | 非 default=白 / default=accent 塗り | **常に accent 塗り**（全ボタンが default 見え）| △ 非 default(白) variant が無い |
| 5 | focus | accent ring | modern → accent outer ring | ✓ 一致 |
| 6 | **disabled** | 淡色 (~50% dim) | **modern 経路は dim なし**（full color のまま）| ✗ disabled dim 不在 |

---

## 4. 改訂方針メモ（実装は user gallery 評価後）

- **足さないもの**: default button の脈動（Yosemite で廃止済、Big Sur 非該当）。
- **hover (#1)**: 標準 push button は hover で変えないのが忠実。`button_theme_macos_big_sur` に **`no_hover()` を付ける**か、`bg_hover` を `bg` と同値にして hover 明化を抑制（低リスク、テーマ値のみ）。※ ただし toolbar/list 系の hover は別物なので push button 限定の判断。user 視覚確認推奨。
- **default vs 非 default (#4)**: 忠実には **非 default = 白/淡グレー（mackuba "white background"）、default = accent 塗り**。現状は accent 一択。将来 `button_theme_macos_big_sur_secondary`（白系）を足し、accent 塗りは default 用に位置付ける案。default 概念自体は framework（どのボタンが default かの状態）に依存するのでスコープ大、user 評価後に判断。
- **disabled (#6)**: modern 経路に disabled 淡色化が無い（paint 確認）。Big Sur disabled は ~50% dim。**disabled 時に fg/bg を淡色化（opacity 低減）する skin 横断機構**が要る（Platinum doc と共通の framework 課題）。
- **accent 追従**: Big Sur の default button 色は user の accent 設定に追従。GUI_kit は固定 #007AFF。動的 accent は将来課題（theme framework）。
- **timing/空気感**: press の scale/暗化の速さは C 層（user が触って承認）。

---

## 5. 出典 URL

- Apple HIG "Push Buttons"（default = accent 強調、disabled 指針）: https://developer.apple.com/design/human-interface-guidelines/buttons
- A guide to NSButton styles（rest=白、press 暗化、Big Sur→Monterey の色ハイライト変遷、hover 記述なし）: https://mackuba.eu/2014/10/06/a-guide-to-nsbutton-styles/
- Aqua = 脈動 default button は OS X 10.0 導入・Yosemite (2014) 廃止: https://en.wikipedia.org/wiki/Aqua_(user_interface)
- Big Sur Accent / Highlight color（accent=button/control/default、Multicolor）: https://512pixels.net/2020/11/big-sur-accent-highlight-colors/
- Full Keyboard Access（focus を accent で強調）: https://support.apple.com/guide/mac-help/use-full-keyboard-access-mchlc06d1059/mac
- 現 GUI_kit 挙動: GUI_kit `crates/hayate-kit/src/widget/button.rs`、`crates/hayate-kit/src/style/widget_theme_presets/button.rs`

---

## 6. user 視覚/触感 確認待ち（PRESIDENT が gallery で）
1. push button を hover 無反応にするか（忠実）、微 hover を残すか。
2. 非 default(白) variant を作るか、全 accent のままにするか。
3. disabled の dim を入れるか（modern 経路の淡色化）。
4. press の縮み/暗化の速さが Big Sur らしいか。
