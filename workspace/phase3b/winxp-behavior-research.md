# Windows XP Luna — button state 挙動の仕様 + GUI_kit 現状 + ギャップ

担当: worker1 / Phase 3b 第3波（behavioral state 研究）/ 2026-05-20
**研究のみ・実装なし・cargo 起動なし**（PRESIDENT が gallery build で cargo 使用中）。視覚最終判定は user。

> 制約: 記憶ベース禁止。本 doc は xp.css (botoxparty/XP.css) `themes/XP/_buttons.scss` 原文（button の :active / :hover / :focus / :not(:disabled) 各規則）+ Win32 標準（disabled 灰文字）を出典とする。現 GUI_kit 挙動は `button.rs` paint/event のコード読解。

---

## 0. 出典 URL

| 種別 | 出典 | URL |
|------|------|-----|
| 実装 (CSS) | xp.css `themes/XP/_buttons.scss`（:active/:hover/:focus/:not(:disabled)） | https://github.com/botoxparty/XP.css/blob/main/themes/XP/_buttons.scss |
| 実装 (CSS) | xp.css `themes/XP/_variables.scss`（surface/border 等） | https://github.com/botoxparty/XP.css/blob/main/themes/XP/_variables.scss |
| 実 OS 挙動 | Win32 `DrawState`(DSS_DISABLED) = XP 継承の灰文字 engrave | https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-drawstate |
| 現 GUI_kit | `crates/hayate-kit/src/widget/button.rs`（paint L290-622 / event L692-816）+ preset `button_theme_xp_luna`(style/widget_theme_presets/button.rs:133-148) | コード読解 |
| 第1波 | `workspace/phase3b/winxp-luna-research.md`（rest 色/gradient/border 既出） | 同 repo |

---

## 1. state 仕様（xp.css 原文 + 実 OS）

XP button の本質 = **白→タンの縦グラデ glossy face + 1px 濃紺枠 + hover で amber(琥珀)発光 + press でグラデ反転(沈み) + focus で blue 発光 + disabled 灰 engrave**。Win95 のような硬い bevel ではなく「ソフトな内側グロー」が XP らしさ。

### 1a. rest（通常）
- `border: 1px solid #003c74`（濃紺アウトライン）、`border-radius: 3px`、font 11px
- 背景 = 縦グラデ（180deg）: `#ffffff` 0% → `#ecebe5` 86% → `#d8d0c4` 100%（上が白く光り下がタン = glossy）
- box-shadow none

### 1b. hover（:hover・amber 内側グロー）
- box-shadow（4 層 inset、border 内側に琥珀グロー）:
  - `inset -1px 1px #fff0cf` / `inset 1px 2px #fdd889` / `inset -2px 2px #fbc761` / `inset 2px -2px #e5a01a`
- = **border の内側に上→下で淡黄〜濃オレンジのグロー帯**。face のグラデは保持（全面が黄色くなるのではなく、縁が光る）。timing 概念 = `transition` 短時間（~0.1s）。

### 1c. press（:active・グラデ反転で沈み）
- box-shadow none に戻し、背景グラデを**反転**（180deg）: `#cdcac3` 0% → `#e3e3db` 8% → `#e5e5de` 94% → `#f2f2f1` 100%
- = **上が暗い #cdcac3、下が明るい #f2f2f1**（rest の白→タンと上下が逆 = 押し込まれて凹む）。面の明暗反転で press 感を出す（bevel 反転ではない）。

### 1d. focus（:focus・blue 内側グロー）
- box-shadow（5 層 inset、青グロー）:
  - `inset -1px 1px #cee7ff` / `inset 1px 2px #98b8ea` / `inset -2px 2px #bcd4f6` / `inset 1px -1px #89ade4` / `inset 2px -2px #89ade4`
- = **border の内側に淡青〜中青のグロー**（hover の amber を青にした版）。focus は press と独立。

### 1e. disabled（灰 engrave）
- xp.css は hover/active を `:not(:disabled)` でゲート → **disabled では amber/青グローも press 反転も出ない**（rest グラデのまま反応停止）。
- 実 OS XP の disabled = **灰文字 + 白ハイライト engrave**（Win32 DSS_DISABLED、ButtonShadow `#ACA899` 灰 + 白 +1,+1）。xp.css は browser 既定の灰に委ねる。

---

## 2. 現 GUI_kit の挙動（button.rs コード読解）

