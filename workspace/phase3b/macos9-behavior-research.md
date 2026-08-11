# Phase 3b 第3波 調査: Mac OS 9 Platinum — widget state 挙動の仕様

worker2 / 2026-05-20。**研究のみ・実装なし・cargo 不使用**。視覚最終判定は user。出典は末尾。
対象 = button の rest / hover / press / focus / disabled / default。

---

## 0. 結論サマリ + 重要な research 訂正

- **「脈動 (pulsing) default button」は Platinum には存在しない**。脈動は **Aqua (Mac OS X 10.0, 2001) で初登場し Yosemite (2014) で廃止**された機能。Aqua は Platinum の後継。
  → Mac OS 9 Platinum の default button は **静的な太い黒枠リング**（脈動なし）。**Platinum 実装に脈動を足してはいけない**（記憶ベース禁止の好例、ミッション記載の「脈動」は時代取り違え）。
- classic Mac OS は **hover (rollover) 状態を持たない**。マウスが乗っても外見は不変。press で初めて沈む。
- press = **ベベルが沈む (sunken)**、**白黒反転ではない**、ラベルは黒のまま。
- GUI_kit の現 `button_theme_mac_classic`（第2波で Platinum bevel 化）は **hover なし (no_hover) / press 沈み / 反転廃止**が既に仕様通り。残ギャップは **default リング / focus 表現 / disabled の質感**。

---

## 1. state 別 仕様（出典付き）

| state | Platinum 仕様 | 出典 |
|-------|--------------|------|
| rest | 淡グレー pillow、薄い 3D ベベル（光源左上 = 明 TL / 暗 BR）+ 細い暗枠 | Inside Macintosh Platinum Appearance / platinum.css |
| **hover** | **状態なし（rollover 概念が classic Mac OS に無い）**。マウス乗りで外見不変 | Inside Macintosh（hover 記述なし）/ Bevel Buttons の状態列挙に hover 不在 |
| press | ベベルが**沈む (sunken)**。両 pressed 状態は Platinum では同一表示。**反転しない**、fg は黒維持 | Inside Macintosh "Bevel Buttons"（"both pressed states look the same under platinum appearance"）|
| **default** | **静的な太い黒枠リング**でボタンを囲む（Return 起動を示す）。**脈動しない**（脈動は Aqua 専用、後述） | Aqua=Platinum 後継 + 脈動は OS X 10.0 導入/Yosemite 廃止（Wikipedia Aqua）|
| focus | キーボード focus は**実線の focus ring / 枠**で示す（主に text field、default button）。classic は focus の届く範囲が限定的 | Inside Macintosh Dialog Box Guidelines（focus ring）|
| disabled | ラベル・コントロールを**淡色化 (dimmed / greyed)**。bevel button は 7 状態中 2 つが disabled (off/on) | Inside Macintosh "Bevel Buttons"（5 active + 2 disabled）|

### Platinum bevel button の 7 状態（参考、push 主眼では rest/press/disabled が要点）
5 active = off / pressed(was off) / on / pressed(was on) / mixed、2 disabled = disabled-off / disabled-on。
push button としては off=rest、pressed=沈み、disabled=淡色 が該当。

---

## 2. 現 GUI_kit の挙動（コード読解、cargo なし）

出典: `crates/hayate-kit/src/widget/button.rs`（state machine + paint）、`widget_theme_presets/button.rs`（mac_classic）。

| 機構 | 実装 | 該当 |
|------|------|------|
| 状態 enum | `ButtonState { Normal, Hovered, Pressed }` + 別 bool `focused` / `disabled` | button.rs:17-24, 66-69 |
| アニメ値 | `bg_value` 0.0=normal / 1.0=hover / 2.0=pressed を Tween (spring/ease) で補間 | :77, :118-119, :653 |
| **hover skip** | `no_hover` 時は hover 遷移を完全スキップ（Normal のまま）| :708-712 |
| press | press で `animate_to(2.0, 0.08)`、release で hover/normal へ復帰 | :740-764 |
| **bevel 自動反転** | press (v>1.0) で外/内ベベルの light↔dark を swap（沈む）| paint :426-477 |
| press text | `press_text_offset` でラベル 1px シフト | paint :568 |
| focus | **bevel テーマ → 点線 (dotted) inner rect**（Win95 流）/ modern → accent outer ring | paint :519-533 |
| disabled | **bevel+bitmap 経路のみ etched 淡色** (`draw_etched`)、modern/cosmic-text 経路は**淡色化なし** | paint :578-593 |
| default 概念 | **無し**（default button という区別も脈動アニメも存在しない）| — |

