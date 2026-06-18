# Handoff 2026-06-18 — WORK-PC session FULL → home-PC

**在 PC = work-PC**（重要訂正: 本セッションは work-PC で実施。先行版 `handoff-2026-06-18-dtp-ruby-land.md` が「home-PC session」と**誤ラベル**していたのを訂正、本ファイルが正・包括版。旧ファイルは git rm 済）。
**hayate-amp = home-PC ローカル専用**（未 push、work-PC では再現/clone 不可）。
**Work-PC は明日(2026-06-19)不使用** → home-PC で滞りなく継続できるよう全 push + 完全引き継ぎ。

GUI_kit main HEAD = **`8e30e06`**（origin push 済、home-PC は `git pull` で全取得）。track-dtp = **`576c046`**（= 8e30e06 + workspace design docs、origin push 済）。

---

## 1. 本日の GUI_kit land サマリ（4 PR、全て origin/main 済）

| PR | 内容 | 主導 |
|---|---|---|
| **#275** | 縦書き engine + L2 `VerticalTextWidget` + **グループルビ** (stage1+2)。codex 実バグ2件(列分割 stale anchor / ルビ内 `\n`)を同PR root-fix | PRESIDENT 直接 (track-dtp) |
| **#277** | `clippy::never_loop` root-fix (`line_height_for` の for+break→next、挙動同一) | boss1 dispatch |
| **#278** | hayate-platform examples の `draw_buffer` 8-arg 取りこぼし E0061 を 16 site/6 file 根治 (#276 の取りこぼし) | boss1 dispatch |
| **#279** | **window_request** = 実行時ウィンドウ開閉の宣言的機構 (popup_request 忠実ミラー + Option A reconciliation)。hayate-amp 要望 | boss1 dispatch / PRESIDENT design-authority LGTM + 実機 live GO |

全件 squash merge、cargo j1 cross-track 直列で contention ゼロ維持。

## 2. ★ home-PC で継ぐ最優先タスク = slider 間欠ドラッグ追従バグ

**症状** (user 報告): slider をドラッグ→離しても、稀にハンドルが pointer に追従し続ける。大抵は正常、窓内でも発生。
**repro 台 = hayate-amp (home-PC ローカル専用)**。work-PC に無いため trace-confirm と live-verify は home-PC でのみ可能 → 本タスクを home-PC へ持ち越し。

**root-cause (現 main 8e30e06 で grounding 済)**: App-level pointer capture が不在 (grep 0) で、drag 継続が `event_overlay` self-gate + dispatch だけに依存。release が dragging 中 slider に届かない経路が 2 系統 — (1) chrome 短絡 (`event_with_csd`@app.rs:917 冒頭 `slot.event`@919 が先処理) / (2) overlay 短絡 (`event_overlay` forward が first-non-Ignored@core.rs:676、先行 overlay widget が shadow)。off-window は解決済、残りは in-window のこの2短絡。

**fix 設計 = App-level pointer capture** (両短絡を一掃する class-wide 解決)。詳細・実施手順は下記 doc に full embed 済:
- `GUI_kit/workspace/slider_pointer_capture_design_v0.1.md` (track-dtp、機構 + edge + home-PC 実施手順 trace-first 7 step)
- `GUI_kit/workspace/slider_drag_release_investigation.md` (track-dtp、root-cause 調査)

**home-PC 着手フロー** (doc に詳細): ① 最新 main で再 grounding (line shift 吸収) ② 使い捨て trace (slider.rs + app.rs に eprintln) を仕込み hayate-amp で**再現→機構確定** ③ trace revert + 回帰テスト化 ④ pointer-capture 実装 (boss1 dispatch 推奨、worktree `feat/slider-pointer-capture`) ⑤ cargo j1 検証 + codex 査読 ⑥ hayate-amp で live-verify ⑦ PR→merge。**trace 前なので fix は未着手・land 禁止**（機構が想定外なら設計 revise の余地を残す）。
※ scroll_bar も同 story (slider.rs:690 コメント) = 同バグ潜在。capture 化で class-wide 同時解決推奨。

## 3. window_request (#279) — hayate-amp 側の使い方

hayate-amp の「メインからペダルを足しに行く」UX 用。Board パネルの widget に `Widget::window_request()` を実装:
- 開く: `WindowRequest::Open { tag, config, root: ペダル UI, decorations }` を1回返す (edge model、`pending.take()` で再発行しない)
- 閉じる: `WindowRequest::Close { tag }`
- `on_window_closed(tag)` を override し「開いてる」flag をリセット (ユーザが窓を自分で閉じても自動同期)
- 型は **hayate-kit prelude から到達** (`WindowRequest`/`WindowTag`、hayate-platform 直 dep 不要、[[feedback_new_apps_depend_on_gui_kit_only]])
設計 doc = `GUI_kit/workspace/window_request_design_v0.1.md` (track-dtp、v0.2 = arm-hook→reconciliation revision 履歴込)。

## 4. 次 DTP ステージ backlog (ルビ #275 land 後)
① 縦書き経路の `scratch_buffer`/`shape_cache` 載せ替え (RSS 漸増、user 指摘) ② **`.family()`/明朝(serif) 対応** (現状 SansSerif 決め打ち、組版品質、user 重視) ③ 約物/禁則 (括弧縦字形・`。」`アキ・行頭行末禁則) ④ Latin 縦中横・caret/selection・mono/熟語ルビ。着手は user trigger 待ち。

