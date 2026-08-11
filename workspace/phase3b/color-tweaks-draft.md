# Phase 3b 第2波: 低リスク色微修正バッチ案ドラフト

担当: worker1 / 2026-05-20 / **cargo-free ドラフト**（PRESIDENT が titlebar 機構を cargo -j1 並行実装中。実装解禁は boss1 通知後）

> 目的: 第1波調査 5 doc で確定した「実物正準へ寄せる低リスク色補正」を、正確な file:line + 新旧値で列挙。実装は boss1 解禁後、cargo -j1 直列 verify で。本 doc は編集計画のみ（まだ何も書き換えていない）。
>
> **ファイル競合の最重要原則**: worker1 編集スコープ = `theme.rs` / `tooltip.rs` / `input.rs`。**`button.rs` は触らない**（worker2 が Mac OS 9 button 修正で同ファイルを編集予定）。button.rs 内の Big Sur radius は §B-3 に file:line + 新旧値を記載するが、**実装は button.rs オーナー(worker2)と boss1 経由で調整、worker1 は編集しない**。

GUI_kit パス: `/home/ken/Documents/GUI_kit/crates/hayate-kit/src/style/`

---

## A. worker1 が実装する変更（theme.rs / tooltip.rs / input.rs）

### A-1. tooltip win95 背景 — native COLOR_INFOBK 一致

| 項目 | 内容 |
|------|------|
| file:line | `widget_theme_presets/tooltip.rs:16` |
| 旧値 | `bg: Color::rgb(255, 255, 225), // "info yellow"`（= #FFFFE1） |
| 新値 | `bg: Color::rgb(255, 255, 192), // native COLOR_INFOBK #FFFFC0` |
| 出典 doc | `win95-refine-research.md` §5-E（L197-198）「native COLOR_INFOBK = #FFFFC0(255,255,192)」/ §INFOBK 表（L59）|
| **テスト追従（必須）** | `tooltip.rs:120` の `assert_eq!(t.bg, Color::rgb(255, 255, 225));` を `Color::rgb(255, 255, 192)` に同時更新。未更新だと `win95_is_yellow_with_hard_border` が落ちる |
| リスク | 低（利得も小。native 厳密一致のため）。XP/MacOS9 tooltip(L35/L67) も同じ #FFFFE1 だが**今回スコープは win95 のみ**。XP/MacOS9 は据え置き（mission 指定どおり） |

### A-2. Win10 bg_primary — Control 正準 #F0F0F0

| 項目 | 内容 |
|------|------|
| file:line | `theme.rs:408`（`WIN10_THEME`） |
| 旧値 | `bg_primary: Color::rgb(0xF3, 0xF3, 0xF3),`（= #F3F3F3、Win11 Mica 寄り） |
| 新値 | `bg_primary: Color::rgb(0xF0, 0xF0, 0xF0),`（Control/ButtonFace canonical #F0F0F0） |
| 出典 doc | `win10-research.md` §1a（Control #F0F0F0）+ §5a（「#F3F3F3 は Win11寄り→#F0F0F0 へ是正」）。Microsoft tenforums + system color gist で #F0F0F0 確認済 |
| テスト追従 | 不要。`win10_theme_fields`(theme.rs:712) は accent と border_radius のみ assert、bg_primary は触らない |
| 補足（スコープ外・任意） | `theme.rs:431 separator_glow: Color::rgb(0xF3, 0xF3, 0xF3)` も bg_primary を mirror した値。今回スコープは bg_primary のみのため**据え置き**。揃えたい場合は別途 boss1 判断（本バッチには含めない） |
| リスク | 低（差は 3/255、視覚微差。canonical 化のみ） |

### A-3. Big Sur warning — macOS systemOrange #FF9500

| 項目 | 内容 |
|------|------|
| file:line | `theme.rs:470`（`MACOS_BIG_SUR_THEME`） |
| 旧値 | `warning: Color::rgb(0xFF, 0x9F, 0x0A),`（= #FF9F0A、iOS dark 変種） |
| 新値 | `warning: Color::rgb(0xFF, 0x95, 0x00),`（macOS systemOrange #FF9500 = 255,149,0） |
| 出典 doc | `macos-bigsur-research.md` §1（L27「systemOrange #FF9500 … iOS dark の #FF9F0A とは別」）+ §4（L120）+ §5（L138「#FF9F0A → #FF9500 macOS systemOrange に統一 ◎」） |
| テスト追従 | 不要。`macos_big_sur_theme_fields`(theme.rs:719) は accent / bg_primary / border_radius のみ assert、warning は触らない |
| リスク | 低（macOS 正準色への置換） |

### A-4. XP selection — 実機 Highlight #316AC5（2 箇所）

XP の selection は現状 accent #0054E3 流用。実機 system color Highlight = #316AC5 へ寄せる。**alpha は各箇所の現値を維持し RGB のみ変更**。

#### A-4a. theme.rs selection_overlay
| 項目 | 内容 |
|------|------|
| file:line | `theme.rs:386`（`XP_LUNA_THEME`） |
| 旧値 | `selection_overlay: Color::rgba(0x00, 0x54, 0xE3, 90),`（accent + a90） |
| 新値 | `selection_overlay: Color::rgba(0x31, 0x6A, 0xC5, 90),`（Highlight #316AC5 + a90 維持） |
| テスト追従 | 不要。`xp_luna_theme_fields`(theme.rs:703) は bg_primary/accent/success/border_radius のみ assert |

