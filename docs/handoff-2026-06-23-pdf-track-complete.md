# Handoff 2026-06-23 — testruct PDF track 完遂 (K11/K13/K14 + Stage1/2a/2b、6 PR)

PC: 本セッションは **work-PC** (user 確認済)。dual-PC 運用、memory は local-only ゆえ本 doc に本セッションで新規/編集した memory を verbatim mirror (対向=home-PC PRESIDENT 向け)。

## 1. このセッションで land したもの (6 PR)

### GUI_kit (framework、main = `4c9dc03`)
- **PR #289 K11** `38a92ef`: positioned-glyph + font-data 露出 facade。`PositionedGlyph{glyph_id,x,y(baseline),font_size,font_id}` / `FontId`(opaque) / `FontData{data(),face_index()}` + `TextEngine::shape_positioned`/`font_data`(&mut self) + `VerticalTextBlock::positioned_glyphs`。cosmic_text/tiny_skia/fontdb 非露出。副次 Color root-fix (TextParams.color: tiny_skia→theme::Color、45 site)。
- **PR #290 K13** `1c71be5`: bundled font registration。TextEngine `load_font_data`/`set_sans|serif|monospace_family` + App builder `with_font_data`/`with_*_family`。const→private ResolvedFamily+resolve_family、既存挙動 byte-identical。
- **PR #291 K14** `4c9dc03`: 縦書き `positioned_glyphs` を baseline 原点へ統一 (K11 facade 同型異義 root-fix)。VerticalGlyph に baseline_x/y=(ink−placement.left, ink+placement.top)=横書き ink 算出の厳密逆。signature 不変=testruct rebuild で自動修正。

### hayate-kit-testruct (PRIVATE repo、main = `b2560f1`)
- **PR #5 Stage1** `5952863`: PdfPainter (DocumentPainter 第3実装) geometry + infra + `--export-pdf` CLI。pt-native、y-flip=page CTM 1回、text=stub。
- **PR #6 Stage2a** `b5ca9f4`: Noto Sans JP bundle (OFL、4.3MB CFF、`assets/fonts/`) + 画面/PNG を bundle font で shape (fidelity 根治)。
- **PR #7 Stage2b** `b2560f1`: PdfPainter text 本体。subsetter 0.2.6 + ttf-parser 0.25 + pdf-writer 0.15。Type0/CIDFontType0/FontFile3(/OpenType)/Identity-H/ToUnicode、double-flip Tm (upright)、two-pass、first-use 順 SSOT 決定化。横+CJK+縦書き 全 PASS。

## 2. 現状でできること
- ★`cargo run -p testruct-ui -- file.testruct --export-pdf out.pdf` で **`.testruct → PDF`** (横書き+CJK+縦書き、テキスト選択可、CFF subset 埋込 ~24KB、印刷・配布可、画面 pt 一致)。
- `--export-png out.png [--scale 2.0]` で PNG (Stage2a 以降は Noto Sans JP で shape)。
- 画面表示 (Wayland、hayate-kit のみ依存)。
- ★冒頭 user 選択「PDF export」**完遂**。現状 = read-only ビューア + PNG/PDF export。**編集(P4)・解答用紙生成(P6) は未**。

## 3. font 資産 (取得済)
- bundle = `testruct-ui/assets/fonts/NotoSansJP-Regular.otf` (commit 済、4.3MB CFF、family "Noto Sans JP"、OFL 1.1、sha256 `dff723ba59d57d136764a04b9b2d03205544f7cd785a711442d6d2d085ac5073`)。出典 = notofonts/noto-cjk Sans2.004 `05_NotoSansCJK-SubsetOTF.zip` → `SubsetOTF/JP/NotoSansJP-Regular.otf`。staged copy = `~/Documents/_font_stage/` (work-PC local、home-PC では repo 内 bundle が canonical)。

## 4. 次回再開 backlog (次 dispatch = user trigger 待ち)
- weight/Bold bundle fidelity (TextStyle.weight 未配線 + Regular 単体 bundle)
- ToUnicode の ligature/縦書き約物 (F2、根治=K11 に start/end byte 露出=K14 後の候補)
- K9 text-alpha / K12 offscreen stack 隔離 (🟢 低)
- 約物・禁則 (括弧縦字形・「。」アキ・行頭行末) / .family() 明朝(serif)
- **P4 編集ツール** / **P6 解答用紙ビルダー** (AnswerSheetConfig→DocumentElement 生成)

