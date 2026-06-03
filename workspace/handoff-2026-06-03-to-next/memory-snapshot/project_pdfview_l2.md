---
name: project_pdfview_l2
description: "hayate-pdfview = L2 PDF viewer initiative, Phase 0 survey done (pdfium recommended)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 0c1128fc-dc9e-4904-9ca9-248007dbe93e
---

PDF ビューワを L2 (hayate-kit) consumer として作る initiative (2026-06-03 user 直接指示、worker3 担当、imageview-l2/notepad-l2 同系列、[[feedback_apps_on_l2]])。repo = ~/Documents/hayate-pdfview。

**✅ Phase 0 SURVEY 完了** (2026-06-03、commit 660846a)：
- **推奨 backend = pdfium-render (Google pdfium FFI) + bblanchon prebuilt libpdfium.so** (BSD-3 + MIT wrapper、AGPL なし)。
- cargo PoC 実証 (poc/rasterize-poc): 実 PDF 4種 (Testruct 生成 English_June.pdf 含む) page1→**native BGRA8888**, byte-exact w·h·4 (**swizzle 不要**), 15-60ms@150dpi。`Renderer::draw_image` contract 完全一致。
- pure-Rust (pdf-rs/lopdf) = parse 可だが **rasterizer 未成熟 → MVP 不可**。mupdf = AGPL 却下。
- **L2 reuse map**: imageview の `decode.rs` DecodeService = 直接転用 (decode_full を pdf rasterize に差替えるだけ、off-thread/generation 機構そのまま)。CanvasViewWidget(zoom/pan)/CarouselWidget(page nav)/FilePickerWidget(open)/draw_image も直接転用。**MVP で L1/L2 新規 API 追加 原則不要**。
- design phase 申し送り: ①連続縦スクロール vs carousel 離散ページ送り (L2 拡張要否) ②crisp zoom = target DPI 再 rasterize + ImageKey.revision bump (canvas upscale はボケる) ③pdfium-render 最小 feature (default-features=false で image 統合切れる) ④libpdfium.so 配布方法 ⑤page prefetch。

**✅ Phase 1 DESIGN DRAFT 完了** (2026-06-03、commit 69687d7、doc = workspace/worker3-notes/phase1_design_draft.md)：§5 申し送り 5 件 裁定:
①MVP=carousel (L2 既存・work ゼロ)、連続縦スクロールは post-MVP → ListView 固定 item_height ゆえ「可変高さ virtual page-stack」を L2 拡張提案 (L3 私有禁止)。②zoom=段階 step で target DPI 再 rasterize + ImageKey.revision bump、中間は canvas scale 暫定。③pdfium-render 最小 feature **cargo 実証**: default-features=false+[pdfium_latest,thread_safe]→dep 36→19、raw BGRA 不変 (poc/feature-min/)。④libpdfium.so=repo vendored (chromium/7869) + bind_to_library 明示パス。⑤prefetch=decode.rs full-queue(current±1)+thumb-queue(navigator)。
精度訂正: **CanvasViewWidget は stateless** (zoom/pan は app-side PageState 所有=imageview 同型、canvas は event forward のみ)。モジュール: main.rs/document.rs/rasterize.rs(中核=decode.rs 派生)/viewer.rs。

**✅ design v0.2** (codex design-gate REVISE 反映、commit 3e757f7、実コード確証): **REVISE-1 owner-thread model** = pdfium `PdfDocument` Send/Sync は `#[cfg(feature="sync")]` gated + README「at your own risk」ゆえ **sync 不採用**、専用 1 thread が Pdfium+PdfDocument 所有・main は (page,zoom,gen) channel 要求 (thread_safe 単体=FFI mutex 直列化のみ、decode.rs worker は path 所有で doc 非対応)。**REVISE-2 zoom-key** = request id に zoom_step encode (id=(page,zoom)→cache miss→crisp rerender) + **generation は維持** (nav-abandonment 用、直交 2 軸両立)。nit: CanvasView は「内部 state 持つ・zoom/pan は app-owned」/ 2-queue→owner-thread 1本 full>thumb priority レーン (doc 共有不可+thread_safe 直列化で並列利得ゼロ)。

**✅ design v0.3** (codex re-gate、commit e1b6ce0): round1 resolved、残=owner-thread が露呈した **document-session lifecycle 層**を §3b 新設。**command-driven session service**: `SessionCommand{OpenDocument/Decode/Shutdown}` + `SessionState{Opening/Ready{page_count,page_sizes}/Failed(err)}` handshake (Arc<Mutex> を root が update() で非 blocking poll、Ready→carousel.set_page_count)。doc-open-fail は **session-level** で表現 (per-request Decoded::Failed では open 前 valid id ゼロで不可)。Ctrl+O rebind = **decode.rs reset() pattern (L200-206) 適用** (gen bump+requested/results clear+owner doc 差替、ordering 不変条件で旧結果混入なし)。nit: composite id=newtype `PageKey{page:u32,zoom:u16}`。module: session.rs 追加。

次 = boss1 確認 → PRESIDENT verify → codex re-gate → impl-spec → impl。**完成判定は live-visual (実 app VulkanDirect) 必須・user 手配** ([[feedback_live_visual_verify_before_completion]])。worker1 S5b と完全並行・別 repo。

survey doc = workspace/worker3-notes/phase0_pdf_backend_survey.md。