#### A-4b. input.rs input_theme_xp_luna selection_color
| 項目 | 内容 |
|------|------|
| file:line | `widget_theme_presets/input.rs:20` |
| 旧値 | `.selection_color(Color::rgba(0, 84, 227, 120))`（accent 0,84,227 + a120） |
| 新値 | `.selection_color(Color::rgba(49, 106, 197, 120))`（Highlight #316AC5 = 49,106,197 + a120 維持） |
| テスト追従 | 不要。`input_xp_luna`(input.rs:113) は bg/border_focused/border_radius のみ assert、selection_color は触らない |

| 共通 | 内容 |
|------|------|
| 出典 doc | `winxp-luna-research.md` §1a（Highlight #316AC5 = 49,106,197 実機正準）+ §5a/§5c（selection を #316AC5 へ寄せ推奨） |
| リスク | 低〜中（青→やや明るい青へ。実機正準だが「accent と統一感」より「実機忠実」を取る判断。最終は user 視覚確認） |
| input.rs 競合注記 | input.rs は共有 widget ファイル。現 task 割当では worker2 = button.rs のみ（input.rs 非対象）だが、共有 worktree のため commit 時 pathspec + workerN/ prefix 厳守。着手前に boss1 へ input.rs 編集を一言共有推奨 |

---

## B. worker1 は編集しない（button.rs = worker2 オーナー、boss1 経由調整）

### B-3. Big Sur button radius 8 → 6 ※worker1 編集禁止

| 項目 | 内容 |
|------|------|
| file:line | `widget_theme_presets/button.rs:175`（`button_theme_macos_big_sur`、現在行 = 175。同ファイル L192 の `radius(8.0)` は `button_theme_mac_classic`(Mac OS 9) で別物・対象外） |
| 旧値 | `.radius(8.0)` |
| 新値 | `.radius(6.0)` |
| 出典 doc | `macos-bigsur-research.md` §3（L76「標準 push button 角丸 ≈5〜6px、8.0 はやや丸すぎ→6推奨」）+ §5（L143「.radius(8.0) → .radius(6.0)」） |
| **テスト追従（必須）** | `button.rs:239` の `assert!((t.border_radius - 8.0).abs() < 0.01);`（`macos_big_sur_radius` テスト）を `6.0` に同時更新が必要 |
| **競合・実装担当** | **button.rs は worker2 が Mac OS 9 button 修正で編集予定。worker1 は button.rs を一切編集しない**。本変更は worker2 の Mac OS 9 commit に同梱するか、worker2 着手完了後に boss1 が別途指示するか、boss1 経由で調整すること。worker1 は file:line + 新旧値の提供のみ |

---

## C. 実装順・verify 方針（boss1 解禁後）

1. **現状 cargo 起動禁止**（PRESIDENT titlebar 機構 cargo -j1 並行中）。本 doc は計画のみ。
2. boss1 が「titlebar cargo 完了 → worker 順次解禁」を通知したら worker1 着手。
3. worker1 バッチ = A-1〜A-4（theme.rs / tooltip.rs / input.rs、計 5 値 + tooltip テスト 1 行）。**1 commit でまとめる**（全て低リスク色補正、bisect 単位として妥当）。
4. verify: `cargo build -j1` + `cargo test -j1`（**-j1 厳守**、`feedback_cargo_j1_rule`）。tooltip win95 テスト追従済を確認。
5. B-3（button.rs）は worker2 / boss1 調整後、別 commit。worker1 は関与しない。
6. commit hygiene: 共有 worktree のため `git add` は pathspec 明示（theme.rs / tooltip.rs / input.rs のみ）、commit message に `worker1/` 文脈明記、pre-commit で branch 確認（`feedback_shared_wt_commit_hygiene`）。

## D. 変更サマリ表

| # | file:line | 旧 → 新 | テスト追従 | 担当 | 出典 doc |
|---|-----------|---------|-----------|------|----------|
| A-1 | tooltip.rs:16 | #FFFFE1 → #FFFFC0 (255,255,192) | tooltip.rs:120 必須 | **worker1** | win95-refine §5-E |
| A-2 | theme.rs:408 | #F3F3F3 → #F0F0F0 | 不要 | **worker1** | win10 §1a/§5a |
| A-3 | theme.rs:470 | #FF9F0A → #FF9500 | 不要 | **worker1** | macos-bigsur §1/§5 |
| A-4a | theme.rs:386 | rgba(0,84,227,90) → rgba(49,106,197,90) | 不要 | **worker1** | winxp-luna §1a/§5a |
| A-4b | input.rs:20 | rgba(0,84,227,120) → rgba(49,106,197,120) | 不要 | **worker1** | winxp-luna §1a/§5c |
| B-3 | button.rs:175 | radius 8.0 → 6.0 | button.rs:239 必須 | **worker2/boss1 調整・worker1 不可** | macos-bigsur §3/§5 |

> 全値は第1波 research doc 根拠（記憶ベースなし）。最終「実物っぽい」判定は user 実機確認 → 反復。cargo は boss1 解禁通知後のみ。
