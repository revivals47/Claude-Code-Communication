# Handoff 2026-06-04 — 会社PC 引き継ぎ snapshot (multi-window L1 + PDF viewer 2 系統)

自宅PCで出勤前に snapshot。**会社PCで本 README + memory (project_multiwindow_l1 / project_pdfview_l2 + 規律 feedback 群) を Read して復元**。本 session は **系統① multi-window L1 (worker1) と 系統② PDF viewer (worker3) の 2 系統並行**。両系統とも基本完成済 + 次機能を実装中。

> ⚠️ **未コミット WIP を WIP-snapshot commit で保全済 (会社PC 転送のため)**。これらは **mid-implementation で未 verify / 未 compile の可能性**。会社PCで resume = WIP を完成させて cargo → gate の続き。

---

## 0. ★会社PC セットアップ (最初にやる)

### GUI_kit (origin = github.com/revivals47/GUI_kit、push 済)
```bash
cd ~/Documents/GUI_kit && git fetch origin
# worktree 再作成 (自宅PCの worktree は転送されない、branch は push 済ゆえ再作成):
git worktree add ../GUI_kit-s5b2 track-multiwindow/s5b-3       # 系統① worker1
git worktree add ../GUI_kit-pdfscroll track-pdf/continuous-scroll  # 系統② worker3 の L2 拡張
git worktree add ../GUI_kit-hotfix hotfix/popup-examples-create-popup-owner  # hotfix
```
### hayate-pdfview (★今回 private remote 新設 = github.com/revivals47/hayate-pdfview)
```bash
git clone git@github.com:revivals47/hayate-pdfview.git ~/Documents/hayate-pdfview
cd ~/Documents/hayate-pdfview
# ★libpdfium.so は gitignored (7.4MB) = 別途取得必須:
cat poc/pdfium-lib/FETCH.md   # 手順に従い poc/pdfium-lib/lib/libpdfium.so を取得
```
### PDF 起動 (live-visual 用)
```bash
cd ~/Documents/hayate-pdfview && cargo build   # まず WIP fix を完成させてから
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 \
  HAYATE_PDFIUM_LIB="$PWD/poc/pdfium-lib/lib/libpdfium.so" \
  ./target/debug/hayate-pdfview <pdf>
```
彩度高い色 PDF = `/home/ken/Downloads/中2国語_期末前日対策プリント_文法重点版.pdf` (色/連続 verify 用)。

---

## 1. 系統① multi-window L1 (GUI_kit、worker1)

### 到達点
- **✅ S5b-2 + S5b-2b LANDED** (main `1dcb049`)：dispatch routing cat1/2/3 + cat4 全完了 = input/output 全 path per-window owner-route、1-entry bit-exact。
- **▶ S5b-3 進行中** (実 2 窓を開く、初の user-live AC1)。branch `track-multiwindow/s5b-3` @ `131c0af` (worktree GUI_kit-s5b2)。
  - **✅ sub-a (regression-safety tier) locked**：9-cell PerWindowChannels split (primary=from_app bit-exact / runtime=fresh) + paste/IME per-window + a4 examples fix。bit-exact gate 緑 + PRESIDENT dual-verify 済。
  - **✅ b1 (id allocator) / b2 (wl_conn stash I6) / b3 (per-window GPU/vk helper) commit 済** (27d9a79 まで)。各 headless bit-exact。
  - **▶ b4 (open_window_live flip + App::on_ready hook A) = WIP commit 131c0af、未完成・未 verify**。app.rs/connection.rs/dispatch_impls.rs + 新 example multiwindow_smoke.rs。**resume = b4 完成 → cargo (b3 primary-GPU-byte 不変=golden を verify) → 初 user-live AC1 (2窓可視、AI 不可、user 手配)**。
  - **残 sub-c**：dnd owning-route + ★create_popup owner-scoping (scope (i) PRESIDENT confirm 済)★ + popup-owner e2e (headless 2-window unit=AC3 payoff AI 可)。
- **design = APPROVED** (`workspace/worker1-notes/s5b3_design_draft.md` v0.8、codex APPROVE-WITH-NITS、scope (i) 確定)。impl-spec final + PoC 3 領域緑。
- **★hotfix branch `hotfix/popup-examples-create-popup-owner` @ d8ac289 = git-ready (a4 cherry-pick)**：main 1dcb049 の popup examples が S5b-2b gate escape で broken (`create_popup` owner 必須化に 2 例未追従)。**b4 後の cargo gap で --example build evidence 付き PR→merge→main** (非 blocking)。s5b-3 は a4 で重複ゆえ rebase で drop。

### 次 action (系統①)
1. b4 完成 (open_window_live で 2 窓目 materialize + on_ready hook) → cargo → bit-exact (1-entry regression) + AC1 user-live。
2. hotfix land (evidence 付き)。
3. sub-c (popup owner-scoping + dnd + e2e)。
4. S5b-3 land → S5b-4 (per-window close lifecycle)。

---

## 2. 系統② PDF viewer (hayate-pdfview、worker3)