現 `button_theme_mac_classic`（第2波）: `.no_hover()` ✓ / press は bevel 自動反転 + `press_text_offset 1.0` ✓ / fg 全状態黒 ✓。
→ **rest / hover無し / press 沈み は仕様一致**。

---

## 3. ギャップ一覧

| # | 項目 | 仕様 | 現 GUI_kit | 判定 |
|---|------|------|-----------|------|
| 1 | hover | 無し | mac_classic は no_hover ✓ | ✓ 一致 |
| 2 | press | 沈む・反転なし・黒文字 | bevel 自動反転 + text 沈み + fg 黒 ✓ | ✓ 一致（第2波で達成）|
| 3 | **default リング** | 静的な太い黒枠リング | リングなし（暫定で bevel shadow 濃色化のみ）| △ 要 framework（外周 ring 描画）|
| 4 | **脈動** | **無し（足してはいけない）** | 無し | ✓ 一致（追加しないこと）|
| 5 | **focus** | 実線 focus ring（主に text field / default）| bevel テーマは**点線 (Win95 流)** | ✗ Platinum は点線でなく実線寄り、push へ点線は非 Platinum |
| 6 | **disabled** | 淡色 (dimmed grey) | etched（Win95 流）。質感が Platinum と別 | △ 淡色化方式の見直し候補 |

---

## 4. 改訂方針メモ（実装は user gallery 評価後）

- **足さないもの**: default button の脈動アニメ（Aqua 専用、Platinum 非該当）。追加は忠実度を下げる。
- **default リング (#3)**: 真の Platinum default = ボタン外周に**静的な太い黒枠**。現 renderer は外周を bevel が上書きするため別途 framework 対応（macos9-button-fix-draft.md §4-C: body 外側 ring rect）。優先度は user が「OK が目立たない」と感じた時。
- **focus (#5)**: Platinum 寄りにするなら push button の focus は**点線でなく細い実線リング**（または default ring と統合）。bevel テーマ一律で Win95 点線にしている分岐（paint:519-533）を skin 別に分けるか検討。framework 案件。
- **disabled (#6)**: Platinum は etched より「全体を淡グレーに沈める」dim。modern 経路には disabled 淡色化が無い（paint で確認）ので、disabled dim を skin 横断で持つかは framework 判断（Big Sur 側 doc と共通課題）。
- **press timing/空気感**: 沈みの速さ (`animate_to 0.08`) は user が触って承認する C 層事項。

---

## 5. 出典 URL

- Aqua = Platinum 後継 / 脈動 default button は OS X 10.0 導入・Yosemite (2014) 廃止: https://en.wikipedia.org/wiki/Aqua_(user_interface)
- Inside Macintosh "Bevel Buttons"（7 状態 = 5 active + 2 disabled、"both pressed states look the same under platinum appearance"、hover 記述なし）: https://dev.os9.ca/techpubs/mac/HIGOS8Guide/thig-16.html
- Inside Macintosh "Platinum Appearance"（Platinum theme 定義）: https://dev.os9.ca/techpubs/mac/HIGOS8Guide/thig-8.html
- Inside Macintosh "Dialog Box Guidelines"（default button / keyboard focus / dialog、章 TOC）: https://dev.os9.ca/techpubs/mac/HIGOS8Guide/thig-38.html
- platinum.css（press box-shadow / button ベベルの recreation 実値）: https://github.com/mat-sz/platinum.css
- 現 GUI_kit 挙動（state machine / paint / 第2波 mac_classic）: GUI_kit `crates/hayate-kit/src/widget/button.rs`、`crates/hayate-kit/src/style/widget_theme_presets/button.rs`、`workspace/phase3b/macos9-button-fix-draft.md` §2

---

## 6. user 視覚/触感 確認待ち（PRESIDENT が gallery で）
1. press 沈みの速さ・深さが Platinum らしいか。
2. default リングが必要か（暫定濃色 bevel で足りるか）。
3. focus を点線のままにするか実線リングにするか。
4. disabled の淡色感（etched vs dim）。