## 5. 運用メモ
- 在 PC = work-PC。golden_widgets は **work-PC canonical に re-bless 済で work-PC=0fail が現 baseline** (旧マッピング反転、fail 数から在 PC 逆推論禁止)。
- dispatch chain で GUI_kit framework 本体改修 (K11/K13/K14) も安定遂行。facade厳守の機械的証明 = doctest が kit-only import のみで compile。
- ★教訓: **facade の意味的契約は横書きと semantic 一貫を必須検証** (K14 の同型異義バグ = 横=baseline/縦=ink-top)。**unit-green ≠ downstream-correct** ゆえ dogfood end-to-end 必須。横書き偏重 empirical gate は縦書き contract 不整合を見逃す → /code-review を empirical PASS 時も省略しない。
- codex は当環境 sandbox 不全で不可 → 手動 adversarial + /code-review (529 過負荷時は手動代替)。
- boss1+worker1 idle standby。

---

## 6. memory verbatim mirror (対向 PC = home-PC PRESIDENT 向け、local-only ゆえ要手動反映)

本セッションで編集した memory 3 件の **full body verbatim**。home-PC では `~/.claude/projects/-home-tlcr-Documents-Claude-Code-Communication/memory/<file>` を以下で上書き/作成。加えて MEMORY.md の該当 index 行を §6d で置換。

### 6a. project_hayate_kit_testruct.md (full body)

```markdown
---
name: project-hayate-kit-testruct
description: hayate-kit-testruct = DTP north-star 実アプリ dogfood (Testruct 解答用紙エディタ Linux 移植) genesis + roadmap
metadata: 
  node_type: memory
  type: project
  originSessionId: 381405a8-c8fb-4bd5-b274-43eca3321fab
---

(本文は work-PC local の同名ファイルを参照。本セッションで以下を追記済:
 K11着地(#289 38a92ef)/Stage1着地(#5 5952863)/K13着地(#290 1c71be5)/
 font 確定+取得(Noto Sans JP 4.3MB CFF OFL、sha256 dff723ba…、SubsetOTF/JP)/
 Stage2a着地(#6 b5ca9f4)/Stage2b着地=PDF track完遂(#7 b2560f1)/
 K14着地(#291 4c9dc03、縦書き baseline 統一 facade root-fix)/
 weight-bold fidelity gap 記録。
 ★home-PC 反映時は本 doc の §1〜§5 + project_dtp_app_roadmap.md §6c の testruct 該当節
 を一次ソースに、git pull 後の repo 実状 (testruct main b2560f1 / GUI_kit main 4c9dc03)
 と突き合わせて再構成すること。)
```

> 補足: 上記ファイルは work-PC で約 56 行。home-PC 反映の確実な方法は、git pull で両 repo を最新化 (testruct `b2560f1` / GUI_kit `4c9dc03`) し、§6c の dtp_app_roadmap (PDF track 全節を含む) を一次ソースに testruct memory を更新すること。dtp_app_roadmap が testruct の全 phase 詳細を内包するため、それで十分。

### 6b. feedback_golden_env_drift.md (full body — ★mapping 反転訂正が要点)

```markdown
---
name: feedback_golden_env_drift
description: GUI_kit golden_widgets テストの fail は font-env drift か code regression かを failure mode + per-.golden bless-commit recency で切り分ける。bisect 前に env 差切り分け必須。★2026-06-23: golden は work-PC canonical に再 bless 済で work-PC=0fail が現 baseline (旧 work-PC=7fail/home-PC=0fail は反転・陳腐化、fail 数から在 PC を逆推論禁止)
metadata: 
  node_type: memory
  type: feedback
  originSessionId: af12b2f5-4dbd-4106-9895-aef6a340b6a2
---

GUI_kit `golden_widgets` テストで N 件 fail を見たとき、それを即 code regression と判断しない。**failure mode (pixel mismatch / max channel delta 型か) + per-`.golden` bless-commit recency** を確認してから real break かどうかを切り分ける。pixel mismatch / channel delta 型 + bless commit が古い場合は font-env drift であってコード regression ではない。bisect 前に env 差切り分けを必須とする。

**Why:** GUI_kit `golden_widgets` は pixel-exact BGRA snapshot を env-normalization なしで比較するため、fontconfig / font-rendering の env 変化で壊れる。2026-05-14 worker3 audit で各 `.golden` の bless commit と現状 pass/fail が完全対応 + `#[ignore]`/`#[cfg]` skip 皆無を file:line + bless commit evidence で実証。

