# Phase 3b 第2波 ドラフト — Win95 フォント案B 実現性調査 (worker3)

作成: 2026-05-20 / 担当: worker3 / 状態: grep + ドラフトのみ（**cargo 一切未起動**、build/test/run 禁止厳守）

関連: 第1波 `workspace/phase3b/win95-refine-research.md` §2/§3（Win95 の真のギャップ = 色でなく font 16px による chrome 膨張）

---

## 0. 結論サマリ（PRESIDENT 向け要点）

**「既存資産だけで 11-12px」は出せない。** GUI_kit の bitmap_font 既存定数は **8px か 16px のみ**で、11-12px の単独定数は存在しない（§1）。完結した日本語対応の最小定数は **8px の `LEGACY_JP_8X8_PROP`**。

ただし **Shinonome 12×12 は既に embed 済み**（現状は 16 行に padding されて JP 側だけ使用）。これを活かせば **真の 12px** が**最小コスト**で作れる。3 案を提示:

| 案 | 内容 | 新規アセット | 寸法 | native 一致度 | 工数 |
|---|---|---|---|---|---|
| **B1** | 既存 `LEGACY_JP_8X8_PROP`（8px）に差替 | **ゼロ** | 8px（native 11px より小） | △ 小さめ・漢字8×8は窮屈 | 最小 |
| **B2** (推奨) | Spleen **6×12** BDF 1 本追加 + Shinonome 12×12（embed済）と組む **新 12px compound** 定数 | 小 1 本（~数十KB、BSD-2） | **12px = native 一致** | ◎ | 中（build.rs emitter + 定数 + 差替） |
| C | W95FA 等ベクター再現導入 | 大 + 新レンダラ経路 | 任意 | ○字形 | 大 |

**worker3 推奨 = B2。** 「純粋に既存資産のみ」という案B原義では 8px(B1) しか出せず native(11-12px) に届かない。Shinonome 12×12 が既に手元にあるため、ASCII 側 12px(Spleen 6×12) を 1 本足すだけで native 寸法の 12px compound が成立する。これが「重いアセット追加(案C)」を避けつつ native 化する最短路。

**最終のフォント字形・寸法（8px vs 12px の見え方、漢字の可読性、タイトル/メニュー高さの実機印象）は user 視覚確認事項**（§5）。worker は GUI を見られない。

---

## 1. bitmap_font モジュール grep 結果（既存フォント定数の全数）

モジュール: `crates/hayate-platform/src/render/bitmap_font.rs`（1190 行）
embed アセット: `crates/hayate-platform/assets/fonts/`（build.rs が BDF → Rust 配列に変換）

### 1-A. 既存 `pub static BitmapFont` 定数（全 4 件）

| 定数 | 行 | cell_w×cell_h | ASCII 字形 | 日本語 | JP 被覆 |
|---|---|---|---|---|---|
| `LEGACY_8X8` | 293 | 8×**8** | font8x8 BASIC_LEGACY（monospace） | ✗ なし | — |
| `LEGACY_8X8_PROP` | 305 | 8×**8** | font8x8（proportional、MS Sans Serif 風間隔） | ✗ なし | — |
| `LEGACY_JP_8X8_PROP` | 328 | 8×**8** | font8x8（proportional） | ✅ Misaki-gothic 8×8 | JIS X 0208 第1/第2水準 + 半角カナ |
| `LEGACY_JP_16_PROP`（**現 win95 使用**） | 392 | 8×**16** | Spleen 8×16 + Latin-1 | ✅ Shinonome 12×12（16行に padding） | JIS X 0208 |

### 1-B. embed 済み BDF アセット（build.rs:34-36, 49-72）

| BDF | 実セル | 生成定数 | 被覆 | ライセンス |
|---|---|---|---|---|
| `misaki_gothic.bdf` | 8×8（ASCENT6/DESCENT2） | `MISAKI_GOTHIC_GLYPHS` | ≥U+0080 JP 7k字 | unlimited permission（商用可） |
| `spleen-8x16.bdf` | 8×16 | `ENGLISH_SPLEEN_16_GLYPHS` | U+0020–00FF | BSD-2-Clause |
| `shinonome12_gothic.bdf` | **12×12** | `SHINONOME_12_GLYPHS` | ≥U+0080 JIS X 0208 | 公開ドメイン |

### 1-C. 決定的所見
- **glyph 高さの実在値は 8 / 12 / 16 のみ**。scale は整数倍のみ（8→16→24）なので 11-12px を scale で作ることは不可能。
- **11-12px の単独 BitmapFont 定数は存在しない。**
- **Shinonome は 12×12（= 12px、native MS Sans Serif にほぼ一致）**だが、現状 `LEGACY_JP_16_PROP` の JP 側専用で、ペアの ASCII が Spleen 8×16(16px) のため 16 行セルに padding されて「12px として独立利用」されていない。
- **12px の ASCII ビットマップが embed されていない**（ASCII は font8x8=8px か Spleen=16px の二択）。これが「既存資産だけで 12px が出せない」根本理由。