`button_theme_xp_luna`(preset L133-148) = gradient(white,#d8d0c4) / bg_hover `#fdebb2` / bg_pressed `#cdcac3` / border 1px `#003c74` / border_hover `#e5a01a` / radius 3 / shine 180 / press_scale 0.98 / hover_duration 0.08。**bevel なし・no_hover なし**（= hover 有効、非 bevel 経路）。

| state | 現 GUI_kit 挙動 | 該当 |
|-------|----------------|------|
| rest | gradient white→#d8d0c4（2 stop）+ shine 180 で 2 行 glass strip（反射）+ border #003c74 | paint L380-405 / preset |
| hover | bg を bg_hover `#fdebb2` へ lerp（**全面が淡 amber tint**）+ border を #003c74→#e5a01a へ lerp。0.08s spring | paint L373-377/L408-409 / event L713-718 |
| press | gradient テーマのため bg_pressed 不使用（worker2 §2-#4）。top が bottom 方向へ 0.6 lerp（やや暗く沈む）+ press_scale 0.98 で 2% 縮小 | paint L380-385/L314-321 |
| focus | 非 bevel → 末尾 `draw_focus_ring`(active_theme) + step6 で **HAYATE_DARK.accent(cyan)を hardcode した外側 accent ring**（L531）+ focus で border alpha/幅 +1 | paint L408-424/L530-545/L618-621 |
| disabled | 非 bevel のため `draw_etched` は**発火せず**（L578 は bevel テーマ限定）。pointer は swallow（L697-705） | paint L578 / event L697-705 |

---

## 3. ギャップ一覧（仕様 vs 現実装）

| # | 項目 | 仕様（xp.css/実OS） | 現 GUI_kit | 重大度 | メモ |
|---|------|---------------------|-----------|--------|------|
| G1 | hover の出方 | border 内側に **amber グロー帯**（face グラデは保持） | bg_hover で**全面を淡 amber tint** + amber border | 中 | 「縁が光る」vs「面が黄ばむ」。framework が inset glow を持てば寄せられる。border_hover #e5a01a はグロー最下層と一致 ✓ |
| G2 | press の出方 | グラデ**反転**（上 #cdcac3 暗 / 下 #f2f2f1 明）で凹む | gradient top を 0.6 lerp（やや暗化）+ 2% 縮小。**下は明るくならない**、bg_pressed #cdcac3 は gradient 時**不使用** | 中 | 押し込み感が弱い。press 時に gradient を反転（暗→明）できると忠実。press_scale 縮小は XP には無い癖（要 user 判断） |
| G3 | focus 色と位置 | border **内側に blue グロー**（#98b8ea 等） | **外側** accent ring + ring 色が **HAYATE_DARK.accent=cyan を hardcode**（L531）→ XP 青でなく cyan | 中〜高 | (a)位置が内→外で別物 (b)**色が theme 非追従の hardcode バグ**。XP では青グローが欲しい。**横断バグ G-X 参照** |
| G4 | disabled 灰化 | 灰文字 + 白 engrave（DSS_DISABLED） | **灰化しない**（etched は bevel 限定、XP は非 bevel → ラベル黒のまま） | 中 | XP disabled が rest と区別つかない（文字が黒いまま）。**非 bevel テーマ全般の問題**（Win10/BigSur/MacOS9 も同断） |
| G5 | rest グラデ stop | 3 stop（#fff→#ecebe5 86%→#d8d0c4） | 2 stop（#fff→#d8d0c4、mid 欠落） | 低 | 第1波 winxp-luna §4b で既出。下部質感が僅かに違う |

### G-X（横断バグ・focus ring の hardcode）
`button.rs:531` の非 bevel focus ring は `let accent = &HAYATE_DARK.accent;`（cyan）を**固定**。XP/Win10/BigSur など全 light テーマで focus ring が cyan になり theme accent と不一致。**`active_theme().accent` に置換すべき**（末尾 L618 の `draw_focus_ring` は active_theme を使うので、step6 の hardcode が二重描画で cyan を被せている疑い）。worker3 Win10 doc とも共有推奨。

---

## 4. 改訂方針メモ（実装は user gallery 評価後）

優先度順（実装判断は PRESIDENT/boss、user 視覚確認前提）:

1. **G-X focus ring hardcode 修正**（中〜高・横断）: `button.rs:531` を `active_theme().accent` 化（or step6 ring を bevel 同様に theme 追従へ）。低コストで XP/Win10/BigSur 全 focus 色が正しくなる。**最優先**（バグ性）。
2. **G4 非 bevel disabled 灰化**（中・横断）: `draw_etched` が bevel 限定なので、非 bevel テーマ用に「fg を灰へ lerp する disabled path」を追加（ButtonTheme に `fg_disabled` or 既定で fg を ButtonShadow へ）。XP/Win10/BigSur/MacOS9 全てに効く。
3. **G3 focus を内側 blue グロー**（中）: framework が inset glow を持てば XP focus を青内グローに。無ければ G-X で「青い外 ring」になるだけでも改善。
4. **G2 press グラデ反転**（中）: gradient テーマの press で top↔bottom を反転 lerp する描画オプション。press_scale 0.98 は XP らしくないので 1.0 へ戻す検討。
5. **G1 hover amber グロー**（中）: G3 と同じ inset glow 基盤で amber 版。無ければ現状の面 tint で暫定許容。
6. **G5 rest グラデ 3 stop**（低）: 第1波の色微修正と同様、framework が 3-stop グラデを持てば。

**触らない方が良い（仕様一致/良好）**: shine 180 の glass strip（rest 反射）= XP らしい ✓。border #003c74 / border_hover #e5a01a ✓。hover 0.08s の短アニメ ✓（XP は短い transition あり）。

> timing 概念: XP は state 遷移に**短い transition（~0.1s）**があり Win95 の即時とは異なる「ぬるっと光る」空気感。GUI_kit の hover 0.08s spring / press 0.08s EaseOut はこの方向で妥当。**ただし press_scale の縮小は XP 実機には無い**ので、忠実度を上げるなら外す（user 視覚確認事項）。