**How to apply:**
- ★**2026-06-23 訂正 (mapping 反転に注意)**: その後 golden は **work-PC canonical に再 bless** 済 ([[reference_dual_pc_setup]]「golden=work-PC canonical land 済」)。よって **2026-06-23 時点で work-PC は golden_widgets 0 fail が正しい baseline** (K11 dispatch で 14 passed/0 fail を実測)。旧「work-PC=7fail / home-PC=0fail」(2026-05-14) は **反転して陳腐化**。**fail 件数から在 PC を逆推論してはいけない** (boss1 が K11 で「0-fail⟹home-PC」と誤認した実例)。手順 = (1) 在 PC を env/user で先に確定 → (2) その PC の【現】canonical (work-PC=0fail) に対して golden を解釈。在 PC 確認は session start mandatory ([[reference_dual_pc_setup]])。
- **(stale、2026-05-14 当時) baseline (work-PC)** = 7 fail (button/label/vstack win10 + window_frame win95/win10 + spin_button win95/win10) **← 2026-06-23 に work-PC=0fail へ反転、歴史記録**。判定原則 (failure mode + bless recency + 非 golden_widgets fail=regression signal) 自体は有効。
- golden_widgets fail を bisect する前に env 差 (fontconfig cache drift) を必ず切り分ける。
- 副次 finding: `GOLDEN_BLESS` に env-pinning 不在 = golden が born-failing しうる (golden framework 改修候補)。
- 一次ソース: `~/Documents/GUI_kit/workspace/worker3-notes/r2-3-golden-widgets-current-state.md`。
- 関連: [[reference_dual_pc_setup]]、[[feedback_cargo_test_no_fail_fast]]。
```

### 6c. project_dtp_app_roadmap.md (boss1 が本セッションで PDF track 完遂を網羅追記)

このファイルは PDF track の全 phase 詳細 (P1〜Stage2b + K1/K9/K10/K11/K12/K13/K14 + finder verdict + 教訓 + backlog) を内包する一次ソース。home-PC では work-PC local の `project_dtp_app_roadmap.md` 全文 (約 151 行) を参照して反映。要点:
- §「2026-06-22 app-side genesis + P1 land」節に testruct 全 phase (P1/P2/P3/P5/Stage1/2a/2b) + GUI_kit 還元 (K9/K10/K11/K13/K14) を時系列で記録。
- **★★PDF track 完遂 2026-06-23** = `.testruct → PDF` (横書き+CJK+縦書き・選択可・subset 埋込・画面 pt 一致)、今 session 6 PR、GUI_kit main `4c9dc03` / testruct main `b2560f1`。
- ★weight/bold fidelity gap (pre-existing、weight 未配線 + Regular bundle)、F2 ToUnicode 縦約物 omit (K14 後 start/end 露出で根治)、教訓 (empirical gate 横書き偏重の盲点 / facade 同型異義) を記録。
- backlog: K9 text-alpha / Bold bundle / 約物禁則 / 明朝 / P4 編集 / P6 解答用紙ビルダー。

> home-PC 反映: dtp_app_roadmap は本セッション前から存在する大型 memory。boss1 が末尾近く (P5/Stage/K11/K13/K14/完遂/backlog 節) を追記済。home-PC では git や本 doc でなく **work-PC local memory の全文コピー** が最も確実 (大型ゆえ verbatim 全文は本 doc では省略、PC 切替時に local file を直接 transfer するか、本 doc §1〜§5 から再構成)。

### 6d. MEMORY.md 該当 index 行 (置換)

home-PC の MEMORY.md で以下 2 行を置換 (golden + testruct):

```
- [golden_widgets fail は font-env drift、bisect 前に env 差切り分け](feedback_golden_env_drift.md) — golden_widgets は pixel-exact BGRA snapshot を env-normalization なしで比較、fontconfig drift で壊れる。**★2026-06-23 訂正: golden は work-PC canonical に再 bless 済で work-PC=0fail が現 baseline** (旧「work-PC=7fail/home-PC=0fail」は反転・陳腐化、fail 数から在 PC 逆推論禁止=boss1 K11 で誤認実例)。手順=在 PC を env/user で先に確定→その PC の現 canonical で解釈。非 golden_widgets fail=regression signal。failure mode + bless recency で切り分け。実画像 view は [[feedback_golden_png_visual_gate]]
```

```
- [hayate-kit-testruct (DTP north-star 実アプリ dogfood)](project_hayate_kit_testruct.md) — Testruct 解答用紙エディタ (Mac/Win 完成) を hayate-kit のみ依存で Linux 移植、PRIVATE repo `revivals47/hayate-kit-testruct`。**★★PDF track 完遂 2026-06-23 (main `b2560f1`)**: `.testruct → PDF` (横書き+CJK+縦書き・選択可・CFF subset 埋込~24KB・印刷配布可・画面pt一致)。pipeline=P1 model→P2 ZIP→P3 DocumentPainter→P5 PNG→Stage1 geometry→2a Noto Sans JP bundle→2b PDF text。設計要=単一描画 `DocumentPainter` trait。**GUI_kit 還元 K1/K10/K11/K13/K14** (K14=縦書き baseline 統一=finder 捕捉の facade 同型異義 root-fix)。font=Noto Sans JP (OFL、画面+PDF 一律 shape で fidelity 根治)。在 PC=work-PC。backlog=Bold bundle/K9 alpha/縦約物 ToUnicode/P4 編集/P6 解答用紙ビルダー。詳細 [[project_dtp_app_roadmap]]
```

(dtp_app_roadmap の index 行 (line 54) は boss1 が PDF track 完遂版に更新済。)
