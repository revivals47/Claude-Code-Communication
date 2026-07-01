# Handoff 2026-07-01 (work-PC) — testruct テキスト編集オーバーレイ修正 (G1/G2/G1b/G2b 全完遂・3 症状 closure)

## 概要
testruct のインライン text 編集オーバーレイ (要素をダブルクリック→編集) が要素の TextStyle を**無視**していたバグの修正。実機 + code で PRESIDENT 確定した真因 = `begin_edit` (canvas/text_edit.rs) が `TextInputWidget::new_with_engine(eng).with_width(w) + set_text(content)` を作るだけで **font_size/font_family/alignment/weight/color を渡していなかった** → overlay が TextInputWidget デフォルト styling で描画。framework gap = TextInputWidget に placeholder 以外の style setter が無かった。

**視覚症状 3 つ** (evidence: `~/Documents/testruct-design-review/textedit_bug_font不一致.png`):
1. font size/family/color/weight 不一致 (タイトル編集で文字が大きすぎ・別書体)
2. box からの overflow/wrap (大きすぎで枠外にはみ出し)
3. alignment 不一致 (中央揃え要素の編集が左寄せ)

→ **4 PR (G1→G2→G1b→G2b) で 3 症状すべて closure**。GUI_kit 側 framework gap 根治 (G1/G1b) + testruct consumer 配線 (G2/G2b) の 2 層構成。全段 additive・golden bit-exact・視覚確認ゲート。

