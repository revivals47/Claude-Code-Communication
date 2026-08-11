# Phase 3b 第1波 調査 doc — Windows 95 深掘り refine (worker3)

作成: 2026-05-20 / 担当: worker3 / 状態: 調査のみ（実装・cargo 未実施）

## 0. 結論サマリ（PRESIDENT 向け要点）

Win95 の **パレット/ベベルは既に高忠実**（PRESIDENT 評価どおり）。web 調査の結果、当初「微差」とされた button 外BR の `#000 vs #0a0a0a` は**変更不要**と判定（理由は §5-A）。

代わりに「実物っぽくない」最大要因は **色ではなくフォントとそれに連動した寸法**、および**未再現の象徴要素**にある。優先度順:

1. **【最大】フォント**: 現状 `LEGACY_JP_16_PROP`（16px）。native Win95 UI は MS Sans Serif 約11px。16px が大きすぎてタイトルバー/メニューバーも native 18-19px → 22px に膨張させている（win95.rs のコメントが自認）。**フォントが大きい→chrome 全体が native より一回り大きい**のが第一印象のズレ。新規アセット是非は §3 で論点化。
2. **フォーカス矩形**: native は破線（dotted）矩形。現状は navy 2px ソリッドリング（focus_ring）。象徴的に違う。
3. **デフォルトボタンの黒枠**: native の既定ボタン（OK 等）は raised bevel の外側に 1px 黒枠。現状 win95 builder に default variant なし。
4. **タイトルバー**: native Win95 は**ソリッド紺**。現状は navy→#1084d0 グラデ（= Windows 98 の機能）。※titlebar は PRESIDENT 担当のため本 doc は調査のみ。
5. **無効テキストの彫り込み（engrave）**: native は grey + 白 1px ドロップシャドウ。現状 fg_muted=#808080 のみ。
6. 微調整: tooltip 黄色 `#FFFFE1 vs native #FFFFC0`、text `#000 vs 98.css #222`（§5 で扱う）。

色の改訂はごく僅か。**本命はフォント方針の決定**（user 視覚確認＋PRESIDENT 判断待ち）。

---

## 1. 実物の色実値（hex 一覧）

### 1-A. 98.css（jdan/98.css）= web 標準実装の照合基準
`style.css` の `:root` から実取得（出典 §6-①）:

| 変数 | hex | RGB |
|---|---|---|
| `--text-color` | `#222222` | 34,34,34 |
| `--surface` | `#c0c0c0` | 192,192,192 |
| `--button-highlight` | `#ffffff` | 255,255,255 |
| `--button-face` | `#dfdfdf` | 223,223,223 |
| `--button-shadow` | `#808080` | 128,128,128 |
| `--window-frame` | `#0a0a0a` | 10,10,10 |
| `--dialog-blue` | `#000080` | 0,0,128 |
| `--dialog-blue-light` | `#1084d0` | 16,132,208 |
| `--dialog-gray` | `#808080` | 128,128,128 |
| `--dialog-gray-light` | `#b5b5b5` | 181,181,181 |
| `--link-blue` | `#0000ff` | 0,0,255 |

> 注: 98.css は名前どおり **Windows 98** 寄り。`--surface #c0c0c0` がチャ面の塗り、`--button-face #dfdfdf` は raised bevel の**内側ハイライト**であり「ボタン塗り色」ではない（後述ベベル参照）。

### 1-B. native Win95 system color（Wine syscolor.c DefSysColors、出典 §6-②）
実 OS の `GetSysColor` 既定値（"Windows Standard" 系）。98.css と near だが差異あり:

| COLOR_* | RGB | hex | 用途 |
|---|---|---|---|
| BTNFACE (3DFACE) | 192,192,192 | `#C0C0C0` | チャ面 |
| BTNSHADOW (3DSHADOW) | 128,128,128 | `#808080` | 内側 BR 影 |
| BTNHIGHLIGHT (3DHIGHLIGHT) | 255,255,255 | `#FFFFFF` | 外側 TL 光 |
| 3DLIGHT | 192,192,192〜223,223,223※ | `#C0C0C0`/`#DFDFDF` | 内側 TL 光 |
| 3DDKSHADOW | 32,32,32 (Wine) | `#202020` | 外側 BR 最暗 |
| WINDOWFRAME | 0,0,0 | `#000000` | 枠線（最暗の典型値） |
| WINDOW | 255,255,255 | `#FFFFFF` | 入力欄/リスト背景 |
| WINDOWTEXT | 0,0,0 | `#000000` | 本文テキスト（**実機は純黒**） |
| GRAYTEXT | 128,128,128 | `#808080` | 無効テキスト |
| ACTIVECAPTION | 0,0,128 | `#000080` | アクティブタイトル（"Windows Standard"。Wine990815 は 0,64,128 と差） |
| INACTIVECAPTION | 128,128,128 | `#808080` | 非アクティブタイトル |
| INFOBK | 255,255,192 | `#FFFFC0` | tooltip 背景 |
| HIGHLIGHT | 0,0,128 | `#000080` | 選択ハイライト（"Windows Standard"） |
| HIGHLIGHTTEXT | 255,255,255 | `#FFFFFF` | 選択文字 |

※「最暗ベベル」値はソースで割れる: native WINDOWFRAME `#000000` / Wine 3DDKSHADOW `#202020` / 98.css window-frame `#0a0a0a`。**いずれも near-black で 1px 描画では視覚差ほぼゼロ**（§5-A の核心）。

---

## 2. font（名称・サイズ・太さ）

- native Win95 UI フォント = **MS Sans Serif**、UI 標準 = **8pt（96 DPI で約 11px 実描画）**、本文も同系。タイトル/メニュー/ダイアログ全て同一（出典 §6-③）。
- 技術形式 = **ラスター .FON**（ビットマップ、ベクターではない）。当時の小サイズで pixel-perfect。スケーラブル化は不可（DPI 変更時は別サイズの .FON を読み込む 8514 系）。
- 太さ: UI は regular。タイトルバー文字は bold 相当。

### 現 GUI_kit のフォント状況
- win95 系 builder は全て `LEGACY_JP_16_PROP`（**16px**）+ scale 1 を使用（button/check/menu/group_box/tooltip 等）。
- `widget/win95.rs` のコメントが自認:「TITLE_HEIGHT を native 18px → **22px に bump**。理由 = 16px bitmap font + 2px frame bevel で caption text が収まらないため」。MENU_BAR_HEIGHT も native 19 → 22、TITLE_BUTTON も 16×14 → 22×18 に拡大。
- **= 16px フォントが native（約11px）より大きい → タイトルバー/メニュー/ボタンが軒並み native より一回り大きい**。これが「Win95 っぽいが微妙に違う」第一印象の主因と推定。

---

## 3. フォントアセットの要否（論点整理 — 新規アセットは重いので別判断材料）

PRESIDENT 指示どおり「論点化のみ」。判断は user/PRESIDENT。3 案を提示:

### 案 A: 現状維持（LEGACY_JP_16_PROP 16px）
- 利点: 追加アセットゼロ。日本語表示も既に可能。
- 欠点: native より大きい寸法が固定化。タイトル/メニュー/ボタンが膨張。最も「実物っぽくない」要因が残存。

### 案 B: 既存 bitmap_font 資産で ~11-12px の小型フォントを採用
- `bitmap_font` モジュールに 11-12px 級のグリフ（Spleen/Shinonome 等の小サイズ）が既にあれば、それを win95 系 builder に割り当て、TITLE/MENU 高さを native 18-19px に戻す。
- 利点: 新規アセット追加なし（既存資産の活用のみ）。寸法を native に近づけられる。
- 欠点: 既存資産に適切な小サイズ・字形があるか要確認（worker は GUI 確認不可なので**user 視覚確認必須**）。日本語グリフ網羅の確認も要。
- **要事前調査**: `hayate_platform::render::bitmap_font` に LEGACY_JP_16_PROP 以外の小型フォント定数が存在するか（本 doc では未確認、第2波着手前に grep 推奨）。

### 案 C: MS Sans Serif 互換の新規アセット導入
候補（いずれも SIL OFL = 商用可、出典 §6-④）:
- **W95FA**（Alina Sava）: MS Sans Serif 再現の OTF/WOFF。「pixel style」だが**ベクター**（真のビットマップではない）→ 小サイズで pixel-grid に厳密一致しない懸念。
- **React95 R95-Sans-serif**: 同系の MS Sans Serif port。
- 利点: 字形が native に最も近い。
- 欠点: (1) **新規アセット = リポジトリ重量増**（PRESIDENT が「重いので別判断」と明示）。(2) ベクターのため GUI_kit の既存 `bitmap_font`（ビットマップアトラス前提）パイプラインと不整合 → ベクターフォントレンダラ経路が必要 or 事前ラスタライズしてアトラス化する工数。(3) 日本語グリフ別途（W95FA は Latin Extended のみ）→ 和文は別フォント併用が必要で、Win95 和文（MS ゴシック系）との二重管理。