---

## 5. 🔁 home-PC PRESIDENT への memory mirror (必須適用、memory は local-only)

home-PC の `memory/project_dtp_app_roadmap.md` の `## ⚡ 2026-06-17 縦書き/ルビ feasibility 確定` セクション末 `② 待ち` 行末に「→ **2026-06-18 に Stage 1+2 land で全 5 判断点 resolved (下記)**。」を追記し、直後に以下を挿入 (verbatim):

```markdown
## ⚡ 2026-06-18 Stage 1+2 land (縦書き engine + グループルビ) — work-PC session

2026-06-17 POC → feasibility 確定を受け Stage 1 (engine vertical core + L2 `VerticalTextWidget`) + Stage 2 (グループルビ) を実装・**main land**。PC クラッシュ復帰後の work-PC session で完遂 (在 PC = work-PC、hayate-amp は home-PC)。

- **landed**: PR #275 squash → GUI_kit main HEAD=`f7e5549`(当時)→現 `8e30e06`。`crates/hayate-platform/src/render/text.rs` の `TextEngine::layout_vertical` (2 パス: base を RTL 列配置しつつ ruby job 記録 → ink 位置 + ルビ strip 解決)、`VerticalSegment::{Plain,Ruby}`、`VerticalTextBlock::measure_segments`、L2 `VerticalTextWidget` (builder `.text()/.ruby(base, reading)`)。`。、，．` は cell 右上。ルビ = `RUBY_FONT_RATIO`(0.5) を base 列の右 strip に **base span 全体へ均等配分 = グループルビ** (mono/熟語ルビではない)。
- **検証**: test -p hayate-platform --lib = 918 passed/0 fail (ルビ 4 test)、build -p hayate-kit --examples 緑、実機 visual GO。codex 査読で実バグ2件 (列分割 stale anchor / ルビ内 `\n`) を同 PR root-fix。
- **`。」`/括弧 probe で約物 gap 確認**: `。` は右上寄せ済だが括弧は横字形のまま (縦字形 vert 未適用)・`。」` アキ無し → 約物/禁則は次ステージ (設計上の段階分け、docstring scope 外)。
- **次 DTP backlog**: ① scratch_buffer/shape_cache 載せ替え(RSS) ② `.family()`/明朝 ③ 約物/禁則 ④ Latin 縦中横・mono/熟語ルビ。Stage 3 着手 user trigger 待ち。
- ルビ pitch 契約 = `RUBY_MIN_PITCH_RATIO`(1.6) + debug_assert + doc。
```

`MEMORY.md` の DTP roadmap 索引行は home-PC 既存と差異あれば以下に揃える (verbatim):

```markdown
- [GUI_kit 長期 north star = DTP app (日本語 / ルビ / 縦書き)](project_dtp_app_roadmap.md) — GUI_kit 長期 north star=DTP ソフト(日本語+ルビ+縦書き必須)。2026-05-26 境界確定: 実在 2 アプリ(Testruct=testruct-v3 国語解答用紙 / ファイラ Hayate=Mac_explorer_v2 v2.4.6)の Linux 移植で「L2 十分」を有限化。**2026-06-18: 縦書き engine + L2 VerticalTextWidget + グループルビ ✅ land (PR#275 squash、main `8e30e06`、test --lib 918 passed、codex 実バグ2件同PR root-fix、実機 visual GO)。次 DTP ステージ backlog = ① scratch_buffer/shape_cache 載せ替え(RSS) ② .family()/明朝対応 ③ 約物/禁則(括弧縦字形・。」アキ)、着手 user trigger 待ち**。ファイラ合成系一部 (multi-pane / pane DnD 等) は [[project_hayate_kit_agents_v3]] 先行 dogfood
```

## 6. file / doc inventory (漏れ確認用)
- GUI_kit origin/main `8e30e06`: 本日 4 PR 全反映 (home-PC: git pull)。
- GUI_kit origin/track-dtp `576c046`: 8e30e06 + workspace/{window_request_design_v0.1, slider_drag_release_investigation, slider_pointer_capture_design_v0.1}.md (home-PC: git checkout track-dtp で design docs 取得)。
- comms (revivals47 fork = userfork) main: 本 handoff doc。
- 旧 `handoff-2026-06-18-dtp-ruby-land.md` は git rm (本ファイルが包括・正)。
- memory edit (work-PC ローカル ~/.claude): §5 mirror を home-PC で手適用。

## 7. 運用ノート / 既知事項
- **codex CLI が background+pipe で stdin block する invocation 問題** (#279 査読で発覚、'Reading additional input from stdin...' で中身ゼロ exit 0)。次回 codex exec は prompt 渡し方を変える (stdin 経由 or 適切フラグ)。**1 case 目なので memory 化保留、再発で promote 判断** ([[feedback_memory_prescriptive_value_requirement]])。
- **pkill -f は自分のシェル command line もマッチして自爆する** — codex 停止時に踏んだ。PID 直 kill か、自コマンドに含まれない pattern を使う。
- dual-PC 規範違反の自戒: **session start 時の在 PC 能動確認を怠り home-PC と誤認** (本訂正の発端)。次回 session 冒頭で在 PC 確認必須 ([[reference_dual_pc_setup]])。
- boss1 + worker は idle standby、winreq worktree 撤去済、残 worktree = track-dtp のみ。