---

## 2. win95 builder 群の font 使用箇所（差替対象の file:line）

font は **2 層構造**:
- **グローバル default**: `app.rs:98` `app_theme_win95()` の `bitmap_text_default = BitmapTextStyle::with(LEGACY_JP_16_PROP, 1)`
- **各 leaf override**（明示指定。これがある leaf はグローバルを上書き）:

| file | line | 指定 |
|---|---|---|
| `widget_theme_presets/app.rs` | 98-100 | `bitmap_text_default` = LEGACY_JP_16_PROP, 1（グローバル） |
| `widget_theme_presets/button.rs` | 129 | `.bitmap_font(LEGACY_JP_16_PROP, 1)` |
| `widget_theme_presets/check.rs` | 86 | `.bitmap_font(LEGACY_JP_16_PROP, 1)` |
| `widget_theme_presets/group_box.rs` | 22 | `.bitmap_font(LEGACY_JP_16_PROP, 1)` |
| `widget_theme_presets/radio.rs` | 35 | `.bitmap_font(LEGACY_JP_16_PROP, 1)` |
| `widget_theme_presets/tab.rs` | 100 | `.bitmap_font(LEGACY_JP_16_PROP, 1)` |
| `widget_theme_presets/dropdown.rs` | 104 | `.bitmap_font(LEGACY_JP_16_PROP, 1)` |
| `widget_theme_presets/menu.rs` | 39-41 | `BitmapTextStyle::with(LEGACY_JP_16_PROP, 1)` |
| `widget_theme_presets/tooltip.rs` | 25-27 | `BitmapTextStyle::with(LEGACY_JP_16_PROP, 1)` |

→ font 差替は **計 9 サイト**。グローバル(app.rs)だけ変えても override 持ち leaf は変わらないため、**(a) 全 9 サイトを新フォントへ repoint** か **(b) override を削除してグローバル継承に一本化**（後者は `resolve()` 継承で行数削減、cohesion 良）。worker3 推奨 = **(b) 寄り**（leaf override は「win95 は全部同じ font」なら冗長）。ただし resolve 挙動の回帰確認が必要なので実装解禁後 cargo verify。

---

## 3. 案B 採用時の具体実装方針

### 3-A. B2（推奨）= 真の 12px compound 新設

**新規アセット（最小）**: `assets/fonts/spleen-6x12.bdf`（fcambus/spleen の 6×12、BSD-2-Clause = 既存 spleen-8x16 と同ライセンス。6×12 は Basic Latin + Latin-1 を被覆。出典 §6）。サイズ ~数十KB（8×16 の 153KB より小）。

**build.rs**: 既存「16-row generic emitter」(build.rs:234-) を流用しつつ **cell_h=12 の 12-row emitter** を追加。Spleen 6×12 → `ENGLISH_SPLEEN_12_GLYPHS`（cell_w=6, cell_h=12）。Shinonome 12×12 は**既に 12 行で素直に入る**（現状 16 行 padding が不要になり、むしろ自然）。

**新定数**（bitmap_font.rs）:
```
pub static LEGACY_JP_12_PROP: BitmapFont = BitmapFont {
    glyphs: GlyphData::Rows16(&SPLEEN_DENSE_12),  // 6×12 ASCII dense
    cell_w: 6, cell_h: 12,
    widths: Some(&SPLEEN_WIDTHS_12),
    extra_glyphs: Some(ExtraGlyphs::Rows16(SHINONOME_12_GLYPHS)),  // 既存流用
};
```
（注: Rows16 は u16 セルなので 6px/12px 幅も格納可。GlyphData は cell_h で高さ管理。実装時に dense pack 関数 `pack_spleen_12_*` を 8×16 版に倣って追加。）

**寸法 native 化**（`widget/win95.rs` 定数。SM_CY* native 値に戻す）:
| 定数 | 現値 | B2 提案 | native 根拠 |
|---|---|---|---|
| `TITLE_HEIGHT` | 22.0 | **18.0** | SM_CYCAPTION=18 ※titlebar 連動 = PRESIDENT 調整事項 |
| `MENU_BAR_HEIGHT` | 22.0 | **19.0** | SM_CYMENU=19 |
| `TITLE_BUTTON_W` | 22.0 | **16.0** | native 16×14 |
| `TITLE_BUTTON_H` | 18.0 | **14.0** | native 16×14 |
| `STATUS_BAR_HEIGHT` | 22.0 | 20.0 | 12px+余白 |
| `SCROLLBAR_THICKNESS` | 16.0 | 16.0（据置） | SM_CXVSCROLL=16 既に native |

