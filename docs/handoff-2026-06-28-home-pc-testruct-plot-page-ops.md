# Handoff 2026-06-28 — home-PC: testruct 関数プロット要素 + ページ追加削除 + 周辺UI修正（PR #68 land 済）

home-PC session。hayate-kit-testruct を Mac/Win 原本（testruct-v3）へ寄せる convergence の継続。
本 session で **関数プロット要素（8番目の要素型）** を中心に land、user は次に **GUI_kit 基盤修正を並行** する宣言（§E 参照）。
**actionable な残タスクは無し**（テスト全緑・main clean・アプリ停止済）。次 reentry は §D の大物候補から user 選択待ち。

---

## §A. 本 session でやったこと — ✅ PR #68 land 完了（hayate-kit-testruct main `e883e14` + docs `857f400`）

3 件まとめて 1 PR で squash merge（全 live verify 済、user OK）。

### 1. 関数プロット要素（PlotElement、8番目の要素型）★大物
- `testruct-core/src/plot_expr.rs`（新規）= 再帰下降の式評価器。`+ − × ÷ ^`（^ は右結合）/ 単項マイナス / `pi`・`e` / `sqrt`・`sin`・`cos` 等の関数（括弧必須、v1）/ 暗黙乗算。定義域エラー（sqrt 負・ln≤0・/0・非有限）は `None`。6 test。
- `element.rs`: `PlotElement`{id,bounds,x_min/max,y_min/max,samples,show_grid,axis_color,curves:Vec<PlotCurve>,visible,locked,opacity} + `PlotCurve`{expression,color,width}。serde 既定（範囲±10/samples 200/width 2.0）。
- `document_element.rs`: `Plot(PlotElement)` variant + 全 match accessor（python script で Table arm を複製）+ **多態 deserializer の `"Plot"` タグ**（これが無く decode で "unknown element type Plot" になった→修正済）。
- `render.rs` `render_plot`: 軸 + グリッド + 各 curve をサンプル数で折れ線描画、不連続点（`jump = yr*2.0`）で polyline 分断。`push_clip(bounds)`。全 backend（screen/PDF/SVG）を core walk 経由で描画。**1/x の漸近線も正しく折れ線分断**を PNG で確認。
- `presets.rs` / `answer_sheet/metrics.rs`: グラフカテゴリ（放物線 x²/直線 x/正弦 sin/余弦 cos/三次 x³/反比例 1/x）+ `make_plot` ファクトリ。

### 2. ページ追加/削除（複数ページ検証を可能にするため）
- `commands.rs`: `AddPageCommand{at}`（apply=`Page::empty` 挿入、revert=削除）/ `DeletePageCommand{at, removed:Option<Page>}`（pages.len()>1 のみ削除、revert=再挿入）。undo 可、test 付き。
- `canvas/zoom.rs`: `add_page`（current 直後に挿入→current 更新→選択 clear→pan 0）/ `delete_page`（pages>1 のみ、current clamp）。`pub(super)`、`testruct_core::AddPageCommand::new(...)` フルパス。
- `canvas/shell.rs`: `ShellAction::AddPage`/`DeletePage` + apply arm → zoom.rs に dispatch。
- `main.rs`: 挿入メニューに「ページを追加 / ページを削除」。
- `pages_panel.rs`: **左サイドバー最下部「＋ ページを追加」ボタン**（常時表示、`add_btn:ItemRect`+`add_hover`、サムネ領域は `ADD_BTN_AREA`=28+PAD の下端余白を確保して重なり回避、hover 色変化、click→`ShellAction::AddPage`）。

### 3. 周辺 UI 修正
- `presets_panel.rs`: 8 カテゴリがパネル高超過（~1180px 内容 vs ~900px パネル）でグラフ/図形が切れる → `scroll:f32` + `content_height()` + `push_clip` + ホイールスクロール（user feedback「向きが逆」で `self.scroll + dy` に修正＝自然方向）。
- `page_nav.rs`: 下バー「ページ X/N」が固定幅 `LABEL_W=120` 左詰めで左寄りに見えた件を、`measure_text_width` でラベル実幅を測り `◀ + ラベル + ▶` をタイトに組んでバー中央寄せ。`LABEL_W` 定数は削除。

### 4. 回帰修正（#64 起因）
- `render.rs` `stroke_2pt` ヘルパ新設（実線=`painter.stroke_line` / 破線=`stroke_dashed`）。#64（破線 PR）で Line/Arrow arm が `stroke_outline`→`stroke_polyline` 化し、`RecordingPainter` が stroke_line だけ数える `render_walk::kokugo_emits_grid_strokes`（core 統合テスト）が落ちていた。#64 時に該当テストを grep し損ねた。Line/Arrow arm + render_rotated の line ケースに配線。

---

## §B. git state（全て origin push 済）

### hayate-kit-testruct（github.com/revivals47/hayate-kit-testruct）
- `main` = `857f400`（docs）/ `e883e14`（PR #68 feat）。origin 同期、tree clean。
- branch `feat/plot-element-page-ops` は squash merge + `--delete-branch` 済。
- **テスト**: core 192（lib）+ 5（integration: file_io 3 + render_walk 2、**kokugo_emits_grid_strokes 緑**）/ ui 103（--bins）/ release build 緑。