### worker3 推奨の検討順
**案 B を第一候補に調査** → 既存資産で 11-12px が出せれば寸法を native 化でき、アセット重量増なし。出せない場合のみ 案 C を費用対効果で再評価。案 A は「色だけ詰めても寸法で実物感が出ない」ため非推奨。**最終はフォント実物を user が視覚確認して決定**。

---

## 4. 角丸 / border / bevel 構成（raised/sunken 各層の色とオフセット）

### 4-A. 98.css のベベル定義（box-shadow、出典 §6-①、verbatim）
CSS の inset box-shadow は `inset <x> <y> <color>`。`-1px -1px` = 右下(BR)辺、`1px 1px` = 左上(TL)辺。

**raised button（通常）= 4 層:**
```
border-raised-outer: inset -1px -1px #0a0a0a (window-frame)  ← 外BR
                     inset  1px  1px #ffffff (button-highlight) ← 外TL
border-raised-inner: inset -2px -2px #808080 (button-shadow)  ← 内BR
                     inset  2px  2px #dfdfdf (button-face)     ← 内TL
```
→ (外TL, 外BR, 内TL, 内BR) = (`#ffffff`, `#0a0a0a`, `#dfdfdf`, `#808080`)

**pressed/active button = raised を反転:**
```
border-sunken-outer: inset -1px -1px #ffffff ← 外BR
                     inset  1px  1px #0a0a0a ← 外TL
border-sunken-inner: inset -2px -2px #dfdfdf ← 内BR
                     inset  2px  2px #808080 ← 内TL
```
→ (外TL, 外BR, 内TL, 内BR) = (`#0a0a0a`, `#ffffff`, `#808080`, `#dfdfdf`)

**field（入力欄）の sunken = 4 層（raised と層構成が異なる）:**
```
border-field: inset -1px -1px #ffffff (button-highlight) ← 外BR
              inset  1px  1px #808080 (button-shadow)     ← 外TL
              inset -2px -2px #dfdfdf (button-face)        ← 内BR
              inset  2px  2px #0a0a0a (window-frame)       ← 内TL
```
→ (外TL, 外BR, 内TL, 内BR) = (`#808080`, `#ffffff`, `#0a0a0a`, `#dfdfdf`)

**default button（既定ボタン、OK 等）= raised + 外周 1px 黒枠:**
```
default-button-border-raised-outer: inset -2px -2px #0a0a0a, inset 1px 1px #0a0a0a
default-button-border-raised-inner: inset 2px 2px #ffffff, inset -3px -3px #808080, inset 3px 3px #dfdfdf
```
→ 通常 raised の外側に 1px の `#0a0a0a` 枠が回り込む（**現 GUI_kit に未実装**）。

### 4-B. radius
全要素 radius 0（角丸なし）。GUI_kit WIN95_THEME も `border_radius*: 0.0`、各 win95 builder も radius 0 → **一致（OK）**。

---

## 5. 現 GUI_kit 定義との差分一覧

凡例: ✅=一致 / 〜=near（視覚差ほぼ無） / ✗=要検討。

### 5-A. button_theme_win95（button.rs:108）
現 `.bevel(外TL=255,255,255 / 外BR=0,0,0 / 内TL=223,223,223 / 内BR=128,128,128)`

| 層 | GUI_kit | 98.css | native | 判定 |
|---|---|---|---|---|
| 外TL | `#ffffff` | `#ffffff` | `#ffffff` | ✅ |
| 外BR | `#000000` | `#0a0a0a` | `#000000`(WINDOWFRAME)〜`#202020`(3DDKSHADOW) | 〜 |
| 内TL | `#dfdfdf` | `#dfdfdf` | `#c0c0c0`〜`#dfdfdf` | ✅ |
| 内BR | `#808080` | `#808080` | `#808080` | ✅ |

