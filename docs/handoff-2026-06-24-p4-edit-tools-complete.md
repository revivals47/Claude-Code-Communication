# Handoff 2026-06-24 — testruct ★★P4 編集ツール全完了 (work-PC → home-PC)

## 在 PC / セッション概要
- **発信 PC**: work-PC (2026-06-24)
- **本 session の成果**: testruct の **P4e-1 undo/redo** + **P4e-2 snap** を land し、**★★P4 編集ツール全 stage 完遂**。viewer → full interactive editor 化が完了。
- **次 step は user trigger 待ち** (idle standby)。

## 現在の repo 状態
| repo | branch | HEAD | 同期 |
|---|---|---|---|
| `~/Documents/hayate-kit-testruct` | main | `46804da` | origin (revivals47/hayate-kit-testruct) push 済、local branch=main のみ (track ブランチ --delete-branch 済) |
| `~/Documents/Claude-Code-Communication` | main | (本 doc commit 後) | userfork (revivals47/Claude-Code-Communication) push 済。origin=Akira-Papa upstream は無関係 |

> home-PC は別 clone・別 cargo cache。session start 時に在 PC を能動確認すること ([[reference_dual_pc_setup]])。

## 本 session land 内容 (testruct)

### P4e-1 undo/redo (PR #12、main `76bec08`)
- testruct-core `undo_stack.rs` (純ロジック headless): **group ベース UndoStack** = `undo:Vec<Vec<Box<dyn DocumentCommand>>>` / redo 同型 / `last_coalesce:Option<CoalesceKey(enum)>` / max_depth=100。
- push(=apply+vec![cmd]+redo.clear+reset+front-drop cap) / push_coalesced(同 key=undo.last_mut().push、else 新 group+cap) / undo(=group **逆順 revert**→redo) / redo(=group **正順 apply**→undo)。
- **coalescing=action-based (timer 不要 deterministic)**: nudge=push_coalesced(Nudge) ゆえ連続矢印=1 group=1 undo (Mac 忠実)、Move/Resize/Delete/TextEdit=push (各 atomic)。reset_coalesce=on_press(無条件 burst 分割)+enter_text_edit。
- canvas 5 apply 経路全て stack 経由に route (旧直 .apply 除去)、Ctrl+Z=undo / Ctrl+Shift+Z(+Ctrl+Y)=redo、undo/redo で選択同期。
- **設計は codex 当環境不全ゆえ PRESIDENT manual analysis で確定** (Explore 当初案「mid-burst apply するが push しない」=undo で最初1命令しか戻らない bug を group 案で回避)。
- finder defect ゼロ (10 risk class)、cargo 143、3 fixture byte-identical。live-verify 3/3 PASS。

### P4e-2 snap (PR #13、main `46804da`) = ★P4 完了の最終ステージ
- testruct-core `snap.rs` (純ロジック page-unit headless): GridSnap(spacing 20、clamp 10-200、round(v/s)*s) + SnapEngine::snap → SnapResult{dx,dy,guides}。
- **object-edge 3×3 (threshold strict< 6.0、軸ごと最近接勝者) 優先 → object snap 無い軸のみ grid (threshold 3.0、offset のみ・guide なし) fallback**。guide=object-edge 勝者のみ。snap_resize_bounds=active edge のみ grid 吸着 (anchored 固定、min-size pin)。
- 原本 ground=SnapEngine.swift/Win SnapEngine.cs・GridSnap.cs・InteractionSnap.cs (de7ce07)。
- canvas wire: Move drag=full snap (others=選択外 top-level bounds、effective offset=drag+snap)、Resize=grid edge-aware のみ (Win InteractionSnap faithful、object-edge+guide は future)、確定=**P4e-1 UndoStack.push 再利用** (snapped 値、atomic、undo 1 回、二重 apply なし)、guides=paint_overlay (drag 中のみ・clear@press+release)。
- threshold は page units=zoom 非依存 (原本忠実)。scope v1=Move 全部/Resize grid-only/snap 常時 ON。
- finder defect ゼロ (12 risk class)、cargo 153 (core 110+ui 43)、全<500、byte-identical。live-verify 4/4 PASS。

## ★★P4 編集ツール全 stage 完遂サマリ
| Stage | 機能 | PR / main |
|---|---|---|
| P4a | 選択 + 移動 | #9 `2425cc1` |
| P4b | リサイズ + 削除 + nudge | (focusable() fix) |
| P4d | text inline 編集 + 日本語 IME | #11 `978efa8` |
| P4e-1 | undo/redo (group/coalesce) | #12 `76bec08` |
| P4e-2 | snap (grid20 + edge6 + guides) | #13 `46804da` |

**全 kit-only = hayate-kit gap ゼロ、facade 十分性を editor 全域で実証** (PDF track K11/K13/K14 還元と対照的に P4 は GUI_kit 還元ゼロで成立)。

## 次 step 候補 (user trigger 待ち)
- **P1.1 モデルパリティ** — PlotElement(関数プロット) + shape 装飾 + 8 図形 + PresetCatalog (原本 de7ce07 で先行、P4c 図形作成の前提)
- **P4c 図形作成ツール**
- **cursor gap** — リサイズ/移動時のカーソル形状変更 (唯一の hayate-kit gap 候補、GUI_kit SetCursor track)
- **PDF ligature ToUnicode** 等 PDF 仕上げ残

## ★運用 gotcha (本 session で 5 回踏んだ、home-PC でも注意)
- `pkill -f hayate-kit-testruct` は **自分自身の bash コマンドライン (同文字列を含む) にマッチして実行シェルを kill** → exit 144 で後続 (merge 等) が走らない。
- アプリ kill は **comm 名マッチ** を使う: `for p in $(pgrep hayate-kit-test); do kill "$p"; done` (pgrep は comm=15字 "hayate-kit-test"、自己 comm="pgrep" ゆえ非自己マッチ)。`pkill -f <binary名>` 系は全て self-kill risk。
- `cmd | head -N` でアプリ起動すると head が pipe を閉じ SIGPIPE で exit 101=panic に見えるが偽陽性 (アプリは正常)。起動は file redirect で。

## memory mirror (home-PC 反映必須 — memory は local-only)
本 session で `memory/project_hayate_kit_testruct.md` を編集 (P4e-1 着地 / P4e-2 着地 + P4 全完遂サマリ / 運用 gotcha 段落を追加)。home-PC の同名 file へ上記「本 session land 内容」「★★P4 全 stage 完遂サマリ」「運用 gotcha」を反映すること。MEMORY.md index 行 (testruct project エントリ) は home-PC 側の現行のままで内容整合 (P4 完了は topic file 側に詳細、index は据え置き可)。MEMORY.md は容量超過中ゆえ index 行を増やさない。

## live-verify 起動メモ (home-PC 再現用)
- undo/redo 検証: `cargo run -p testruct-ui -- crates/testruct-core/tests/fixtures/text_edit_smoke.testruct` (text 3 要素=plain-JSON fixture)
- snap 検証: `cargo run -p testruct-ui -- crates/testruct-core/tests/fixtures/edit_smoke.testruct` (複数要素)
