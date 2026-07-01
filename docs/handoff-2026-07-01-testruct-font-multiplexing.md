# Handoff 2026-07-01 (work-PC) — testruct フォント複数化 (FontPicker) F1-F5 全完遂

## 概要
user 要望「フォント複数化」。testruct を 1 書体 (Noto Sans JP) から **3 family × Regular/Bold** へ拡張し、per-element FontPicker + screen↔PDF real Bold 一貫を実現。PRESIDENT→boss1 dispatch、worker1 が F1-F5 逐次 PR chain (共有 file=font.rs/map_family/pdf_text ゆえ single-author 継続)。

## 着地 sha chain (testruct main = e331e97)
- **F1** `2b3757f` bundle 丸ゴ+明朝 + SSOT registration (BUNDLED_FONTS 単一 list + helper 2 で 6 site iterate、旧 BUNDLED_SANS 統合、latent 登録漏れ class 閉塞)
- **F2** `fe83f7d` map_family routing (FAMILY_* const 昇格 + 既知 family→Named、非match→SansSerif=parity anchor) + render 実証。**F4** (PDF multi-embed) は F2 検証で達成 (FontId two-pass 自動 embed)
- **F3** `a46261e` FontPicker (inspector 3 ボタン 角ゴ/丸ゴ/明朝 + SetFontFamily + TextStyleCommand 再利用 undo + ★active=map_family 解決後比較)
- **F5a** `3e5457d` screen real Bold (3 Bold face bundle、RIBBI、bundle-only code ゼロ、B ボタン自動太字)
- **F5b** `8378595` PDF real Bold (pdf shaping に weight 配線 + synthetic FillStroke 条件化 + real Bold face embed)

## 成果 (フォント複数化 全完遂)
- **3 family**: 角ゴ=Noto Sans JP / 丸ゴ=Zen Maru Gothic / 明朝=Noto Serif JP、各 **Regular+Bold** (計 6 face)。
- **per-element FontPicker**: inspector フォント section の 3 ボタン、1-click 切替、active=実描画書体を map_family 解決後で highlight。太字は既存 B ボタン (weight 軸)。
- **screen+PNG+PDF real Bold 一貫**: RIBBI (同 family 名 weight 違い) で fontdb が weight=700 時 Bold face 自動選択。PDF も weight 配線で real Bold embed (合成 stroke 廃止、条件化で fallback 時のみ synthetic)。
- **SSOT 貫通**: `BUNDLED_FONTS`(登録6)/`FAMILY_*`(語彙3)/`FONT_CHOICES`(picker3) = font.rs 単一 source。BUNDLED_FONTS≠FONT_CHOICES 分離 (Bold=weight 軸、picker family でない)。
- **parity 厳守**: map_family 既定枝 (非mono→SansSerif) 不変で Regular 経路 byte-exact。kokugo (Regular-only) fixture が全段 byte-identical (対照群)。

## font sourcing (全 OFL・RFN なし、_font_stage staging、FONT_PROVENANCE.md)
| face | size | sha256(head) | 加工 |
|---|---|---|---|
| NotoSansJP-Regular.otf | 4.53MB | dff723ba | 既存 |
| ZenMaruGothic-Regular.ttf | 3.83MB | a0c0b535 | official 無改変 |
| NotoSerifJP-Regular.ttf | 8.08MB | 6ec460b7 | variable wght400 instance + RIBBI name-fix |
| NotoSansJP-Bold.ttf | 5.76MB | a4b563fe | variable wght700 instance + RIBBI name-fix + BOLD bits |
| ZenMaruGothic-Bold.ttf | 3.78MB | fe24426b | official static Bold 無改変 |
| NotoSerifJP-Bold.ttf | 8.07MB | 2d10098c | variable wght700 instance + RIBBI name-fix + BOLD bits |
- 計 bundle ~34MB。Noto instance は fontTools varLib.instancer + name-table 修正 (family=Regular同名/subfamily=Bold/usWeightClass700/fsSelection BOLD/macStyle bold) で RIBBI 成立。全 OFL に Reserved Font Name なし=改変/instance/rename 可を確認。

