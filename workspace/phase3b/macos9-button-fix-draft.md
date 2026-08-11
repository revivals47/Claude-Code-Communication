# Phase 3b 第2波 ドラフト: Mac OS 9 Platinum button 修正案

worker2 / 2026-05-20。**cargo 未起動（PRESIDENT が titlebar 機構を cargo -j1 並行実装中のため）**。本 doc は grep + コード読解に基づく builder ドラフト。実装・cargo は boss1 解禁通知後。
視覚最終判定は user。第1波 finding 出典: workspace/phase3b/macos9-research.md §1-3 / §5 / §7-2。

---

## 0. 結論サマリ

現 `button_theme_mac_classic`（System7 風: フラット #DDD・1.5px 黒枠・押下で **bg黒/fg白の白黒反転**）を、
Win95 で実証済の 2-stage 3D bevel 機構（`ButtonTheme::bevel()`）を流用し、**Platinum グレー実値**へ置換する。
**押下は bevel が沈む（自動反転）+ テキスト 1px シフトのみ。白黒反転は廃止（fg は黒維持）**。

ただしコード読解で **2 件の renderer 構造制約**が判明（§2）。これにより:
- **radius 3.0 と bevel は現状両立不可** → 即時実装は **radius 0.0**（Win95 同様の角丸なし）。radius 3.0 は framework 拡張待ち（§4-A）。
- **Platinum 特有の「全周 1px ダーク輪郭線」は bevel と両立不可** → framework 拡張待ち（§4-B）。

→ **即時実装可能な範囲で「Win95 の信頼できるベベルを Platinum グレー+淡グラデ face にした版」を納める**。角丸・全周輪郭は framework 側で別途。

---

## 1. 現状コード（差替対象）

`crates/hayate-kit/src/style/widget_theme_presets/button.rs:182-200`

```
pub fn button_theme_mac_classic() -> ButtonTheme {
    ButtonTheme::new()
        .bg(rgb(221,221,221)).bg_hover(rgb(230,230,230)).bg_pressed(rgb(0,0,0)) // ← 押下で黒
        .fg(rgb(0,0,0)).fg_hover(rgb(0,0,0)).fg_pressed(rgb(255,255,255))        // ← 押下で白文字
        .border(1.5, rgb(0,0,0)).border_hover(rgb(0,0,0)).radius(8.0)            // ← 丸すぎ
        .press_scale(1.0).hover_duration(0.0)
}
pub fn button_theme_mac_classic_default() -> ButtonTheme {
    button_theme_mac_classic().border(3.0, rgb(0,0,0))
}
```

問題: (a) 押下で白黒反転（Platinum は反転しない、沈むだけ）、(b) 3D ベベルなし（Platinum の核を欠く）、(c) radius 8.0 は丸すぎ。

---

## 2. renderer 構造制約（コード読解、cargo なし）

出典: `crates/hayate-kit/src/widget/button.rs`（paint）。

| # | 制約 | 該当 | 影響 |
|---|------|------|------|
| 1 | **bevel は押下時に light↔dark を自動反転**（沈む効果）| L426-440, L472-477 | raised の 4 色だけ指定すれば pressed は自動。**追加フィールド不要** |
| 2 | **bevel は 4 辺を `fill_rect` の直線で描画し radius を無視**（body は rounded だが bevel は矩形）| L442-515 | **radius>0 + bevel = 角が破綻**。Win95 が radius 0 なのはこのため |
| 3 | **bevel(step5b) は border(step5) の後に描画**し外周 1px を上書き | L407-424→L426 | 別途 `.border()` のダーク輪郭は bevel に隠れて出ない |
| 4 | gradient 設定時、押下で top が bottom 方向へ lerp（0.6）し**わずかに沈む見え**になる | L380-385 | gradient face でも押下感は出る（bg_pressed は gradient 時不使用）|
| 5 | bevel テーマは focus 時に**点線フォーカス枠**（Win95 流）| L519-529 | Platinum でも点線フォーカスになる（許容、要 user 視覚確認）|