**核心判断 — 外BR `#000 vs #0a0a0a` は変更不要**:
- native の最暗ベベルは WINDOWFRAME `#000000`（純黒）。98.css の `#0a0a0a` はむしろ web 用の softening。
- 「実物っぽい」を求めるなら**純黒 `#000000` は native 忠実で正当**。
- かつ {`#000`,`#0a0a0a`,`#202020`} の差は 1px ラインでは**視覚的に判別不能**。
- → **現状維持を推奨**。98.css と機械的に揃えたいだけなら `#0a0a0a` に変えても可だが視覚利得ゼロ。

その他 button: bg `#c0c0c0` ✅（98.css のボタン塗り = surface c0c0c0 と一致。`#dfdfdf` はベベル内TL であり塗りではない）。no_hover ✅、press_text_offset 1.0 ✅、radius 0 ✅。
- ✗ **default button variant 未実装**（§4-A の外周黒枠）。`button_theme_win95_default()` 追加候補。
- ✗ font（§2/§3）。padding(10,4) は font 16px 前提なので font 改訂時に再調整要。

### 5-B. input_theme_win95（input.rs:72）
現 `.sunken_bevel(外TL=128,128,128 / 外BR=255,255,255 / 内TL=0,0,0 / 内BR=223,223,223)`
98.css field = (外TL=`#808080`, 外BR=`#ffffff`, 内TL=`#0a0a0a`, 内BR=`#dfdfdf`)

| 層 | GUI_kit | 98.css | 判定 |
|---|---|---|---|
| 外TL | `#808080` | `#808080` | ✅ |
| 外BR | `#ffffff` | `#ffffff` | ✅ |
| 内TL | `#000000` | `#0a0a0a` | 〜（§5-A 同様、変更不要） |
| 内BR | `#dfdfdf` | `#dfdfdf` | ✅ |

selection `#000080` ✅、bg white ✅、radius 0 ✅。**実質一致、改訂不要**。

### 5-C. check_theme_win95（check.rs:69）
sunken_bevel は input と同パターン（128/255/0/223）、size 13px ✅（native 13×13）、checkmark 黒 ✅。**一致**。内TL `#000 vs #0a0a0a` のみ（§5-A、変更不要）。font 改訂は連動。

### 5-D. titlebar_theme_win95（titlebar.rs:13）※PRESIDENT 担当、調査のみ
- bg `#000080` ✅、title white bold ✅、button_bevel true ✅、close `×`/max `□`/min `─` ✅。
- ✗ `bg_gradient_bottom = #1084d0`（navy→水色グラデ）。**native Win95 はソリッド紺**。グラデは **Windows 98 で導入された機能**（OSR2 含む Win95 全版はソリッド。出典 §6-⑤）。
  - → 「Windows 95」を名乗るならグラデを切って**ソリッド `#000080`**が忠実。「クラシック Windows 体験」としてグラデ容認なら現状可。**user/PRESIDENT 判断事項**。98.css がグラデなのは "98" だから。
- ✗ inactive title 未表現（native = `#808080` + 文字 `#c0c0c0`）。`set_theme` 連動と合わせ PRESIDENT スコープ。
- height 22 / button 22×18 は font 16px 連動（§2）。font 改訂で native 18px 系に戻せる。

### 5-E. tooltip_theme_win95（tooltip.rs:14）
bg `#FFFFE1`(255,255,225)、native COLOR_INFOBK = `#FFFFC0`(255,255,192)。〜 僅差。忠実重視なら `#FFFFC0` に。border 黒 1px ✅、radius 0 ✅、shadow 0 ✅。

### 5-F. menu_theme_win95（menu.rs:11）
bar navy open ✅、etched separator ✅、panel black border + bevel ✅。**良好**。font 16px 連動で bar_height 22（native 19）。

### 5-G. scroll_bar_theme_win95（scroll_bar.rs:13）
dither track + raised thumb bevel + arrow caps bevel ✅。色は BUTTON_* 定数（c0c0c0/fff/dfdfdf/808080/000）。**良好**。

### 5-H. group_box_theme_win95（group_box.rs:13）
etched frame（shadow `#808080` + highlight `#fff`）✅、label 黒 ✅。**良好**。font 16px 連動。