### GUI_kit（github.com/revivals47/GUI_kit）
- testruct の path dep。本 session では **GUI_kit に変更なし**（K2 `fill_polygon`=PR #305 は前 session で land 済）。
- ⚠️ untracked `docs/architecture-debt-roadmap-2026-06-28.md` あり＝**user の並行 GUI_kit 基盤修正の作業ファイル**（§E）。testruct 側は触っていない。

### Claude-Code-Communication（comm repo）
- 本 handoff doc を commit + push。
- `.claude/settings.local.json` の M と `section/`（untracked）は本 session 無関係、commit しない。

---

## §C. memory 更新（home-PC `~/.claude/projects/-home-ken-Documents-Claude-Code-Communication/memory/`）

- **更新** `project_testruct_mac_convergence.md` — PR #68 の詳細 bullet 追加（Plot/ページ操作/scroll/nav/回帰の5点）、サイドバー v1 gap の「ページ追加削除なし」を解消注記、⬜残リストから関数プロットを除去。
- **更新** `MEMORY.md` — testruct index 行を最新化＆短縮（旧行が #44 時点で stale + 200字超だった。〜#68 まで land、残=フォント複数化/ビルダー対話UI/グラデ半透明）。
  - 注: MEMORY.md は依然 size limit 超（警告 39KB vs 24.4KB）。index 行の長さは全体的に要圧縮（別途）。

---

## §D. 次 reentry checklist / 残タスク（user 選択待ち、いずれもスコープ大）

docs/REMAINING-TASKS.md（main `857f400`）が source of truth。図形/要素モデル・数式・表・レイヤー・エクスポート・ページ操作は一通り land 済。残る大物:

1. **フォント複数化（FontPicker + 複数フォント bundle）** — Win `FontPicker.cs`+`BundledFonts.cs`。現状 Noto Sans JP 単一で全 family が SansSerif 解決、書体切替 UI なし。font bundle が前提でスコープ大。
2. **解答用紙ビルダー 対話 UI** — コア生成（`answer_sheet/`）+ プリセット挿入はあるが、config を GUI 編集する画面が無い（`answer_sheet_config` は opaque な `serde_json::Value` 往復のみ）。最も実用インパクト大の大物。
3. **描画 fidelity の fallback 根治** — グラデ（K4、最初の stop 単色 fallback）/ 半透明（K8/K9、真の alpha 合成なし）/ shadow blur。**テスト用紙では低価値・高コスト=見送り推奨**。
4. 低優先: 右クリック context menu、レイヤー Z順ボタン、専用ツールパレット、text/image 回転、PlotElement の Inspector 編集（範囲/曲線追加 UI、現状はプリセット挿入のみ）。

---

## §E. ★ user 並行作業との調整事項（重要）

user は本 session 終了後 **GUI_kit 基盤修正を並行** する旨を宣言。
- GUI_kit に untracked `docs/architecture-debt-roadmap-2026-06-28.md`（基盤負債ロードマップ）が既にある＝この並行作業の起点。
- **testruct は GUI_kit を path dep で参照**。GUI_kit 側の API/Renderer に破壊的変更が入ると testruct の build/golden に波及しうる。
- 次に testruct 作業を再開する際は、**まず GUI_kit main を pull → testruct を `cargo build --release -j1` で緑確認**してから着手すること（GUI_kit drift 検出）。
- testruct 側から GUI_kit に新規 K-track 還元（例: shadow blur / グラデ primitive）を起票する場合は、user の基盤修正と衝突しないよう先に GUI_kit の現状を確認。

---

## §F. 教訓（本 session）
1. **多態 enum に variant 追加時は custom deserializer のタグ arm も忘れず** — `DocumentElement` の手書き Deserialize に `"Plot"` arm を入れ忘れ「unknown element type」。serde derive でなく手書き tag matching の構造体は variant 追加で2箇所（enum + deserializer）要修正。
2. **回帰修正の grep は統合テストまで含める** — #64 で `render_walk.rs`（core 統合テスト）の `kokugo_emits_grid_strokes` を grep 漏れ。`RecordingPainter` は `stroke_line` だけ数えるので polyline 化が機械検出された。lib test だけでなく `--test <name>` の統合テストも回す。
3. **GUI アプリの detached 起動は launch+poll を1コマンドに** — `setsid … & disown` で別コマンドに分けると harness sandbox が disown 後の lingering job を kill して exit 144。`& disown; sleep N; pgrep …` と同一コマンド内で foreground を継続させると生存。`dangerouslyDisableSandbox: true` も必要（Wayland display アクセス）。HAYATE_SCREENSHOT 経路は本 session では sandbox と競合し AI 自前キャプチャ不能、**user が live 視覚レビュー**で代替。
4. **cargo verify は crate kind を pre-flight**（[[feedback_cargo_verify_crate_kind_preflight]]）— `testruct-ui` は **bin**（`--lib` 不可、`--bins`）、`testruct-core` は lib（`--lib` で 192、`--test render_walk` で統合）。