**leaf 寸法・font_size 再調整**（16px 前提値の見直し）:
- `button.rs` `.padding(10.0, 4.0)` → 12px 用に `(8.0, 3.0)` 程度、`.font_size(11.0)` は据置〜12。
- `menu.rs` `item_height 20.0` → 18.0、`bar_height` は MENU_BAR_HEIGHT 連動。
- `check.rs` `.size(13.0)` 据置（native 13×13、font 非依存）。
- 各 builder の `font_size` は bitmap 不在時の cosmic-text fallback サイズ。bitmap 有効時は実描画に不使用だが、11-12 に揃えて整合。

### 3-B. B1（ゼロアセット）= 既存 8px へ差替

§2 の 9 サイトを `LEGACY_JP_8X8_PROP`（8px）へ。`win95.rs` 寸法は 8px に合わせ更に縮小可（TITLE ~14, MENU ~14-16）。
- 利点: アセット追加ゼロ・即着手可。
- 欠点: (1) 8px < native 11px で全体が小さい。(2) **漢字が 8×8 で窮屈**（Misaki 8×8、可読性は user 判断）。(3) native 18px chrome を保つと 8px text が浮く / proportions 維持なら絶対サイズが native より小。

### 3-C. C（重）= ベクター再現
W95FA 等。新レンダラ経路（bitmap_font はビットマップアトラス前提でベクター非対応）+ 和文別フォント二重管理 + リポジトリ重量増。**非推奨**（B2 で目的達成可能なため）。

---

## 4. 「既存資産で 11-12px が出せない場合の所見」（案C 再評価の要否）

- **純既存資産のみ（B1）では 11-12px は出せない**（8px が上限の小型）。→ この事実は確定。
- ただし **案C 全面採用は不要**。Shinonome 12×12 が既 embed のため、**Spleen 6×12 BDF 1 本（小・同ライセンス）追加（B2）で native 12px が成立**。これは「重いアセット追加」に当たらない（数十KB・既存ビットマップ経路再利用・新レンダラ不要）。
- したがって **案C 再評価は不要**。判断軸は「B1（8px・ゼロアセット）か B2（12px・小アセット1本）か」に収斂する。これは主に**見た目の好み**（小さめのレトロ感 vs native 寸法忠実）= **user 視覚確認**で決まる。

---

## 5. user 視覚確認事項（worker・PRESIDENT は GUI を見られないため明記）

1. **8px(B1) vs 12px(B2) の見え方**: どちらが「実物 Win95 らしい」か。native は ~11px なので理屈上 B2 が忠実だが、最終は実機印象。
2. **漢字の可読性**: B1 は Misaki 8×8（窮屈）、B2 は Shinonome 12×12（明瞭）。日本語 UI 主体なら B2 有利と推測。
3. **タイトル/メニュー高さ**: 22px → 18-19px(native) に下げた時の窮屈感の有無（特に 16px bitmap で「収まらない」と判断した経緯があるため、12px なら収まるかは実機確認）。
4. **タイトルバー高さは PRESIDENT 担当**: `TITLE_HEIGHT` は `titlebar_theme_win95`(titlebar.rs:14) が消費。PRESIDENT のタイトルバー機構実装と**競合・連動するため、worker は TITLE_HEIGHT を単独変更しない**。menu/button 側の高さ調整に留め、TITLE 系は PRESIDENT と調整。

---

## 6. 出典 URL
- Spleen bitmap font（6×12 含む全サイズ・BSD-2-Clause・Basic Latin/Latin-1 被覆）: https://github.com/fcambus/spleen ／ 6×12 BDF: https://github.com/fcambus/spleen/blob/master/spleen-6x12.bdf ／ https://www.cambus.net/spleen-monospaced-bitmap-fonts/
- native chrome metrics（SM_CYCAPTION=18 / SM_CYMENU=19 / SM_CXVSCROLL=16）+ MS Sans Serif: 第1波 doc §2 出典（Microsoft Learn GetSystemMetrics / MS Sans Serif Wikipedia）を継承。
- GUI_kit 内部（grep、本 doc §1/§2 の file:line）: 一次は実コード。

## 7. 制約遵守メモ
- **cargo 一切未起動**（grep + web + doc のみ）。PRESIDENT のタイトルバー cargo -j1 並行実装と非競合。
- 記憶ベースなし。font 定数・アセット・file:line は全て実 grep。Spleen サイズ展開は web 出典明記。
- 実装解禁は boss1 通知待ち。解禁後の cargo verify 項目: (a) 新 build.rs emitter の 12-row 出力、(b) resolve() 継承挙動（override 削除案 (b) 採用時）、(c) 既存 16px 利用箇所への非回帰。
- TITLE_HEIGHT は PRESIDENT スコープのため単独変更せず調整事項として明示（§5-4）。
- フォント字形・寸法の最終可否は user 視覚確認（§5）。