### 到達点
- **✅ MVP + zoom-UX cluster + 色 + auto-hide 全 user-verified 完了** (user「動作完璧」)：render/scroll/page-nav + 連続zoom/recenter/600-800% + toolbar(−/%/+/marquee/auto-hide 2.5s) + Ctrl+O multi-doc (dirty-gap/ImageKey collision/completion-edge 3-fix) + R↔B 色 fix (set_reverse_byte_order(false))。tag `mvp-v0.1.0`。
- **▶ Phase 4① 連続縦スクロール 実装中** (A = L2 既存 reuse + 併存 toggle)。
  - **design APPROVED** (3 re-gate REVISE→REVISE→APPROVE 収束)。★既存 ScrollViewWidget + VirtualViewport (FenwickTree) を per-item 高さ対応に拡張 = 新 widget 不要 (PRESIDENT measure-first redirect)★。bulk-storm = (b) batch (set_item_heights ONE recompute)。
  - **GUI_kit 側** (branch `track-pdf/continuous-scroll` @ `74c0f3d`、worktree GUI_kit-pdfscroll)：ScrollViewWidget variable-height 拡張 + VirtualViewport symmetrize/batch (L1) cargo-green 済。**▶ scroll_view.rs に impl-review fix WIP (Page uniform bit-exact branch、未 verify)**。
  - **PDF 側** (master @ `f89a981`)：continuous consumer wiring (view_mode SinglePage/Continuous + toggle + doc-wide zoom) cargo-green 済。**▶ viewer.rs に impl-review fix WIP (zoom>100% width-clamp blank 除去、未 verify)**。
  - **▶ combined impl-review = REVISE 2 finding (両 WIP fix 中)**：(High) viewer.rs:199 zoom>100% 幅 clamp で blank / (Medium) scroll_view Page=scroll_by(height) が既存 uniform consumer の floor-rows Page bit-exact 回帰 → uniform/variable 分岐。F1/F2/F3 + dirty-STALL contract は解消済 (設計核心 OK)。
- **Phase 4 roadmap** (user 直接指示)：①連続スクロール(今) → ②検索 Ctrl+F (FPDFText) → ③サムネ+jump (L2 navigator) → ④text 選択 (FPDFText)。
- **Phase 5 (将来)** = iLovePDF 系 manipulation (merge/split/compress/rotate/organize/JPG変換/watermark/page#/crop/protect/sign/OCR)。★Office 変換 (Word/Excel/PPT) は user「一旦不要」でスコープ外★。

### 次 action (系統②)
1. 2 WIP fix 完成 (viewer.rs zoom-blank + scroll_view Page uniform-branch) → cargo (b4 後の j1 slot) → combined re-verify → ★user live-visual (≣ continuous/滑らかさ/mixed-size/doc-wide zoom/single 非回帰)★。
2. GUI_kit (scroll 拡張) + PDF wiring の combined gate → impl-review → land (新 pub API ゆえ impl-review 必須)。
3. Phase 4② 検索へ。

---

## 3. coordination / 規律 (会社PC で継続)
- **★GUI_kit 共有 = worker1 (s5b-3) と worker3 (pdfscroll) が同 repo 別 worktree、cargo j1 serialize (boss1 起動前一報で排他)★**。共有 working tree 禁止 ([[feedback_shared_wt_commit_hygiene]])。
- **live-visual は AI 不可 = user 手配** ([[feedback_live_visual_verify_before_completion]] / [[feedback_ai_worker_capability_boundary]])：系統① AC1 2窓可視 / 系統② continuous scroll。
- **dirty-STALL class (PDF で 3+ 回)** ([[feedback_api_gate_verify_against_consumer_loop]])：背景遷移/completion-edge は dirty() 維持 + was_X latch。
- **verify-the-mechanism** ([[feedback_verify_reused_mechanism_behavior]])：reuse method は存在でなく完全性 (set_item_height の visible_range/revision invalidate) まで ground。
- **gate-integrity** ([[feedback_merge_gate_build_examples]])：examples gate の緑は実 `cargo build --all-targets` 出力 evidence 必須 (S5b-2b escape の教訓)。public-API signature 変更時は load-bearing criterion を独立 spot-check。
- **PRESIDENT 独立 grounding**：relay 鵜呑み禁止、claim を git/grep/cargo で裏取り (本 session で gate-escape / scroll-subsystem reuse / set_item_height partial-wire を catch)。

## 4. 全 remote/branch sha (2026-06-04 時点)
- GUI_kit origin: main `1dcb049` / track-multiwindow/s5b-3 `131c0af` (b4 WIP) / track-pdf/continuous-scroll `74c0f3d` (scroll fix WIP) / hotfix/popup-examples-create-popup-owner `d8ac289`
- hayate-pdfview origin (★private 新設): master `f89a981` (zoom-blank fix WIP)

## 5. ★「誰も動いていない」懸念について
自宅PC tmux の worker pane が今も active かは PRESIDENT (Claude) から確認不能。但し commit 直前まで **b4 + 両 impl-review fix の未コミット WIP が存在** = 直前まで worker は作業していた。会社PCでは tmux multiagent セッション再起動 → boss1/worker に上記 WIP の resume を dispatch。