### 5-I. WIN95_THEME palette（theme.rs:262）
- bg_primary/secondary/tertiary `#c0c0c0` ✅、bg_surface white ✅。
- fg_primary `#000000`: native WINDOWTEXT = 純黒で ✅（98.css の `#222` は web softening。**実機忠実は純黒**なので現状維持推奨）。
- accent `#000080` ✅、fg_muted `#808080` ✅、selection_overlay navy ✅。
- ✗ **focus_ring_color `#000080` 2px ソリッド**: native は**破線（dotted）矩形**（黒 or 反転ドット、出典 §6-⑥）。象徴的差異。framework が dotted focus rect を描けるか要確認（描けないなら別途 PRESIDENT 相談 = framework 機能）。

---

## 6. 改訂案（まとめ）

### 6-A. 即適用可（color、低リスク・視覚利得小〜中）
1. tooltip_theme_win95 bg: `#FFFFE1` → **`#FFFFC0`**（native COLOR_INFOBK 一致）。利得小。
2. button 外BR / input 内TL / check 内TL の `#000`→`#0a0a0a`: **非推奨**（§5-A、視覚利得ゼロ・native 忠実はむしろ純黒）。98.css と機械一致させたい場合のみ。
3. fg_primary / text の純黒維持: **現状維持**（native 忠実）。98.css `#222` には寄せない。

### 6-B. 象徴要素の追加（中リスク、視覚利得大）
4. **default button variant 追加**: `button_theme_win95_default()` = raised + 外周 1px 黒枠（§4-A）。OK/既定ボタン用。framework が外周追加枠を描けるか要確認。
5. **dotted focus rectangle**: focus 表現を navy ソリッドリング → 破線矩形へ。**framework 機能の有無を要確認**（描画経路が無ければ PRESIDENT スコープ）。
6. **無効テキストの engrave**: disabled = `#808080` + 白 1px ドロップシャドウ。widget theme で表現可能か要確認。

### 6-C. 本命（要 user/PRESIDENT 判断、視覚利得最大）
7. **フォント方針**（§3）: 案 B（既存資産で ~11-12px）を第一調査 → 寸法を native（TITLE 18 / MENU 19px 系）に是正。アセット重量増なし。出せなければ案 C を費用対効果で再評価。**実物の見た目は user 視覚確認で確定**。
8. **タイトルバー ソリッド化**（PRESIDENT 担当）: グラデ廃止 → ソリッド `#000080`（Win95 忠実）。「クラシック体験」優先ならグラデ容認も選択肢。

### 優先度
最大利得 = **7（フォント）> 5（focus dotted）> 4（default button）> 8（titlebar、PRESIDENT）**。色補正（1,6B-6）は低利得。**「Win95 のパレット/ベベルは高忠実」評価は正しく、詰めるべきは色ではなく font と象徴 detail**。

---

## 7. 出典 URL

- ① jdan/98.css `style.css`（palette + bevel box-shadow、verbatim 取得）: https://raw.githubusercontent.com/jdan/98.css/main/style.css （リポジトリ: https://github.com/jdan/98.css ）
- ② Wine `windows/syscolor.c`（DefSysColors 既定値、native system color 照合）: https://goma.googlesource.com/wine/+/wine-990815/windows/syscolor.c
- ③ MS Sans Serif（Win95 既定 UI フォント、8pt ラスター .FON）: https://en.wikipedia.org/wiki/Microsoft_Sans_Serif / https://www.aeanet.org/what-font-does-windows-95-use/
- ④ フォント代替アセット: W95FA https://fontsarena.com/w95fa-by-alina-sava/ ／ React95 R95-Sans-serif https://github.com/React95/R95-Sans-serif
- ⑤ タイトルバー グラデは Win98 の機能（Win95 は OSR2 含めソリッド）: https://www.betaarchive.com/forum/viewtopic.php?t=38981 / https://msfn.org/board/topic/184433-windows-95-gradient-title-bars-osr2/
- ⑥ Universal Focus Rectangle（破線フォーカス矩形）: https://www.askvg.com/how-to-remove-the-annoying-focus-rectangle-in-windows/
- ⑦ GetSysColor / COLOR_* 索引（Microsoft Learn）: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor
- 参考（cross-ref、未一次採用）: Chicago95 https://github.com/grassmunk/Chicago95

## 8. 制約遵守メモ
- 記憶ベース実装なし。全数値は §7 の web 一次調査から。出典明記済。
- 実装・cargo 一切未実施（調査のみ）。
- 視覚判定（フォント字形・寸法・グラデ可否）は user 確認事項として明示。
- titlebar 紺バー連動は PRESIDENT 担当 → 調査のみ・実装せず（§5-D）。