## grounding が捕捉した premise 訂正・learning (6+)
1. **F1 多 site**: with_font_data/load_font_data は main + PDF/PNG engine 全 5 site。SSOT list iterate で登録漏れ構造閉塞。
2. **parity anchor**: fixture は HiraginoSans (Mac 名)、「Sans」literal でなく「非mono→SansSerif 既定枝」不変が anchor。
3. **F5 weight 配線**: screen は end-to-end 配線済 (B→weight700→fontdb Bold 選択、bundle-only)。★PDF は未配線 (default axes + fake stroke) ゆえ code 要。
4. **FontEditCommand 不要**: font_family は TextStyle mutation、既存 edit_text_style+TextStyleCommand で undo 無料。
5. **★UX 補正 (PRESIDENT catch)**: picker active は生文字列でなく map_family 解決後比較 ('Sans'≡'Noto Sans JP'≡SansSerif 吸収)、既定要素も正しく active。
6. **★premise-learning (F5a)**: dispatch 前提「fixture=全 Regular」は誤り (english 18 Bold / april 32 Bold)。→ ★parity 前提は fixture の実 weight/family を grep 事前確認すべき。english/april の diff は Bold 要素のみ局在 (kokugo=Regular-only IDENTICAL が Regular 不汚染を厳密証明) = 意図した upgrade (screen が Bold を flat 描画していた latent 限界を根治)。
7. **★premise-learning (F5b mono)**: 「mono+bold→synthetic stroke 維持」は不正確、実は fontdb fallback で real bold face を拾う (flat 化せず、'2 Tr'=0)。synthetic 安全網は regular-face+weight700 で発火を決定的 unit test 実証。

## dogfood 成果 (framework/設計 観点)
- **map_family = 単一 choke point** (screen+PNG+PDF)、FontId two-pass で PDF 自動 multi-embed → routing 1 箇所で全経路追従の綺麗な設計を実証。
- **RIBBI** (同 family 名 weight 違い) で fontdb が weight 自動選択 = distinct family 不要の正道を確認。
- **synthetic bold が real bold gap を隠していた**: screen が weight700 を no-op (flat) 描画、PDF は fake-stroke。F5 で両者 real Bold face へ、screen↔PDF 一貫化。既存 fixture の Bold text が初めて本物太字に。

## backlog (silent drop 防止、必要時着手・投機しない)
- **SVG limitation**: svg_painter は raw family 名を SVG へ出力 (font 埋込せず)、viewer に Zen Maru/Serif 無いと fallback。routing 外、v1 scope 外。
- **pdf_font.rs:122 BaseFont mislabel**: PDF BaseFont 名を全 face 'NotoSansJP' hardcode = cosmetic (embed outline/選択は正常)。multi-font/Bold で face 種類増ゆえ修正価値 再評価候補。
- **(B) 自作 dropdown** / **(C) GUI_kit DropdownWidget**: family 数増時の picker UX (現 3 は button 列で十分)。
- **woff2 圧縮 bundle**: repo ~34MB を decompress 依存で ~40% 化 (v2 最適化)。
- **weight 以外の軸**: italic 等 (未要望)。

## ★memory mirror 用要点 (PRESIDENT が canonical へ反映用)
PRESIDENT 側で **project_hayate_kit_testruct** に F1-F5 追記 + **reference_guikit_font_resolution** 更新。要点:
- testruct フォント: 3 family (角ゴ Noto Sans JP / 丸ゴ Zen Maru Gothic / 明朝 Noto Serif JP) × R/B、per-element picker (inspector 3 button)、screen↔PDF real Bold。testruct main=e331e97。
- SSOT: font.rs BUNDLED_FONTS(6=登録)/FAMILY_*(語彙)/FONT_CHOICES(3=picker) が font 名 canonical source、BUNDLED_FONTS≠FONT_CHOICES 分離 (Bold=weight 軸)。
- map_family (screen_painter) = 単一 routing choke point (screen+PNG+PDF)。既定枝 非mono→SansSerif=parity anchor。Named は &'static const。
- RIBBI: Bold は Regular と同 family 名+subfamily Bold+wght700+style bits、fontdb weight 自動選択。Noto Bold/Serif は variable instance+name-fix (全 OFL/RFN なし)。
- picker active = map_family 解決後比較 (生文字列でなく)。undo=TextStyleCommand 再利用。
- premise-learning: parity 前提は fixture 実 weight/family を grep 事前確認 (F5a で english/april に Bold 発覚)。
- PDF: weight 配線 (screen 同型) + synthetic stroke 条件化 (選択 face is_bold() 実判定、real Bold→off/fallback→on)。screen が Bold を flat 描画していた latent 限界を F5 で根治。

## push
handoff doc は ★**userfork** へ push (`git push userfork main`、origin=Akira-Papa は read-only 上流、前回 learning)。sha は push 後 ack に明記。