---

## 3. 即時実装案（radius 0、achievable now）

Win95 機構流用 + Platinum グレー（platinum.css 出典）+ 淡グラデ face。**白黒反転を廃止**。

```rust
/// Mac OS 9 Platinum push button — light-grey pillow face with a 2-stage
/// 3D grey bevel (light top-left / dark bottom-right = the canonical
/// Platinum raised convention, light source top-left). Pressing sinks the
/// bevel (renderer auto-inverts) and nudges the label 1px; it never flips
/// to black-on-white.
///
/// Grey values: mat-sz/platinum.css pixel-perfect recreation
/// (surface #DEDEDE / frame #CECECE / shadow #9C9C9C / outer-shadow #8C8C8C
/// / white #FFFFFF). 3D orientation (light TL / dark BR) per Inside
/// Macintosh "Platinum Appearance" light-source-top-left rule.
/// NOTE: radius is 0.0 because the bevel renderer draws square edges and
/// ignores corner radius (button.rs paint L442-515) — see draft §4-A for
/// the rounded-corner framework enhancement.
pub fn button_theme_mac_classic() -> ButtonTheme {
    ButtonTheme::new()
        // 淡グラデ pillow: near-white top → window-grey bottom（押下で僅かに沈む, L380-385）
        .gradient(Color::rgb(0xF0, 0xF0, 0xF0), Color::rgb(0xD6, 0xD6, 0xD6))
        // solid fallback (gradient 不使用パスのため一応指定)
        .bg(Color::rgb(0xDE, 0xDE, 0xDE))
        .bg_hover(Color::rgb(0xDE, 0xDE, 0xDE))
        .bg_pressed(Color::rgb(0xCC, 0xCC, 0xCC))
        // ★ fg は常に黒（押下でも白にしない = 反転廃止）
        .fg(Color::rgb(0, 0, 0))
        .fg_hover(Color::rgb(0, 0, 0))
        .fg_pressed(Color::rgb(0, 0, 0))
        .border(0.0, Color::rgba(0, 0, 0, 0))   // bevel に隠れるので border は使わない(§2-#3)
        .radius(0.0)                              // bevel と radius は両立不可(§2-#2)
        // 2-stage bevel: 外 TL=白 / 外 BR=#8C8C8C, 内 TL=#DEDEDE / 内 BR=#9C9C9C
        // Win95 より柔らかいグレー → Platinum らしさ（外 BR を黒でなく #8C8C8C に）
        .bevel(
            Color::rgb(0xFF, 0xFF, 0xFF), // outer light (TL highlight)
            Color::rgb(0x8C, 0x8C, 0x8C), // outer dark  (BR shadow)
            Color::rgb(0xDE, 0xDE, 0xDE), // inner light (TL)
            Color::rgb(0x9C, 0x9C, 0x9C), // inner dark  (BR)
        )
        .press_text_offset(1.0)  // 押下でラベル 1px シフト（沈む, 反転しない）
        .no_hover()              // classic Mac OS: ロールオーバー状態なし
        .hover_duration(0.0)
        .padding(14.0, 5.0)      // Mac ボタンは横 padding やや広め
        .font_size(12.0)         // Platinum システムフォント ~12pt
}
```

### default button（OK ボタン等）
真の Platinum default は**ボタン外周に隙間を空けた太いダークリング**。現 renderer では外周は bevel が上書きするため（§2-#3）、`.border()` での太枠は**出ない**。即時の差別化は限定的なので暫定案 + framework 要望（§4-C）の二段構え。