## 着地 sha chain
### GUI_kit (main = `fb9191a`)
- **G1** (PR #316、merge `424ce15`、commit `26a77dd`): TextInputWidget additive style setters。`with_font_size(:154)/with_text_color(:161)/with_font_family(:169)/with_font_weight(:176)`。TextInputStyle に `font_family: FontFamily<'static>`(既定 SansSerif) + `font_weight: Option<f32>` 追加。draw を `draw_text_with_axes` へ切替 (SansSerif+new() 時 draw_text と byte-identical)、measure_text_width も family+axes threading で caret 整合。
- **G1b** (PR #317、merge `fb9191a`):
  - `1d6a183` horizontal alignment (Leading/Center/Trailing) via **offset-when-fits**。`align: HAlign` field (既定 Leading) + `align_metrics(:231)→(offset,fits)` (Leading→0 / Center→(content_w-full_w)*0.5 / Trailing→content_w-full_w、overflow 時 offset=0 で scroll 経路へ)。caret 右端 clip を align 条件化 (`align_offset>0`→`<=` / else Leading strict `<`=byte-identical)。content_metrics + scroll_offset() を SSOT helper 化。`with_alignment(:188)`。
  - `cef5b25` IME candidate rect を draw-path caret basis (`content_x + cursor_x - scroll_offset + align_offset`) で報告 (touched-line side-retrofit、codex finding A 採択)。

### testruct (main = `c4a16d6`)
- **G2** (PR #80、merge `0f43f6f`、+100/-9): begin_edit が element TextStyle を読み G1 setter 適用。overlay `.with_font_size(font_size * zoom)` (zoom scale = screen_painter:194 `font_px = style.font_size * self.zoom` と一致) + TextElement に `.with_font_family(map_family)/.with_text_color/.with_font_weight(weight)`。表セル = font_size のみ。`text_style_of` helper。→ 症状 1+2 closure。
- **G2b** (PR #81、merge `c4a16d6`、commit `5aaa8ca`、+115/-7): 水平揃え配線。`halign_of_text` (Start→Leading / Center→Center / End→Trailing / **Justified→Leading** = 単一行 justify 不能の妥当 degradation・コメント付) + `halign_of_cell` (Left/Center/Right→Leading/Center/Trailing) mapping 2。begin_edit に `align: HAlign` 引数 + `.with_alignment(align)` 1 行 (G2 setter 不変)。caller source 別 = TextElement は style.alignment / 表は cell_alignment。TextEditState が align 記録 (plumbing 観測点)。→ 症状 3 closure。

## 検証・ゲート (全段 pass)
- **G1/G1b (GUI_kit)**: golden bit-exact (SansSerif+Leading 時 draw_text と byte-identical を設計 invariant 化)、cargo green。
- **G2 (testruct)**: 独立視覚確認 OK (user GO)。要素の font/size/family/color/weight が overlay に一致、overflow 解消。
- **G2b (testruct)**: cargo test 327 passed / 0 failed。unit 4 = `halign_of_text`/`halign_of_cell` 全変種 + `begin_edit_records_alignment` (plumbing) + `enter_text_edit_applies_element_alignment` (Center 要素→Center overlay full-path)。**Center live 視覚**: AFTER=中央揃え「中央揃え」要素の編集 overlay が中央配置・caret 末尾・要素一致 / BEFORE(leading toggle)=左端。証跡 = worker1 scratchpad `g2b_after_center.png` / `g2b_before_leading.png`。env-hook (HAYATE_EDIT_SHOT/TESTRUCT_AUTOEDIT_ALIGN) + toggle 完全 revert (grep 残渣ゼロ)、既存 fixture 不変 (編集非経由)。
- **codex 判定**: G1b (14 caret/IME site の intricate 変更) で diff inline 査読実施 = core LGTM + pre-existing IME candidate-rect basis 不整合を finding→touched-line side-retrofit で吸収 (cef5b25)。repo 整合 clean 確認 ([[reference_codex_sandbox_repo_mutation]] 遵守)。G2b は enum→enum mapping + setter 1 行の局所 plumbing ゆえ codex 不要と評価 (unit 4 + boss1 全読で足りる)。

## grounding / premise 訂正・learning
1. **★click hit-test N/A (premise 訂正)**: G1b 設計当初「alignment 導入で click-to-caret の hit-test 逆算も要る」と想定 → grounding で **testruct の overlay caret は keyboard-only、click-to-caret 機能自体が存在しない**と判明。req (click 逆算) は N/A、G1b を単純化。honest premise 訂正として PRESIDENT 承認。
2. **G1b split 判断**: alignment × 単一行 scroll/caret が entangle (2 draw path × ~14 site + update_scroll_offset + IME rect)。当初 G1 一括案 → worker1 recommend split → boss1 検証 → PRESIDENT 承認で G1(setter)/G1b(alignment) 分離。offset-when-fits により align 成立時は scroll_offset=0 強制 (align/scroll 相互排他)。
3. **zoom scale 整合**: overlay font = `style.font_size * zoom` (screen_painter:194 と同型) で編集中も画面 pt 一致。
4. **caller source 別**: TextElement=style.alignment / 表セル=cell_alignment を別経路で map (混同回避)。
5. **IME candidate rect basis**: draw-path caret basis (scroll_offset + align_offset 込み) に統一。cef5b25 で touched-line の pre-existing 不整合も side-retrofit。

## backlog (silent drop 防止・投機せず必要時着手)
- **★複数行編集**: 現状 TextInputController は single-line。multi-line 化は別大 track (overlay を multi-line エディタへ、caret/scroll/描画全書換)。今回 scope 外。
- **IME 他症状**: candidate rect basis は修正済だが IME の他症状は未確認。要れば user 操作 (実機で日本語変換) で再洗い。[[feedback_state_dependent_runtime_trace]] に従い前提状態固定で trace。
- **空 text caret Leading (低)**: 空文字列時の caret 位置が Leading 前提。align 反映は要検討だが優先度低。
- **click-to-caret 不在**: 現状 keyboard-only。将来 click-to-caret 機能追加時は hit-test で `align_offset` 減算が必要 (text_input_render.rs の caret 逆算に forward-note 相当)。
- **G1b 温存細部**: codex 査読で core LGTM の細部 (14 site の individual verification は boss1 全読 + unit で cover、追加査読は温存)。

## ★memory mirror 用要点 (PRESIDENT が canonical へ反映)
PRESIDENT 側で **project_hayate_kit_testruct** に text-edit fix 追記。要点:
- testruct インライン text 編集 overlay が要素 TextStyle 無視のバグ → 4 PR で 3 症状 closure。testruct main=`c4a16d6` / GUI_kit main=`fb9191a`。
- **framework gap 根治**: TextInputWidget に style setter が placeholder しか無かった → G1 で `with_font_size/with_text_color/with_font_family/with_font_weight`、G1b で `with_alignment` (offset-when-fits) additive 追加。draw_text_with_axes 切替で SansSerif+Leading 時 golden byte-identical (parity invariant)。
- **testruct consumer 配線**: begin_edit が element TextStyle 読取 → G2 で font_size*zoom/family(map_family)/color/weight、G2b で alignment (halign_of_text: Justified→Leading degradation / halign_of_cell)。caller source 別 (TextElement=style / 表=cell)。
- **premise 訂正**: click-to-caret 機能は testruct に存在しない (keyboard-only caret) → G1b の click hit-test 逆算 req は N/A。alignment×single-line entangle ゆえ G1/G1b 分離が正道。
- **codex**: G1b (14 caret/IME site) は diff inline 査読 = core LGTM + IME candidate-rect basis 不整合 side-retrofit (cef5b25)。G2b (局所 plumbing) は codex 不要。
- backlog: 複数行編集 (別大 track、single-line controller) / IME 他症状 (要 user 再洗い) / 空 text caret Leading (低) / click-to-caret 将来 (align_offset 減算)。
- 関連: [[project_dtp_app_roadmap]] (testruct=Testruct 移植 dogfood) / [[feedback_new_apps_depend_on_gui_kit_only]] (kit-only、HAlign prelude 経由) / [[feedback_root_cause_over_quick_fix]] (framework gap を band-aid でなく setter API で根治)。

## push
handoff doc は **userfork** へ push (`git push userfork main`、origin=Akira-Papa は read-only 上流、前回学び)。sha は push 後 ack に明記。
