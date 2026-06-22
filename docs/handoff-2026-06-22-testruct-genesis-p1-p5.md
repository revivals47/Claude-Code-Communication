# Handoff 2026-06-22 — hayate-kit-testruct genesis → P1〜P5 + GUI_kit R2-4/K1/K10

PC: 本セッションは `/home/tlcr` 環境（在 PC ラベルは次回 reentry 時に env で確認）。dual-PC 運用、memory は local-only ゆえ本 doc に新規/編集 memory を verbatim mirror（対向 PC PRESIDENT 向け）。

## 1. このセッションで land したもの

### GUI_kit (framework、main = `0312546`)
- **PR #286 R2-4**: modal focus trap + Esc dismiss（AlertDialog Tab/Shift+Tab cycle + focus-aware Enter[BC保持] + FilePicker `on_cancel`/Escape）。`cc6f188`。
- **PR #287 K1**: `VerticalSegment`/`VerticalTextBlock` を hayate-kit re-export（縦書き低レベル draw API、kit-only doctest 付き）。`0f29832`。
- **PR #288 K10**: CPU `push_clip` が active translate 未適用で Vulkan と不一致（frame-in-group で clip ズレ）の **framework bug を root-fix**（`transform_rect` で bake、pixel-level regression test、offset0 で既存無影響）。`0312546`。DTP dogfood が捕捉。

### hayate-kit-testruct (新 PRIVATE repo、main = `1ae74b4`)
- **genesis** `c70ecb2`: 2-crate（testruct-core 非GUI serde / testruct-ui hayate-kit features=ime,a11y）、notepad 構成踏襲。
- **PR #1 P1** `5296b70`: データモデル + serde（7要素 + 多態 DocumentElement v3内部タグ/v2 fallback + PageSize 三系 + TextStyle 縦書き field always-emit）。golden 3 fixture model-level round-trip。re-baseline 2件（answerSheetConfig casing / TextStyle drift = 契約 stale を Mac source で訂正）。
- **PR #2 P2** `75c2021`: .testruct ZIP I/O（STORE+DEFLATE read / STORE write / CRC / bare-JSON fallback / atomic write / path safety / zip-bomb 二重防御）。Swift より hardening（A1 total cap 実バイト / (b) asset flat-only）。
- **PR #3 P3** `48da618`: DocumentPainter trait（core、backend非依存）+ ScreenPainter（ui、hayate-kit Renderer wrap）で **実 .testruct を画面描画**。kokugo(枠/罫グリッド)/english(縦書き+横書き) 視覚 PASS。
- **PR #4 P5段階A** `1ae74b4`: **オフスクリーン PNG export**（`Renderer::Cpu` 直接 + 既存 ScreenPainter + render_page = 単一経路、scale2.0/白背景/multi-page、`--export-png` CLI）+ PDF feasibility PoC（pdf-writer、3択B）。

cargo test: testruct 72 green / GUI_kit hayate-platform 953 + hayate-kit 1133 green。

## 2. 現状でできること / できないこと
- ✅ `cargo run -p testruct-ui -- file.testruct [--export-png out]` で実 .testruct を Wayland 表示 + multi-page PNG 書き出し（hayate-kit のみ依存）。april(英語問題7p)/kokugo/english 確認済。
- ⚠️ **read-only viewer + PNG export 段階**。編集(P4) / 解答用紙生成(P6) / PDF export(K11 前提) は未。
- ⚠️ fidelity 微ズレ既知（font bundle 未 = system fallback、user 2026-06-22 指摘）。

## 3. K-gap 現況（GUI_kit 還元、ROADMAP §5 に durable）
- **K1 着地**（縦書き API）/ **K10 着地**（push_clip bug）
- **K11 pending**: PDF の positioned-glyph (glyph_id,x,y,font_id) + 埋込 font bytes を ui に tiny_skia/cosmic_text 内部を曝さず公開。PDF full の前提。
- **K12 pending**: offscreen `Renderer::Cpu` の thread-local CPU stack reset API（`reset_cpu_stacks` が pub(crate)）。K10 と同 CPU-stack facade facet。
- K2-K9: fixture 未使用ゆえ defer。

## 4. 次回再開段取り（PRESIDENT 主導）
- (1) **K10+K12 統合 CPU-stack facade GUI_kit track**（push_clip は済、offscreen stack reset 追加）
- (2) **K11 PDF 前提 track**（positioned-glyph + font-data 露出 API 設計）→ その後 **PDF full dispatch**（pdf-writer、PdfPainter=ui）
- または testruct **P6 解答用紙生成**（AnswerSheetConfig→DocumentElement[]、RTL packer + 12×20 作文 grid）/ **P4 ツール**（編集・選択ハンドル）
- worker1 + boss1 = idle standby
- 別途 GUI_kit 側 open PR #285（chrome controls、他者 WIP）+ track-r4/dialog-default-button-audit（R4、R2-4 と統合点あり）が残

## 5. 運用メモ
- boss1 は worker 完了後の「査読→PR」前で沈黙しがち（P1/P2/P3/P5 で都度発生）→ PRESIDENT が pane/repo を直接見て nudge で前進（`feedback_boss1_intermediate_ack_required`）。
- 各 phase で boss1 が re-baseline（契約/plan stale を Mac source/fixture で訂正）を継続実施 = 良判断。PRESIDENT の premise 誤り（P1 skip_serializing_if）も grounding で訂正された。
- codex は当環境 sandbox 不全で不可 → 手動 adversarial + /code-review で代替。

---

## 6. 新規/編集 memory の verbatim mirror（対向 PC 向け）

### 6a. MEMORY.md 追加/更新行（既存 genesis 行を以下へ置換）
```
- [hayate-kit-testruct (DTP north-star 実アプリ dogfood)](project_hayate_kit_testruct.md) — **2026-06-22**: Testruct 解答用紙エディタ (Mac/Win 完成) を hayate-kit のみ依存で Linux 移植、新 PRIVATE repo `revivals47/hayate-kit-testruct` (main `1ae74b4`)。**P1 モデル/P2 ZIP I/O/P3 DocumentPainter描画/P5段階A PNG export 全着地** (72 green)、実 .testruct が Wayland で kit-only 描画+PNG書出し可 (read-only viewer 段階)。設計要=単一描画 `DocumentPainter` trait。DTP dogfood が GUI_kit gap 捕捉: **K1着地**(#287 縦書き re-export)/**K10着地**(#288 CPU push_clip translate bug root-fix)/**K11 pending**(PDF glyph露出)/**K12 pending**(offscreen stack reset)。PDF=PoC済3択B次dispatch(pdf-writer)。fidelity微ズレ既知(font bundle未)。roadmap=repo `docs/ROADMAP.md`
```

### 6b. project_hayate_kit_testruct.md（full body、対向 PC でこのファイルを作成/更新）
frontmatter: name=project-hayate-kit-testruct / description=「hayate-kit-testruct = DTP north-star 実アプリ dogfood (Testruct 解答用紙エディタ Linux 移植) genesis + roadmap」/ metadata.type=project。

本文は本 repo（local）の `~/.claude/projects/-home-tlcr-Documents-Claude-Code-Communication/memory/project_hayate_kit_testruct.md` を参照（genesis 段落 + ソース + ロードマップ難易度逆転 + DocumentPainter/K1 + **進捗段落: P1-P5+K1/K10 着地・K11/K12 pending・PDF 3択B・fidelity 課題** + 次回再開段取り）。対向 PC では git pull 後の repo 実状（main `1ae74b4`、`docs/ROADMAP.md` §5 K-gap 表）を一次ソースに再確認すること。
