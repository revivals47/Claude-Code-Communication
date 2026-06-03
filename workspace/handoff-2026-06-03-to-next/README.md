# Handoff 2026-06-03 — 2 並行 initiative 再開用 snapshot

次 session の Claude (PRESIDENT) は本 README + memory (project_multiwindow_l1 / project_pdfview_l2 + 規律 feedback 群) を Read して context 復元。本 session は **multi-window L1 (worker1) と PDF viewer (worker3) の 2 系統並行**。

---

## 系統① multi-window L1 (GUI_kit、worker1)

### 到達点
- **S5b-1 ✅ MERGED** (PR #221 → main `236ce0c`、squash)：factory-closure + per-window drain/event 一般化 + Case A focus owner-hold、全 1-entry bit-exact。
- **S5b stage 構成 (PRESIDENT 確定、a2-iii split 適用後)**:
  - **S5b-2** = dispatch-handler id-routing **cat1/2/3** (surface/seat-focus/scale)。design **v0.6 PRESIDENT verify PASS** (cat2 emission completeness を multi-grep cross-check で達成)。→ **次 = codex re-gate** (codex slot 空き)、clean なら impl-spec。
  - **S5b-2b** = dispatch-handler **cat4** (popup/buffer owned-object)。a2-iii split-off。3 structural の design cycle 中: (1) create_popup owner-id-bearing API (parent_wid plumb 不足) (2) 全 buffer-create site owner tag = SHM(buffer.rs)+DMA-BUF(dmabuf.rs create_immed)+popup pool (3) popup_surface_to_id.remove を popup close から UiState/owner 到達させる lifecycle hook。+ pending_drop continuation (cat4-source)。
  - **S5b-3** = open_window_live 2窓 materialization (★初 user-live AC1=2窓可視/AC3 routing、capture-vs-fresh PerWindowChannels 6→9 + id allocator + GPU-vk runtime)。draft = s5b3_design_draft.md。
  - **S5b-4** = lifecycle (9-assert + per-window close=quit_flag decouple + title hardcode 廃止)。
- sequencing: S5b-2 → S5b-2b → S5b-3 → S5b-4。S5b-2/S5b-2b は両方 bit-exact headless ゆえ 2窓 flip (S5b-3) 前に land。

### worktree / 未 commit 物
- **GUI_kit-s5b2** (branch `track-multiwindow/s5b-2`、base 236ce0c)。★design draft 3本 untracked★: `workspace/worker1-notes/{s5b2_dispatch_routing_draft.md, s5b2b_popup_buffer_draft.md, s5b3_design_draft.md}`。code commit なし (design phase)。**再開時 commit or 保全要**。

### 再開 action (系統①)
1. **S5b-2 codex re-gate** (v0.6、cat2 completeness)。clean なら impl-spec → PoC (2-arg macro borrow / snapshot-then-drop) → impl (Pattern 1) → bit-exact gate (lib 843/0 + golden 12-2 + dogfood 8 + warning-clean + examples) → codex impl-review → PRESIDENT verify → merge (squash、per-stage PR)。
2. **S5b-2b** design draft → boss1 確認 → PRESIDENT verify → codex design-gate (3 structural)。S5b-2 advance と並行可。

### dispatch-routing 確立規範 (S5b-2/S5b-2b で適用)
2-arg window! macro / 全 33 Dispatch 4-category (surface/seat-focus/scale/owned-object) **no-silent-omission** / **graceful-missing** (late-event-after-close ignore、hard-expect rare/none) / **snapshot-then-drop** (whole-state call=apply_cursor_shape 等の前に per-window 値 snapshot→borrow drop) / **Case A 4-focus** (pointer/keyboard/dnd/ime Enter owner-resolve、popup→owner via window_id_from_popup_surface) / **leave-side snapshot-before-clear** (4 site) / **buffer WindowId UserData** (create_buffer 引数 tag、map→scan→UserData 収束) / **focus-TRACKING≠event-DELIVERY** (focus tracking + 全 emission arm の両方を完全列挙)。

---

## 系統② PDF viewer (hayate-pdfview、worker3、新規 initiative)

### 到達点
- L3 consumer app (imageview-l2 / notepad-l2 同系列、L2=hayate-kit consume)。MVP = 基本ビューア (render+scroll+zoom step+page-nav+FilePicker、imageview composition 再利用)。
- **backend = pdfium-render LOCK-IN** (PRESIDENT 決定)：Phase0 survey で実 PDF 4種 (★Testruct English_June.pdf target 一致) → BGRA rasterize 実証、license clear (BSD-3/MIT)、pure-Rust は rasterizer なし不可。
- design: v0.1 → v0.2 (owner-thread + zoom composite-key) → re-gate → **v0.3 committed (`e1b6ce0` command-driven document-session service)**。
- **★次 = PDF v0.3 PRESIDENT verify 未実施 (本 session pause 時点で committed・verify 待ち)**。v0.3 = owner-thread を document-session actor 化 (OpenDocument(path)→Ready{page_count,page_sizes}|Failed / DecodePage{page,zoom,gen}→Image|Failed / Shutdown の command protocol + multi-doc OpenDocument handshake=reset()+doc 差替 + session state machine)。

### repo
- **~/Documents/hayate-pdfview** (HEAD e1b6ce0)。survey doc + design draft (phase0/phase1) + PoC (poc/rasterize-poc + poc/feature-min + poc/pdfium-lib libpdfium.so 7.4MB)。

### 再開 action (系統②)
1. **PDF v0.3 PRESIDENT verify** (owner-thread session actor command protocol + OpenDocument handshake + Ready/Failed state machine、mechanism ground = decode.rs reset()/CarouselWidget set_page_count 確認済) → PDF codex re-gate。
2. clean なら impl-spec → PoC → impl (rasterize.rs owner-thread / viewer.rs carousel+canvas+picker / main.rs) → **★live-visual AC (user 手配)★** (実機 VulkanDirect で PDF open/scroll/zoom crisp/nav 目視) → merge。

### §5 design 申し送り (一部 PRESIDENT 裁定済)
連続スクロール=post-MVP+L2 拡張提案 (可変高さ virtual page-stack、L3 私有禁止) / zoom step 50-400%+4096 cap / feature-min `default-features=false`+["pdfium_latest","thread_safe"] (cargo 実証済) / libpdfium git-direct vendored (7.4MB) / prefetch MVP=current±1・navigator サムネ post-MVP。

---

## 本 session 確立 / 強化した規律 (両系統横断)
- **verify-mechanism-not-intent** ([[feedback_verify_reused_mechanism_behavior]])：design が「既存 mechanism (generation/cache/feature) reuse」と言う時、★mechanism の実挙動を ground せず intent を approve しない★。PRESIDENT 自己 gap (PDF zoom-key=decode.rs cache 未 ground / owner-thread=pdfium feature defer) + S5b focus-routing 2-miss が同根。
- **no-silent-omission multi-grep cross-check** (Pattern 5 enumeration)：完全性は単一 grep でなく ★複数独立 exhaustive all-file grep の union★。cat2 emission = codex+PRESIDENT grep×2+boss1 grep×2 の 5 pass で収束 (key-repeat connection.rs:1334-1337 は boss1 全ファイル grep のみ catch)。event-emission path は予想外 file に潜む (per-handler grep でなく cross-file)。
- **pre-authorized split-trigger**：深い cluster (a2-iii popup/buffer = 3-round 深掘り) は独立 stage 分割、bounded completion (PDF session 層 / cat2) は in-place。判別が鍵。
- **focus-TRACKING ≠ event-DELIVERY routing**：focus state を route しても実 event push を route しなければ誤配送。S5b-1 H2/inbound/leave-side/cat2 emission が同根。
- **honest 分類 (gating-cap)**：real finding を nit 偽装して loop 脱出しない。codex adversarial が最終 word。
- **PRESIDENT 独立 grounding**：relay/summary 鵜呑み禁止、claim を自分で grep/cargo/git 裏取り。本 session で squash 訂正 (merge-commit 誤推奨) / m6・v0.6 miss / PDF 2 gap を catch、また boss1 grep が PRESIDENT list の漏れ (594/658/key-repeat) を catch = 多層 cross-check。

## 運用メモ
- worker1=S5b (GUI_kit-s5b2) / worker3=PDF (hayate-pdfview)、完全並行・別 repo。**worker2 は未割当 (空き)**。
- codex/cargo は **-j1 serialize** (両系統の gate は 1 本ずつ、background run 可)。
- in-house 実装 (boss1→worker)、codex=review。live-visual は AI 不可 (user 手配)。
- 次 session 開始時 = GUI_kit main fetch (236ce0c 確認) + hayate-pdfview fetch + memory Read。