```rust
/// Platinum default button. 真の「外周リング」は framework 拡張待ち(§4-C)。
/// 暫定: 外 BR をより濃く + 内枠も濃くして「重い」印象に（リング代替）。
pub fn button_theme_mac_classic_default() -> ButtonTheme {
    button_theme_mac_classic().bevel(
        Color::rgb(0xFF, 0xFF, 0xFF),
        Color::rgb(0x60, 0x60, 0x60), // 外 BR をより濃く（重さ）
        Color::rgb(0xDE, 0xDE, 0xDE),
        Color::rgb(0x80, 0x80, 0x80), // 内 BR も濃く
    )
}
```
※ この暫定は「太リング」を完全には再現しない。**user 視覚確認で不足なら §4-C の framework 拡張を要請**。

---

## 4. framework 拡張要望（PRESIDENT/boss 判断、別 cargo）

即時案で「3D 沈み・Platinum グレー・反転廃止」は達成できるが、以下 3 点は renderer 構造の制約で実現不可。Platinum 完成度を上げるには framework 側の対応が要る。

- **A. radius 対応 bevel**: 現 bevel は矩形辺を描き radius 無視（§2-#2）。**rounded corner に沿う bevel** を描けるようにすれば、Platinum の「僅かに角丸（~3px）+ 3D」が両立。優先度: 中（角丸は Platinum の細部）。
- **B. 全周ダーク輪郭線**: Platinum ボタンは細い near-black の全周アウトライン + 内側 pillow。現状 border は bevel に上書きされる（§2-#3）。**border を bevel の後に描く / 専用 outer-frame** を追加すれば再現可。優先度: 中。
- **C. default button の外周リング**: ボタン本体の外に隙間を空けた太枠（OK ボタンの強調）。**body 外側に ring rect を描く capability** が必要。優先度: 低〜中（user が「OK が目立たない」と感じたら）。

※ A+B を入れれば、最終形は「radius 3.0 + 全周ダーク輪郭 + 内側 2-stage pillow bevel」= 真の Platinum push button。

---

## 5. 値の出典

- グレー実値（surface #DEDEDE / frame #CECECE / shadow #9C9C9C / outer-shadow #8C8C8C / white #FFFFFF / border #212121）: mat-sz/platinum.css `src/index.scss` https://github.com/mat-sz/platinum.css
- 3D 立体（light source 左上 = raised は light TL/dark BR）: Inside Macintosh "Platinum Appearance" https://dev.os9.ca/techpubs/mac/HIGOS8Guide/thig-8.html
- Platinum = Appearance Manager 既定・Charcoal: https://en.wikipedia.org/wiki/Platinum_(theme)
- renderer 機構（bevel 自動反転 / radius 無視 / 描画順）: GUI_kit `crates/hayate-kit/src/widget/button.rs` paint L372-529（コード読解）
- bevel API 4 層の意味: GUI_kit `crates/hayate-platform/src/widget_themes/button.rs` `bevel()` L287-299

---

## 6. user 視覚確認待ち事項（PRESIDENT が後で確認）

1. face グラデの強さ/向き: 案 = top #F0F0F0 → bottom #D6D6D6（淡）。platinum.css は #9C9C9C→#FFF（濃く 135°）。**淡 vs 濃 は user 判断**。
2. 外 BR シャドウ濃度: #8C8C8C（柔・Platinum らしい）か、より濃い #808080 か。
3. radius 0（即時）で許容か、§4-A 拡張を待って角丸 3px にするか。
4. default button の強調が暫定 bevel で足りるか、§4-C リングが要るか。
5. フォーカス点線枠（Win95 流, §2-#5）が Platinum で許容か。
6. font: 現状 cosmic-text(AA)。classic Mac は非 AA bitmap（Charcoal/Geneva）。crisp 化は worker3 の win95-font-draft と連動する別アセット判断。

---

## 7. 第2波スコープ整理

- **本ドラフト = button のみ**（最優先 per-theme）。titlebar 縞二色化・左右分割・scrollbar bevel・window frame は macos9-research.md §7-3 に記載済、別タスク/別 worker。
- 実装（cargo）は boss1 の解禁通知後、1 人ずつ。それまで本案は **review 用ドラフト**。
